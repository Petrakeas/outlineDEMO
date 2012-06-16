//
//  DemoViewController.m
//  outlineDEMO
//
//  Created by Petros Douvantzis on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DemoViewController.h"
#import "customrender.h"
//#define forceFasterFps 1

@interface DemoViewController ()

@end

@implementation DemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //catch notifications to stop and resume animations
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(appBecameActive:) 
                                                     name: UIApplicationDidBecomeActiveNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(appResignedActive:) 
                                                     name: UIApplicationWillResignActiveNotification 
                                                   object:nil];
    }
    return self;
}

-(void) updateTention: (UISlider*) slider{
    myCustomRenderLayer.tension = slider.value;
}

- (void)loadView{
    const CGRect screenRect = [UIScreen mainScreen].applicationFrame;
    UIView *containerView = [[[UIView alloc] initWithFrame:screenRect] autorelease];
    
    //create a CALayer for shadow  effect
    CALayer* myShadowLayer = [[[CALayer alloc]init] autorelease];
    myShadowLayer.shadowOpacity = 0.5;
    myShadowLayer.shadowRadius = 7;
    myShadowLayer.shadowColor = [UIColor blackColor].CGColor;
    //myShadowLayer.shadowOffset = CGSizeMake(10, 10);
    //    myShadowLayer.rasterizationScale = 0.5;
    //    myShadowLayer.shouldRasterize = YES;
    [containerView.layer addSublayer:myShadowLayer];
    
    UISlider* slider = [[[UISlider alloc]initWithFrame: CGRectMake(200, 20, 90, 40)] autorelease];
    slider.value = 0.2;
    [slider addTarget:self action:@selector(updateTention:) forControlEvents:UIControlEventValueChanged];
    
    myCustomRenderLayer = [[[customrender alloc]init]autorelease];
    myCustomRenderLayer.shadowlayer = myShadowLayer;
    myCustomRenderLayer.tension = slider.value;
    [containerView.layer addSublayer:myCustomRenderLayer];
    
    
    [containerView addSubview:slider];
    


#ifdef forceFasterFps
    [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(ForceRedraw:) userInfo:myCustomRenderLayer repeats:YES];
#endif
    
    self.view = containerView;
}


-(void)ForceRedraw:(NSTimer*) _timer 
{
    customrender* renderInstance = (customrender*) _timer.userInfo;

    [renderInstance setNeedsDisplay];
}

- (void) appBecameActive: (NSNotification*) notification
{
    [myCustomRenderLayer removeAllAnimations];
    
    //create an animation for the width of the outline in myview
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"linewidth"];
    animation.duration = 3;
    animation.fromValue = [NSNumber numberWithFloat:8.0];
    animation.toValue = [NSNumber numberWithFloat:40.0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    [myCustomRenderLayer addAnimation:animation forKey:@"animateLineWidth"];
    
    //create an animation for the angle of the second path
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"angle"];
    animation2.duration = 8;
    animation2.fromValue = [NSNumber numberWithFloat:0];
    animation2.toValue = [NSNumber numberWithFloat:6];
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation2.autoreverses = YES;
    animation2.repeatCount = HUGE_VALF;
    [myCustomRenderLayer addAnimation:animation2 forKey:@"animateangle"];

}

- (void) appResignedActive: (NSNotification*) notification
{
    [myCustomRenderLayer removeAllAnimations];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
