//
//  nowplayingAppDelegate.h
//  nowplaying
//
//  Created by プー坊 on 11/09/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class nowplayingViewController;

@interface nowplayingAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet nowplayingViewController *viewController;

@end
