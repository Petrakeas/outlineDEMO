//
//  outlineDEMOAppDelegate.h
//  outlineDEMO
//
//  Created by Petros Douvantzis on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class customrender;

@interface outlineDEMOAppDelegate : NSObject <UIApplicationDelegate> {
    
    customrender* myview;


}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
