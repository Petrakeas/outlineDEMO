//
//  functions.h
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/10/11.
//  Copyright 2012 evilwindowdog.com All rights reserved.
//

/*The following fucntions/methods can help in the creation of a path's outline and the calculation of the control points of a bezier curve
 The functions come in 3  flavours:
 1)C functions that accept array of floats as input
 2)C functions that accept a CGPath as input (read about the limitations below)
 3)UIbezier methods
 The later ones are just wrappers, created for convenience.
 */

#import <Foundation/Foundation.h>
#define _max_points  512 //the maximum number of points the input path can have. I decided not to allocate memory dynamically for performance reasons


//////////////////////////Utilities////////////////////

//prints the values of a CGPath on console
//prints only the first point of a CGPathElement
void printCGPath(CGPathRef path);


///////////////////////////////Outline Creation///////////////////////////

/*The following functions/methods have 2 different implementations for the calculation of the outline: Apple's and mine
 
*The funtions that use Apple's implementaion have "stroke" in their name.
 They accept all kind of CGPaths, all the available values of CGLineJoin and CGLineCap
 Their drawback is that if you stroke the returned path, you'll notice the intersection of lines
 
*The rest of the functions (that use my implementation) are slightly faster and the returned path doesn't have inersections.
 The restrictions are:
 The CGPath or UIBezierPath should only have 1 subpath and it must be formed only by lines (not arcs etc)
 The following CGLineJoin are supported: kCGLineJoinBevel, kCGLineJoinMiter
 You can't alter the CGLineCap.
*/

//Creats and returns a new CGPath that is the ouline of the given path
CGMutablePathRef CreateOutlinePathFromPath( CGPathRef path, float width, CGLineJoin  joinType);


//Creats and returns a new CGPath that is the ouline of the given path (uses Apple's implementation)
CGPathRef CreateOutlinePathFromStrokedPath( CGPathRef path , float width, CGLineJoin joinType, CGLineCap capType );


//Creats and returns a new CGPath that is the ouline of the coordinates given
CGMutablePathRef CreateOutlinePath(  float* pixelx , float* pixely, int n , bool isClosed, float width, CGLineJoin  joinType);


@interface UIBezierPath (additions)


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





