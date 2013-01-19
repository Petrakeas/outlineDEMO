//
//  functions.m
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CGutilities.h"
#import <Accelerate/Accelerate.h>


#pragma mark - smooth bezier funtions

void calculateBezierControlPoints( CGFloat* cpx, CGFloat* cpy, CGFloat* p_x, CGFloat* p_y, bool isClosed, int n, CGFloat t)
{/*calculates the control points needed to draw a bezier curve passing smoothly through the given points
  if the path is open:
    returns (n-2)*2+2 = 2*n-2 control points that can be used with the orignal points (point_x) (point_y)
    ex. if n=3 you have to supply 3 points: P0,P1,P2 (using points_x and points_y arrays). The 4 control points returned shoud be used in the following order so that they can be drawn: P0 CP0 CP1 P1 CP2 CP3 P2
  if the path is closed:
    returns 2*4 control points
  is is up to you to allocate space for the returned control points: cpx, cpy
  more info on the math part here: http://scaledinnovation.com/analytics/splines/aboutSplines.html
  */
    
    CGFloat len1,len2;
    CGFloat f1,f2;
    int k;
    
    CGFloat px[_max_points+2];
    CGFloat py[_max_points+2];
    CGFloat diff_x[_max_points];
    CGFloat diff_y[_max_points];
    CGFloat lengths[_max_points];
    
    //copy the input values to our CGFloat arrays
    if(isClosed == YES && n>2){
        //if the input path is closed, shift the input array by one and add as first element the last of the input and as last element the first of the input
        memcpy(px+1, p_x, sizeof(CGFloat)*n);
        px[0] = p_x[n-1];
        px[n+1] = p_x[0];
        memcpy(py+1, p_y, sizeof(CGFloat)*n);
        py[0] = p_y[n-1];
        py[n+1] = p_y[0];
        n+=2;//we will compute 2 more elements
        k=-2;
    }
    else{
        memcpy(px, p_x, sizeof(CGFloat)*n);
        memcpy(py, p_y, sizeof(CGFloat)*n);
        k=0;
        
        //the first and last control point we be calculated with a heuristic way because for proper calculation we would need a point before the first one and after the last one
        cpx[0]= px[0] + t *(px[1]-px[0]);//first control point
        cpy[0]= py[0] + t *(py[1]-py[0]);
        cpx[(n-2)*2+1]= px[n-1] - t *(px[n-1]-px[n-2]);//last control point
        cpy[(n-2)*2+1]= py[n-1] - t *(py[n-1]-py[n-2]);
        
    }
    
   
    
    //calculate the distances between the n points in batch mode (the non-batch mode is the commented  out  lines of len1,len2)
    CG_vsub(px,1,px+1,1,diff_x,1,n-1);//first caclulate the differences of x
    CG_vsub(py,1,py+1,1,diff_y,1,n-1);//then calculate the difference of y
    CG_vdist(diff_x, 1, diff_y, 1, lengths, 1, n-1);//take the square root of the sum of the squares of the differences
    
    for(int i=1 + (int)isClosed ; i<n-1; i++){//for all the points except the first and last one
        
        //        len1 = sqrtf(powf((px[i]-px[i-1]),2)+powf((py[i]-py[i-1]),2));//the distance of current point with the previous
        //        len2 = sqrtf(powf((px[i]-px[i+1]),2)+powf((py[i]-py[i+1]),2));//the distance of current point with the next
        len1 = lengths[i-1];
        len2 = lengths[i];
        f1 = ( t*len1/(len1+len2) );//scaling factor control point before current point
        f2 = t-f1;//scaling factor for the second control point after current point
            
        cpx[i*2-1 + k]  = px[i] - f1*(px[i+1]-px[i-1]);//calculate the x of the control point before current point
        cpy[i*2-1 + k]  = py[i] - f1*(py[i+1]-py[i-1]);//the same for y
        cpx[i*2 + k]    = px[i] + f2*(px[i+1]-px[i-1]);//calculate the x of the control point after current point
        cpy[i*2 + k]    = py[i] + f2*(py[i+1]-py[i-1]);//the same for y
    }
    if(isClosed){//we need one more iteration for the first "extra" point of closed paths
        int i = 1;
        len1 = lengths[i-1];
        len2 = lengths[i];
        f1 = ( t*len1/(len1+len2) );//scaling factor control point before current point
        f2 = t-f1;//scaling factor for the second control point after current point
        
        //the control point before the "first" point is the control point "after" the last point
        cpx[2*(n-2)-1] = px[i] - f1*(px[i+1]-px[i-1]);
        cpy[2*(n-2)-1] = py[i] - f1*(py[i+1]-py[i-1]);
        //the control point after the "first" point is the control point before the actual first point
        cpx[0] = px[i] + f2*(px[i+1]-px[i-1]);//calculate the x of the control point before current point
        cpy[0] = py[i] + f2*(py[i+1]-py[i-1]);//the same for y


    }

    
}


CGMutablePathRef CreateSmoothedBezierPathFromPath( CGPathRef path, CGFloat tention)
{
    //convert path to 2 arrays of CGFloats
    struct dataPointer my_dataPointer; //this struct will hold the 2 indexes of the CGpath
    my_dataPointer.numberOfPoints = 0;
    my_dataPointer.isClosed = NO;
    CGPathApply(path, &my_dataPointer, savePathToArraysApplierFunc);
    
    //the arrays where the control points will be stored
    CGFloat controlPoints_x[2*_max_points];
    CGFloat controlPoints_y[2*_max_points];
    
    calculateBezierControlPoints(  controlPoints_x, controlPoints_y, my_dataPointer.indexx , my_dataPointer.indexy, my_dataPointer.isClosed, my_dataPointer.numberOfPoints, tention);
    
    //the final CGpath constisting of original points and computed control points
    CGMutablePathRef bezierPath = CGPathCreateMutable();
    
    for (int i = 0; i<my_dataPointer.numberOfPoints + (int) my_dataPointer.isClosed; i++) 
    {
        if(i==0)
            CGPathMoveToPoint(bezierPath, nil, my_dataPointer.indexx[0], my_dataPointer.indexy[0]);
        else if (i==my_dataPointer.numberOfPoints) //this happens when the path is closed
            CGPathAddCurveToPoint(bezierPath, nil, controlPoints_x[i*2-2], controlPoints_y[i*2-2], controlPoints_x[i*2-1], controlPoints_y[i*2-1],my_dataPointer.indexx[0], my_dataPointer.indexy[0]);
        else
            CGPathAddCurveToPoint(bezierPath, nil, controlPoints_x[i*2-2], controlPoints_y[i*2-2], controlPoints_x[i*2-1], controlPoints_y[i*2-1],my_dataPointer.indexx[i], my_dataPointer.indexy[i]);
    }
    if(my_dataPointer.isClosed)
        CGPathCloseSubpath(bezierPath);

    return bezierPath;
    
}

#pragma mark - UIBezierPath category
////////////////////////////////////////UIBezierPath Category implementation//////////////////////////////////

@implementation UIBezierPath (smoothBezier)


-(UIBezierPath*) smoothedBezierPathWithTension: (CGFloat) tension{
    
    CGMutablePathRef smoothedCGPath = CreateSmoothedBezierPathFromPath(self.CGPath, tension);
    UIBezierPath* smoothedBezierPath = [UIBezierPath bezierPathWithCGPath:smoothedCGPath];
    CGPathRelease(smoothedCGPath);
    
    return smoothedBezierPath;
}

+(UIBezierPath*) smoothedBezierOutlinePathWithCGPath:(CGPathRef)path tension:(CGFloat) tension{
    
    CGMutablePathRef smoothedCGPath = CreateSmoothedBezierPathFromPath(path, tension);
    UIBezierPath* smoothedBezierPath = [UIBezierPath bezierPathWithCGPath:smoothedCGPath];
    CGPathRelease(smoothedCGPath);
    
    
    return smoothedBezierPath;
}

@end


