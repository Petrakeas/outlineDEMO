//
//  outlineDEMOAppDelegate.m
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "outlineDEMOAppDelegate.h"
#import "customrender.h"
#import <QuartzCore/CAAnimation.h>

@implementation outlineDEMOAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    //create a CALayer for shadow  effect
    CALayer* myShadowLayer = [[[CALayer alloc]init] autorelease];
    myShadowLayer.shadowOpacity = 0.5;
    myShadowLayer.shadowRadius = 7;
    myShadowLayer.shadowColor = [UIColor blackColor].CGColor;
    //myShadowLayer.shadowOffset = CGSizeMake(10, 10);
//    myShadowLayer.rasterizationScale = 0.5;
//    myShadowLayer.shouldRasterize = YES;
    [self.window.layer addSublayer:myShadowLayer];
    
    
    //create an instance of customrender and add it to the view
    myview = [[customrender alloc] init]; 
    
    myview.shadowlayer = myShadowLayer;

    [self.window.layer addSublayer:myview];
    
    
    [myview setNeedsDisplay];
    
    [self.window makeKeyAndVisible];
    
    
    
    //create an animation for the width of the outline in myview
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"linewidth"];
    animation.duration = 3;
    animation.fromValue = [NSNumber numberWithFloat:8.0];
    animation.toValue = [NSNumber numberWithFloat:40.0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    [myview addAnimation:animation forKey:@"animateLineWidth"];
    
    //create an animation for the angle of the second path
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"angle"];
    animation2.duration = 8;
    animation2.fromValue = [NSNumber numberWithFloat:0];
    animation2.toValue = [NSNumber numberWithFloat:6];
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation2.autoreverses = YES;
    animation2.repeatCount = HUGE_VALF;
    [myview addAnimation:animation2 forKey:@"animateangle"];
    
 
       //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(repeatFunction) userInfo:nil repeats:NO];
    
    
    return YES;
}

//- (void) repeatFunction {
//    NSLog(@"%f", [myview.linewidth floatValue]);
//}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{

    [myview release];
    [_window release];
    [super dealloc];
}

@end
