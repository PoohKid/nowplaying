//
//  ConfigViewController.h
//  nowplaying
//
//  Created by プー坊 on 11/09/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfigViewControllerDelegate;

@interface ConfigViewController : UITableViewController {
    id<ConfigViewControllerDelegate> delegate;
    NSArray *twitterApplications_;
    NSString *chooseApplication_;
    IBOutlet UIBarButtonItem *doneButton;
}

@property (nonatomic, assign) id<ConfigViewControllerDelegate> delegate;

- (IBAction)tapDoneButton:(id)sender;

@end

@protocol ConfigViewControllerDelegate <NSObject>

- (void)didChooseApplication;

@end
