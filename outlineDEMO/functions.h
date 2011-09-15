//
//  functions.h
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface functions : NSObject {
    
    
    
}

//we declare the methods as class methods so that we can use them easilly without the need to alloc an instance of the class "functions"



//accepts a line (closed or open path) in the form of CGpath (this method is just a wrapper)
//returns  a closed path (outline)  that surrounds the points of the given path 
+(CGMutablePathRef) newClosedPathWithWidth: (float) pw fromPath:(CGPathRef) path;

//same as above but it uses apple's implementation
//if you fill the returned path you'll get the same result as with my function, but if you stroke it you'll get a less desirable result
+(CGPathRef) newPathFromStrokedPathWithWidth: (float) pw fromPath:(CGPathRef) path;


//accepts a line (closed or open path) in the form of 2 float arrays
//returns  a closed path (outline)  that surrounds the points of the given path 
+(CGMutablePathRef) newClosedPathWithWidth: (float) pw fromPointsWith_x: (float*)pixelx and_y: (float*)pixely withLength: (int) n whichIsClosed:(bool) isClosed;






//IMPORTANT: you are responsible for releasing the returned path (watch the implementation in customrender.m)


@end
