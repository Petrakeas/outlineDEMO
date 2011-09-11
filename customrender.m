//
//  customrender.m
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "customrender.h"
#import "functions.h"


@implementation customrender

@synthesize linewidth,angle,shadowlayer;//this is the property that we will animate

//these are the variables that need to be set again for the presentation version of the CAlayer
-(void)createPaths
{
   
    //create an open path
 
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 30, 130);
    CGPathAddLineToPoint(path, nil, 70, 30);
    CGPathAddLineToPoint(path, nil, 120, 200);
    CGPathAddLineToPoint(path, nil, 200, 120);
    
    //create a closed path
    path2 = CGPathCreateMutable();
    CGPathMoveToPoint(path2, nil, -50, 50);
    CGPathAddLineToPoint(path2, nil, 50, 50);
    CGPathAddLineToPoint(path2, nil, 50, -50);
    CGPathAddLineToPoint(path2, nil, -50, -50);
    CGPathCloseSubpath(path2);
    
    //create an open path
    path3 = CGPathCreateMutable();
    CGPathMoveToPoint(path3, nil, 0, 100);
    CGPathAddLineToPoint(path3, nil, 100, 100);
    CGPathAddLineToPoint(path3, nil, 0 , 200);
    CGPathAddLineToPoint(path3, nil, 130, 200);
    
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
        
        [self createPaths];        
    }
    
    return self;
    
}



//we overide drawInContext to perfom our custom rendering
- (void)drawInContext:(CGContextRef)ctx
{
    //NSLog(@"RENDERING %f", [linewidth floatValue]);
    
   //rotate and translate path2
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeRotation([self.angle floatValue]), CGAffineTransformMakeTranslation(100, 300)); 
    UIBezierPath* uipath2 = [UIBezierPath bezierPathWithCGPath:path2];
    [uipath2 applyTransform:transform];
    
    //translate path3
    transform = CGAffineTransformMakeTranslation(150, 250);
    UIBezierPath* uipath3 = [UIBezierPath bezierPathWithCGPath:path3];
    [uipath3 applyTransform:transform];
    


    //Draw settings for the original paths
    CGContextSetLineWidth(ctx, 2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 3);
    
    // Draw  the paths
    CGContextAddPath(ctx, path);
    CGContextAddPath(ctx, uipath2.CGPath);
    CGContextAddPath(ctx, uipath3.CGPath);
    CGContextDrawPath(ctx,kCGPathStroke);
    
    //compute the outline of the original paths
    CGMutablePathRef outline = [functions newClosedPathWithWidth:[linewidth floatValue] fromPath:path];
    CGMutablePathRef outline2 = [functions newClosedPathWithWidth:[linewidth floatValue] fromPath:uipath2.CGPath];
    CGMutablePathRef outline3 = [functions newClosedPathWithWidth:[linewidth floatValue] fromPath:uipath3.CGPath];
    
    //Draw settings for the outline paths
    CGContextSetLineWidth(ctx, 3);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    
    //Draw the outline paths
    CGContextAddPath(ctx, outline);
    CGContextAddPath(ctx, outline2);
    CGContextDrawPath(ctx,kCGPathStroke);
    
    //draw outline3 as shadow
    self.shadowlayer.shadowPath = outline3;
    
    CGPathRelease(outline);
    CGPathRelease(outline2);
    CGPathRelease(outline3);

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
    CGPathRelease(path);
    CGPathRelease(path2);
    CGPathRelease(path3);
    self.linewidth = nil;
    self.angle = nil;
    self.shadowlayer = nil;
    [super dealloc];
}

@end
