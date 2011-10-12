//
//  functions.m
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "functions.h"
#import <Accelerate/Accelerate.h>

#define _max_points  512 //the maximum number of points you may give to the functions. I decided not to allocate memory dynamically for performance reasons


@implementation functions





//accepts a line (closed or open path) in the form of 2 float arrays
//returns  a closed path (outline)  that surrounds the points of the given path 
+(CGMutablePathRef) newClosedPathWithWidth: (float) pw fromPointsWith_x: (float*)pixelx and_y: (float*)pixely withLength: (int) n whichIsClosed:(bool) isClosed
{
    if(n<2)
        return nil;
    
    pw = pw/2;
    
    
    CGMutablePathRef outline_path = CGPathCreateMutable();
    float cpUx [_max_points];//the points for the outer part of the outline
    float cpUy [_max_points];
    float cpDx [_max_points];//the points for the inner part of the outline
    float cpDy [_max_points];
    
    float px[_max_points];
    float py[_max_points];
    float diffx[_max_points];
    float diffy[_max_points];
    float lengths[_max_points];
    float normalx[_max_points];//the  unitary vectors perpendicular to the lines that form the original path
    float normaly[_max_points];
    float vectorx[_max_points];//the vectors thas are formed by 2 normals
    float vectory[_max_points];
    
    float dot[_max_points];
    float scalar = 1;
    int k;

    //copy the input values to our float arrays
    if(isClosed == YES && n>2){
        //if the input path is closed, shift the input array by one and add as first element the last of the input and as last element the first of the input
        memcpy(px+1, pixelx, sizeof(float)*n);
        px[0] = pixelx[n-1];
        px[n+1] = pixelx[0];
        memcpy(py+1, pixely, sizeof(float)*n);
        py[0] = pixely[n-1];
        py[n+1] = pixely[0];
        n+=2;//we will compute 2 more elements
        k=1;
    }
    else{
        memcpy(px, pixelx, sizeof(float)*n);
        memcpy(py, pixely, sizeof(float)*n);
        k=0;

    }
    
    
    vDSP_vsub(px,1,px+1,1,diffx+1,1,n-1);//compute the differences of the points in pairs
    vDSP_vsub(py,1,py+1,1,diffy+1,1,n-1);
    vDSP_vdist(diffx+1, 1, diffy+1, 1, lengths+1, 1, n-1);//take the square root of the sum of the squares of the differences (length)
    vDSP_vdiv(lengths+1, 1,diffx+1 , 1, normaly+1, 1, n-1); // divide the differences with their length to get the normal vectors
    vDSP_vdiv(lengths+1, 1, diffy+1, 1, normalx+1, 1, n-1); 
    vDSP_vneg(normalx+1, 1, normalx+1, 1, n-1);
    
    //compute the first and last vectors for open paths (don't need to do that for closed paths)
    if(isClosed==NO || n<=2){
        vectorx[0] = normalx[1];
        vectory[0] = normaly[1];
        vectorx[n-1] = normalx[n-1];
        vectory[n-1] = normaly[n-1];
    }
    
    //compute the vectors for the line joins
    if(n>2){//we need at least 3 points to have a join
        
        vDSP_vadd(normalx+1, 1, normalx+2, 1, vectorx+1, 1, n-2);//add the normal vectors in pairs of 2 to get the final vectors (they will be scaled)
        vDSP_vadd(normaly+1, 1, normaly+2, 1, vectory+1, 1, n-2);
        
        vDSP_vmma(normalx+1, 1, normalx+2, 1, normaly+1, 1, normaly+2, 1, dot+1, 1, n-2);//calculates the dot products of the pairs of normal vectors
        vDSP_vsadd(dot+1, 1, &scalar, dot+1, 1, n-2);//add 1 because that's the scaling factor we need
        
        vDSP_vdiv(dot+1, 1, vectorx+1, 1, vectorx+1, 1, n-2);//scale the vectors by dividing them with their scaling factors
        vDSP_vdiv(dot+1, 1, vectory+1, 1, vectory+1, 1, n-2);
        
        
    }

    if(isClosed == YES && n>2){
        n=n-2;
    }
    vDSP_vsmul(vectorx+k, 1, &pw, vectorx+k, 1, n);//multiply the vectors so that we get the width we want
    vDSP_vsmul(vectory+k, 1, &pw, vectory+k, 1, n);
    vDSP_vadd(vectorx+k, 1, px+k, 1, cpUx, 1, n);//add the vectors to their points to get the upper section of the outline
    vDSP_vadd(vectory+k, 1, py+k, 1, cpUy, 1, n);
    vDSP_vneg(vectorx+k, 1, vectorx+k, 1, n);
    vDSP_vneg(vectory+k, 1, vectory+k, 1, n);
    vDSP_vadd(vectorx+k, 1, px+k, 1, cpDx, 1, n);//add the vectors to their points to get the down section of the outline
    vDSP_vadd(vectory+k, 1, py+k, 1, cpDy, 1, n);
    
    //-----------create the resulting cgpath--------------
    
    //add the points of the outer part of the ouline
    for(int i=0; i<n; i++){
        //NSLog(@"x:%f y:%f ux:%f uy:%f dx:%f dy:%f",px[i],py[i],cpUx[i],cpUy[i],cpDx[i],cpDy[i]);
        if (i==0) 
            CGPathMoveToPoint(outline_path, nil, cpUx[i],cpUy[i]);
        else
            CGPathAddLineToPoint(outline_path, nil, cpUx[i], cpUy[i]);
    }
    
    //add the points of the inner part of the outline
    if(isClosed == YES && n>2){
        CGPathCloseSubpath(outline_path);
        for(int i=n-1; i>=0; i--){//we add the points in reverse order so that if you fill this path it stays empty inside
            if (i==n-1) 
                CGPathMoveToPoint(outline_path, nil, cpDx[i],cpDy[i]);
            else
                CGPathAddLineToPoint(outline_path, nil, cpDx[i], cpDy[i]);
        }

    }
    else{
        for(int i=n-1; i>=0; i--)
            CGPathAddLineToPoint(outline_path, nil, cpDx[i], cpDy[i]);
    }
    CGPathCloseSubpath(outline_path);
    
    return outline_path;
}


struct dataPointer  {
    float indexx[_max_points];
    float indexy[_max_points];
    int numberOfPoints;
    bool isClosed;
};

//this is a CGpath applier function that converts the cgpath to 2 arrays of floats (that are passed to the "info" pointer
//it only works for path made from lines
void savePathToArraysApplierFunc (void *info,const CGPathElement *element){
    
    struct dataPointer* my_dataPointer = (struct dataPointer*) info;
    if(element->type != kCGPathElementCloseSubpath){
        my_dataPointer->indexx[my_dataPointer->numberOfPoints] = element->points[0].x;
        my_dataPointer->indexy[my_dataPointer->numberOfPoints] = element->points[0].y;
        my_dataPointer->numberOfPoints++;
    }
    else{
        my_dataPointer->isClosed = YES;
    }
    
}

//void  printarray (void *info,const CGPathElement *element){
//    
//    NSLog(@"%d %f %f",element->type,element->points[0].x,element->points[0].y);
//}


//accepts a line (closed or open path) in the form of CGpath (this method is just a wrapper)
//returns  a closed path (outline)  that surrounds the points of the given path 
+(CGMutablePathRef) newClosedPathWithWidth: (float) pw fromPath:(CGPathRef) path 
{
    //convert path to 2 arrays of floats
    struct dataPointer my_dataPointer; //this struct will hold the 2 indexes of the CGpath
    my_dataPointer.numberOfPoints = 0;
    my_dataPointer.isClosed = NO;
    CGPathApply(path, &my_dataPointer, savePathToArraysApplierFunc);
    
    //get the outline path and return it
     return [functions newClosedPathWithWidth:pw fromPointsWith_x:my_dataPointer.indexx and_y:my_dataPointer.indexy withLength: my_dataPointer.numberOfPoints whichIsClosed: my_dataPointer.isClosed];
    
}

//this function uses apple's implementation (CGContextReplacePathWithStrokedPath)
//accepts a line (closed or open path) in the form of CGpath 
//returns  a closed path (outline)  that surrounds the points of the given path 
+(CGPathRef) newPathFromStrokedPathWithWidth: (float) pw fromPath:(CGPathRef) path 
{
    //create an image context (we will not draw here but we'll just use some CGcontext functions on it)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0),YES,1.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(ctx, path);
    CGContextSetLineWidth(ctx, pw);
    CGContextSetLineJoin(ctx, kCGLineJoinMiter);
    
    //create the outline with this CG function
    CGContextReplacePathWithStrokedPath(ctx);
    CGPathRef outline_path_unmutable =  CGContextCopyPath(ctx);

    
    UIGraphicsEndImageContext();
    
    return outline_path_unmutable;

}



- (void)dealloc
{
    [super dealloc];
}

@end
