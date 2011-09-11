//
//  customrender.h
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class functions;


@interface customrender : CALayer {
    
    CGMutablePathRef path;
    CGMutablePathRef path2;
    CGMutablePathRef path3;

    

    NSNumber* linewidth;
    NSNumber* angle;
    
    functions* myFunctions;
 
}


@property (nonatomic,retain) NSNumber* linewidth;//this is the width for the outlines of the paths
@property (nonatomic,retain) NSNumber* angle;//this angle is used to rotate path2
@property (nonatomic,retain) CALayer* shadowlayer;//this is an external CALayer used for shadows


@end
