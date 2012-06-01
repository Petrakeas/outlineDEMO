//
//  outlineDEMOAppDelegate.h
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemoViewController;

@interface outlineDEMOAppDelegate : NSObject <UIApplicationDelegate> {
    
    DemoViewController* dvc;


}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
