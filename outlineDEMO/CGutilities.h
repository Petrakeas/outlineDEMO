//
//  functions.h
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/10/11.
//  Copyright 2012 evilwindowdog.com All rights reserved.
//

/*The following fucntions/methods can help in the creation of a path's outline and the calculation of the control points of a bezier curve
 The functions come in 3  flavours:

  1)UIbezier methods
  2)C functions that accept a CGPath as input (read about the limitations below)
  3)C functions that accept array of floats as input
 
 The functions have some restrictions in their usage detailed below.
 
 You can combine the functions as long as their restrictions are satisfied. For example:
 (ok):  open path -> outline-> smoothed
 
 (FAIL):  open path -> smoothed -> outline (because the smoothed path contains bezier curves)
 (ok):  open path -> smoothed -> outline_apple_version 
 
 (FAIL):  closed path -> outline -> smoothed (because the outline will consist of 2 subpaths)
 
 */

#import <Foundation/Foundation.h>
#define _max_points  512 //the maximum number of points the input path can have. I decided not to allocate memory dynamically for performance reasons


#pragma  mark - outline
///////////////////////////////Outline Creation///////////////////////////

/*
 The following functions/methods have 2 different implementations for the calculation of the outline: Apple's and mine
 
-The funtions that use Apple's implementaion have "stroke" in their name.
 They accept all kind of CGPaths, all the available values of CGLineJoin and CGLineCap
 Their drawback is that if you stroke the returned path, you'll notice the intersection of lines
 
-The rest of the functions (that use my implementation) are slightly faster and the returned path doesn't have inersections.
 The restrictions are:
 1)The CGPath or UIBezierPath should only have 1 subpath and it must be formed only by lines (not arcs etc)
 2)The following CGLineJoin are supported: kCGLineJoinBevel, kCGLineJoinMiter
 3)You can't alter the CGLineCap.
*/

//Creats and returns a new CGPath that is the ouline of the given path
CGMutablePathRef CreateOutlinePathFromPath( CGPathRef path, float width, CGLineJoin  joinType);

//Creates and returns a new CGPath that is the ouline of the given path (uses Apple's implementation)
CGPathRef CreateOutlinePathFromStrokedPath( CGPathRef path , float width, CGLineJoin joinType, CGLineCap capType );

//Creates and returns a new CGPath that is the ouline of the coordinates given
CGMutablePathRef CreateOutlinePath(  float* pixelx , float* pixely, int n , bool isClosed, float width, CGLineJoin  joinType);


@interface UIBezierPath (outline)

/* Creates and returns a new UiBezierPath object containing the outline of the receiver
 *The receiver must comply with the restrictions mentioned earlier */
-(UIBezierPath*) outlinePathWithWidth: (float) width lineJoin: (CGLineJoin) joinType;

/*Creates and returns a new UiBezierPath which is the outline of the supplied CGpath.
 *The input path must comply with the restrictions mentioned earlier */
+(UIBezierPath*) bezierOutlinePathWithCGPath:(CGPathRef)path width:(float) width lineJoin:(CGLineJoin) joinType;


// Creates and returns a new UiBezierPath object containing the outline of the receiver (uses Apple's implementation)
-(UIBezierPath*) strokedOutlinePathWithWidth:(float)width lineJoin:(CGLineJoin)joinType lineCap:(CGLineCap)lineCap;

//Creates and returns a new UiBezierPath which is the outline of the supplied CGpath (uses Apple's implementaion)
+(UIBezierPath*) bezierStrokedOutlinePathWithCGPath:(CGPathRef)path width:(float) width lineJoin:(CGLineJoin) joinType lineCap:(CGLineCap)lineCap;


@end


#pragma mark - smoothed bezier
///////////////////////////////Bezier Curve creation///////////////////////////

/*
 The following functions calculate the control points of the given path (open or closed) and creates a new smoothed path consisting of bezier curves.
 The only parameter is tension that takes positive/negative values. If you set it to zero, the result looks sharp. Good range of values is [0 1]

 The given path must comply with the following restriction:
 1)The CGPath or UIBezierPath should only have 1 subpath and it must be formed only by lines (not arcs, bezier etc)
*/


//Creates and returns a new CGPath that consists of bezier curves passing smoothly through the CGPath given
CGMutablePathRef CreateSmoothedBezierPathFromPath( CGPathRef path, float tention);

@interface UIBezierPath (smoothBezier)

/* Creates and returns a new UiBezierPath object containing the smoothed bezier version of the receiver
 *The receiver must comply with the restrictions mentioned earlier */
-(UIBezierPath*) smoothedBezierPathWithTension: (float) tension;

/*Creates and returns a new UiBezierPath object which is a smoothed bezier version of the supplied CGpath.
 *The input path must comply with the restrictions mentioned earlier */
+(UIBezierPath*) smoothedBezierOutlinePathWithCGPath:(CGPathRef)path tension:(float) tension;
@end


struct dataPointer  
{
    float indexx[_max_points];
    float indexy[_max_points];
    int numberOfPoints;
    bool isClosed;
};

#pragma mark - utilities
//////////////////////////Utilities////////////////////

/*prints the values of a CGPath on console
 prints only the first point of a CGPathElement
 */
void printCGPath(CGPathRef path);

//CGpath applier function that converts the cgpath to 2 arrays of floats (that are passed to the "info" pointer
//it only works for path made from lines (not curves)
void savePathToArraysApplierFunc (void *info,const CGPathElement *element);
