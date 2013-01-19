//
//  customrender.m
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "customrender.h"
#import "CGutilities.h"

//#define _appleImplementation 1

#if CGFLOAT_IS_DOUBLE
# define CGFloatValue	doubleValue
#else
# define CGFloatValue	floatValue
#endif

@implementation customrender

@synthesize linewidth,angle,shadowlayer, tension;//this is the property that we will animate

//these are the variables that need to be set again for the presentation version of the CAlayer
-(void)createPaths
{
   
    //create an open path (up z)
    path1 = CGPathCreateMutable();
    CGPathMoveToPoint(path1, nil, 30, 130);
    CGPathAddLineToPoint(path1, nil, 70, 30);
    CGPathAddLineToPoint(path1, nil, 120, 200);
    CGPathAddLineToPoint(path1, nil, 200, 120);

    
    //create a closed path (rectangle)
    path2 = CGPathCreateMutable();
    CGPathMoveToPoint(path2, nil, -50, 50);
    CGPathAddLineToPoint(path2, nil, 50, 50);
    CGPathAddLineToPoint(path2, nil, 50, -50);
    CGPathAddLineToPoint(path2, nil, -50, -50);
    CGPathCloseSubpath(path2);
    
    //create an open path (down Z)
    path3 = CGPathCreateMutable();
    CGPathMoveToPoint(path3, nil, 0, 100);
    CGPathAddLineToPoint(path3, nil, 100, 100);
    CGPathAddLineToPoint(path3, nil, 0 , 200);
    CGPathAddLineToPoint(path3, nil, 130, 200);
    
    //create a closed path (triangle)  
    CGAffineTransform trans = CGAffineTransformMakeTranslation(-50, -100 +  50.0*tanf(M_PI * 30.0/180.0));
    path5 = CGPathCreateMutable();
    CGPathMoveToPoint(path5, &trans, 0, 100);
    CGPathAddLineToPoint(path5, &trans, 100, 100);
    CGPathAddLineToPoint(path5, &trans, 50, 100 - 100.0*sinf(M_PI * 60.0/180.0));
    CGPathCloseSubpath(path5);


    
}

- (id)init
{
    self = [super init];
    if (self) {
        
        // Initialization code
        self.frame = [[UIScreen mainScreen] bounds];
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.opaque = NO;
        
        if ([self respondsToSelector:@selector(setContentsScale:)])
        {
            self.contentsScale = [[UIScreen mainScreen] scale]; //= 1;
        }
        
        //set our propertis
        self.linewidth = [NSNumber numberWithFloat:20];//initial value
        
        self.angle = [NSNumber numberWithFloat:1];
  
        [self createPaths];

    }
    return self;
}

//overide contructor because CAanimation uses this to create presentation layers from the model layer
- (id) initWithLayer:(id)layer {

    customrender* modelLayer = (customrender*) layer;
    
    self = [super initWithLayer:layer];
    
    if(self) {//copy the properties from model layer to presentation layer
        
        self.shadowlayer = modelLayer.shadowlayer;
        self.linewidth = modelLayer.linewidth;
        self.angle = modelLayer.angle;
        self.tension = modelLayer.tension;

        [self createPaths];        
    }
    
    return self;
    
}



//we overide drawInContext to perfom our custom rendering
- (void)drawInContext:(CGContextRef)ctx
{
    CGFloat _tension = self.tension;
    
    //create one more path
    CGFloat _angle = [self.angle CGFloatValue];
    CGMutablePathRef path4 = CGPathCreateMutable();
    CGPathMoveToPoint(path4, nil, 150, 100 + 40 * sinf(_angle));
    CGPathAddLineToPoint(path4, nil, 200, 100 + 40 * sinf(_angle +     M_PI_2));
    CGPathAddLineToPoint(path4, nil, 250, 100 + 40 * sinf(_angle + 2 * M_PI_2));
    CGPathAddLineToPoint(path4, nil, 300, 100 + 40 * sinf(_angle + 3 * M_PI_2 ));
    
    
    
    //convert CGPaths to UIBezierPaths for convenience
    UIBezierPath* uipath1 = [UIBezierPath bezierPathWithCGPath:path1];
    UIBezierPath* uipath2 = [UIBezierPath bezierPathWithCGPath:path2];
    UIBezierPath* uipath3 = [UIBezierPath bezierPathWithCGPath:path3];
    UIBezierPath* uipath4 = [UIBezierPath bezierPathWithCGPath:path4];
    UIBezierPath* uipath5 = [UIBezierPath bezierPathWithCGPath:path5];
    CGPathRelease(path4);
    
    
    //make 1st and 4th path "smoothed"
    UIBezierPath* smoothedPath1 = [uipath1 smoothedBezierPathWithTension:_tension];
    UIBezierPath* smoothedPath4 = [uipath4 smoothedBezierPathWithTension:2*_tension];
    
    //rotate and translate path2
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeRotation([self.angle CGFloatValue]), CGAffineTransformMakeTranslation(100, 300));
    [uipath2 applyTransform:transform];
    
    //translate path3
    transform = CGAffineTransformMakeTranslation(150, 250);
    [uipath3 applyTransform:transform];
    
    //rotate and translate path5
    CGAffineTransform transform2 = CGAffineTransformConcat(CGAffineTransformMakeRotation([self.angle CGFloatValue]), CGAffineTransformMakeTranslation(250, 200));
    [uipath5 applyTransform:transform2];


    
    // Draw  the paths
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 3);
    
    CGContextAddPath(ctx, smoothedPath1.CGPath);
    CGContextAddPath(ctx, uipath2.CGPath);
    CGContextAddPath(ctx, uipath3.CGPath);
    CGContextDrawPath(ctx,kCGPathStroke);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(ctx, 2);
    
    CGContextAddPath(ctx, smoothedPath4.CGPath);
    CGContextAddPath(ctx, [uipath5 smoothedBezierPathWithTension:_tension].CGPath);
    CGContextDrawPath(ctx,kCGPathStroke);
    
    
    //compute the outlines of the original paths
    #ifdef _appleImplementation
    UIBezierPath*   outline1 = [smoothedPath1 strokedOutlinePathWithWidth:[linewidth CGFloatValue] lineJoin:kCGLineJoinMiter lineCap:kCGLineCapRound];
    #else
    UIBezierPath*   outline1 = [[uipath1 outlinePathWithWidth:[linewidth CGFloatValue] lineJoin:kCGLineJoinMiter] smoothedBezierPathWithTension:_tension];
    #endif

    UIBezierPath*   outline2 = [uipath2 outlinePathWithWidth:[linewidth CGFloatValue] lineJoin:kCGLineJoinMiter];
    UIBezierPath*   outline3 = [uipath3 outlinePathWithWidth:[linewidth CGFloatValue] lineJoin:kCGLineJoinMiter];
 
    
    //Draw the outline paths
    CGContextSetLineWidth(ctx, 3);
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    
    CGContextAddPath(ctx, outline1.CGPath);
    CGContextAddPath(ctx, outline2.CGPath);
    CGContextDrawPath(ctx,kCGPathStroke);
    
    //Draw outline3 as shadow
    self.shadowlayer.shadowPath = outline3.CGPath;
    

}

//we overide this class function of CAlayer so that changing the value of "linewidth" triggers the use of "drawInContext" to show the changes in the view
+ (BOOL) needsDisplayForKey:(NSString*)key{
    if([key isEqualToString:@"linewidth"] || [key isEqualToString:@"angle"])
        return YES;
    else{
        return [super needsDisplayForKey:key];
    }
}


- (void)dealloc
{
    CGPathRelease(path1);
    CGPathRelease(path2);
    CGPathRelease(path3);
    CGPathRelease(path5);
    self.linewidth = nil;
    self.angle = nil;
    self.shadowlayer = nil;
    [super dealloc];
}

@end
