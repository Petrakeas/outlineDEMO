//
//  functions.m
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CGutilities.h"
#import <Accelerate/Accelerate.h>


#pragma mark - utilities

//this is a CGpath applier function that converts the cgpath to 2 arrays of CGFloats (that are passed to the "info" pointer
//it only works for path made from lines (not curves)
void savePathToArraysApplierFunc (void *info,const CGPathElement *element){
    
    struct dataPointer* my_dataPointer = (struct dataPointer*) info;
    switch (element->type) {
        case kCGPathElementMoveToPoint:

        case kCGPathElementAddLineToPoint:
            
            my_dataPointer->indexx[my_dataPointer->numberOfPoints] = element->points[0].x;
            my_dataPointer->indexy[my_dataPointer->numberOfPoints] = element->points[0].y;
            my_dataPointer->numberOfPoints++;
            break;
        case kCGPathElementCloseSubpath:
            
            my_dataPointer->isClosed = YES;
            break;
            
        default:
            break;
    }
       
}

void  printCGPathApplier (void *info,const CGPathElement *element){
    
    NSLog(@"%d %f %f",element->type,element->points[0].x,element->points[0].y);
}

void printCGPath(CGPathRef path){
    CGPathApply(path, nil, printCGPathApplier);
}

#pragma mark - outline path functions

//accepts a line (closed or open path) in the form of 2 CGFloat arrays
//returns  a closed path (outline)  that surrounds the points of the given path 
CGMutablePathRef CreateOutlinePath(CGFloat* pixelx, CGFloat* pixely, int n, bool isClosed, CGFloat width, CGLineJoin joinType)
{
    if(n<2 || joinType == kCGLineJoinRound){
        return nil;
    }
    
    width = width/2;
    
    
    CGFloat cpUx [_max_points*2];//the points for the outer part of the outline
    CGFloat cpUy [_max_points*2];
    CGFloat cpDx [_max_points*2];//the points for the inner part of the outline
    CGFloat cpDy [_max_points*2];
    
    CGFloat px[_max_points+2];
    CGFloat py[_max_points+2];
    CGFloat diffx[_max_points+2];
    CGFloat diffy[_max_points+2];
    CGFloat lengths[_max_points+2];
    CGFloat normalx[_max_points+2];//the  unitary vectors perpendicular to the lines that form the original path
    CGFloat normaly[_max_points+2];
    CGFloat vectorx[_max_points+2];//the vectors that are formed by 2 normals
    CGFloat vectory[_max_points+2];
    
    CGFloat dot[_max_points];
    CGFloat scalar = 1;
    int k;

    //copy the input values to our CGFloat arrays
    if(isClosed == YES && n>2){
        //if the input path is closed, shift the input array by one and add as first element the last of the input and as last element the first of the input
        memcpy(px+1, pixelx, sizeof(CGFloat)*n);
        px[0] = pixelx[n-1];
        px[n+1] = pixelx[0];
        memcpy(py+1, pixely, sizeof(CGFloat)*n);
        py[0] = pixely[n-1];
        py[n+1] = pixely[0];
        n+=2;//we will compute 2 more elements
        k=1;
    }
    else{
        memcpy(px, pixelx, sizeof(CGFloat)*n);
        memcpy(py, pixely, sizeof(CGFloat)*n);
        k=0;

    }
    
    //compute normals
    CG_vsub(px,1,px+1,1,diffx+1,1,n-1); // compute the differences of the points in pairs
    CG_vsub(py,1,py+1,1,diffy+1,1,n-1);
    CG_vdist(diffx+1, 1, diffy+1, 1, lengths+1, 1, n-1); // take the square root of the sum of the squares of the differences (length)
    CG_vdiv(lengths+1, 1,diffx+1 , 1, normaly+1, 1, n-1); // divide the differences with their length to get the normal vectors
    CG_vdiv(lengths+1, 1, diffy+1, 1, normalx+1, 1, n-1); 
    CG_vneg(normalx+1, 1, normalx+1, 1, n-1);
    
    //compute the first and last vectors for open paths (don't need to do that for closed paths)
    if(isClosed==NO || n<=2){
        vectorx[0] = normalx[1];
        vectory[0] = normaly[1];
        vectorx[n-1] = normalx[n-1];
        vectory[n-1] = normaly[n-1];
        if (joinType == kCGLineJoinBevel) {
            vectorx[n] = normalx[n-1];
            vectory[n] = normaly[n-1];
        }
        
    }
    
    //compute the vectors for the line joins
    if(n>2){//we need at least 3 points to have a join
        
        
        switch (joinType) {
            case kCGLineJoinMiter:
                
                CG_vadd(normalx+1, 1, normalx+2, 1, vectorx+1, 1, n-2);//add the normal vectors in pairs of 2 to get the final vectors (they will be scaled)
                CG_vadd(normaly+1, 1, normaly+2, 1, vectory+1, 1, n-2);
                
                //scale the vectors (proven mathematically)
                CG_vmma(normalx+1, 1, normalx+2, 1, normaly+1, 1, normaly+2, 1, dot+1, 1, n-2);//calculates the dot products of the pairs of normal vectors
                CG_vsadd(dot+1, 1, &scalar, dot+1, 1, n-2);//add 1
                
                CG_vdiv(dot+1, 1, vectorx+1, 1, vectorx+1, 1, n-2);//scale the vectors by dividing them with their scaling factors
                CG_vdiv(dot+1, 1, vectory+1, 1, vectory+1, 1, n-2);
                
                
                break;
                
            case kCGLineJoinBevel:
                
                memcpy(vectorx+1, normalx+1, sizeof(CGFloat)*(n-1));
                memcpy(vectory+1, normaly+1, sizeof(CGFloat)*(n-1));
                break;
                
            default:
                return nil;
                break;
        }
        
        
    }

    if(isClosed == YES && n>2){
        n=n-2;
    }
    CG_vsmul(vectorx+k, 1, &width, vectorx+k, 1, n+1);//multiply the vectors so that we get the width we want
    CG_vsmul(vectory+k, 1, &width, vectory+k, 1, n+1);
    switch (joinType) {
        case kCGLineJoinMiter:
            //add the vectors to their points to get the upper section of the outline
            CG_vadd(vectorx+k, 1, px+k, 1, cpUx, 1, n);
            CG_vadd(vectory+k, 1, py+k, 1, cpUy, 1, n);
            //compute the vertical normals
            CG_vneg(vectorx+k, 1, vectorx+k, 1, n);
            CG_vneg(vectory+k, 1, vectory+k, 1, n);
            //add the vectors to their points to get the down section of the outline
            CG_vadd(vectorx+k, 1, px+k, 1, cpDx, 1, n);
            CG_vadd(vectory+k, 1, py+k, 1, cpDy, 1, n);
            break;
        
        case kCGLineJoinBevel:
            
            //add the vectors to their points to get the upper section of the outline
            CG_vadd(vectorx+k, 1, px+k, 1, cpUx, 2, n); 
            CG_vadd(vectorx+k+1, 1, px+k, 1, cpUx+1, 2, n);//each vector is added in 2 points
            CG_vadd(vectory+k, 1, py+k, 1, cpUy, 2, n); 
            CG_vadd(vectory+k+1, 1, py+k, 1, cpUy+1, 2, n);//each vector is added in 2 points
            //compute the vertical normals
            CG_vneg(vectorx+k, 1, vectorx+k, 1, n+1);
            CG_vneg(vectory+k, 1, vectory+k, 1, n+1);
            //add the vectors to their points to get the down section of the outline
            CG_vadd(vectorx+k, 1, px+k, 1, cpDx, 2, n);
            CG_vadd(vectorx+k+1, 1, px+k, 1, cpDx+1, 2, n);//each vector is added in 2 points
            CG_vadd(vectory+k, 1, py+k, 1, cpDy, 2, n);
            CG_vadd(vectory+k+1, 1, py+k, 1, cpDy+1, 2, n);//each vector is added in 2 points
            n = n*2;
            break;
        
        default:
            return nil;
            break;
    }
    
    
    //-----------create the resulting cgpath--------------
    CGMutablePathRef outline_path = CGPathCreateMutable();
    
    //add the points of the outer part of the ouline
    for(int i=0; i<n; i++){
        //NSLog(@"ux:%f uy:%f dx:%f dy:%f",cpUx[i],cpUy[i],cpDx[i],cpDy[i]);
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




CGMutablePathRef CreateOutlinePathFromPath( CGPathRef path, CGFloat width, CGLineJoin  joinType)
{
    //convert path to 2 arrays of CGFloats
    struct dataPointer my_dataPointer; //this struct will hold the 2 indexes of the CGpath
    my_dataPointer.numberOfPoints = 0;
    my_dataPointer.isClosed = NO;
    CGPathApply(path, &my_dataPointer, savePathToArraysApplierFunc);
    

     return CreateOutlinePath( my_dataPointer.indexx , my_dataPointer.indexy , my_dataPointer.numberOfPoints, my_dataPointer.isClosed, width, joinType);
    
}


CGPathRef CreateOutlinePathFromStrokedPath( CGPathRef path, CGFloat width, CGLineJoin joinType, CGLineCap capType )
{
    //create an image context (we will not draw here but we'll just use some CGcontext functions on it)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0),YES,1.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(ctx, path);
    CGContextSetLineWidth(ctx, width);
    CGContextSetLineJoin(ctx, joinType);
    CGContextSetLineCap(ctx, capType);
    
    //create the outline with this CG function
    CGContextReplacePathWithStrokedPath(ctx);
    CGPathRef outline_path_unmutable =  CGContextCopyPath(ctx);

    
    UIGraphicsEndImageContext();
    
    return outline_path_unmutable;

}
#pragma mark - UIBezierPath category
////////////////////////////////////////UIBezierPath Category implementation//////////////////////////////////

@implementation UIBezierPath (outline)

-(UIBezierPath*) outlinePathWithWidth: (CGFloat) width lineJoin: (CGLineJoin) joinType{
    
    CGMutablePathRef outlineCGPath = CreateOutlinePathFromPath(self.CGPath, width, joinType);
    UIBezierPath* outlineBezierPath = [UIBezierPath bezierPathWithCGPath:outlineCGPath];
    CGPathRelease(outlineCGPath);
    
    return outlineBezierPath;
}

+(UIBezierPath*) bezierOutlinePathWithCGPath:(CGPathRef)path width:(CGFloat) width lineJoin:(CGLineJoin) joinType{
    
    CGMutablePathRef outlineCGPath = CreateOutlinePathFromPath(path, width, joinType);
    UIBezierPath* outlineBezierPath = [UIBezierPath bezierPathWithCGPath:outlineCGPath];
    CGPathRelease(outlineCGPath);
    
    return outlineBezierPath;
}


-(UIBezierPath*) strokedOutlinePathWithWidth:(CGFloat)width lineJoin:(CGLineJoin)joinType lineCap:(CGLineCap)lineCap{
    
    CGPathRef outlineCGPath = CreateOutlinePathFromStrokedPath(self.CGPath, width, joinType, lineCap);
    UIBezierPath* outlineBezierPath = [UIBezierPath bezierPathWithCGPath:outlineCGPath];
    CGPathRelease(outlineCGPath);
    
    return outlineBezierPath;
}

+(UIBezierPath*) bezierStrokedOutlinePathWithCGPath:(CGPathRef)path width:(CGFloat) width lineJoin:(CGLineJoin) joinType lineCap:(CGLineCap)lineCap{
    
    CGPathRef outlineCGPath = CreateOutlinePathFromStrokedPath(path, width, joinType, lineCap);
    UIBezierPath* outlineBezierPath = [UIBezierPath bezierPathWithCGPath:outlineCGPath];
    CGPathRelease(outlineCGPath);
    
    return outlineBezierPath;
    
}

@end


