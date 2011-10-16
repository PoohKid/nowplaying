//
//  nowplayingViewController.h
//  nowplaying
//
//  Created by プー坊 on 11/09/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConfigViewController.h"

@class MultiADBannerView;

@interface nowplayingViewController : UIViewController <UITextViewDelegate, ConfigViewControllerDelegate> {
    NSDictionary *twitterApplication_;

    IBOutlet UITextView *textView;
    IBOutlet UIView *operationPanel;
    IBOutlet UILabel *restLabel;
    IBOutlet UIButton *tweetButton;

    IBOutlet MultiADBannerView *adBannerView;

    CGFloat originalTextViewHeight_;
    CGFloat originalOperationPanelTop_;
}

- (void)setNowPlaying;

- (IBAction)tapSettingButton:(id)sender;
- (IBAction)tapReloadButton:(id)sender;
- (IBAction)tapCopyButton:(id)sender;
- (IBAction)tapTweetButton:(id)sender;

@end
