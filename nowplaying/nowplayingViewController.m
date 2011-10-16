//
//  nowplayingViewController.m
//  nowplaying
//
//  Created by プー坊 on 11/09/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "nowplayingViewController.h"
#import "MultiADBannerView.h"

@interface nowplayingViewController ()
- (void)setTwitterApplication;
@end

@implementation nowplayingViewController

- (void)dealloc
{
    [twitterApplication_ release], twitterApplication_ = nil;

    textView.delegate = nil;
    [textView release];
    [operationPanel release];
    [restLabel release];
    [tweetButton release];

    [adBannerView release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    GA_TRACK_CLASS

    textView.delegate = self;

    //iPodで再生中の楽曲情報を取得
    [self setNowPlaying];

    //TwitterApplication選択
    [self setTwitterApplication];

    //textViewのオリジナルの高さとoperationPanelの位置を保存
    originalTextViewHeight_ = textView.frame.size.height;
    originalOperationPanelTop_ = operationPanel.frame.origin.y;

    //広告初期化
    [adBannerView initBannerWithTitle:@"#nowplaying" rootViewContoller:self];
}

- (void)viewDidUnload
{
    [twitterApplication_ release], twitterApplication_ = nil;

    textView.delegate = nil;
    [textView release], textView = nil;
    [operationPanel release], operationPanel = nil;
    [restLabel release], restLabel = nil;
    [tweetButton release], tweetButton = nil;

    [adBannerView release], adBannerView = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //キーボード表示・非表示の通知の開始
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //キーボード表示
    [textView becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{    
    //キーボード表示・非表示の通知を終了
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - private methods

- (void)setTwitterApplication
{
    [twitterApplication_ release], twitterApplication_ = nil;

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TwitterApplications" ofType:@"plist"];
    NSArray *twitterApplications = [[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"Root"];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *chooseApplication = [userDefaults stringForKey:@"ChooseApplication"];

    for (NSDictionary *twitterApplication in twitterApplications) {
        if ([chooseApplication isEqualToString:[twitterApplication objectForKey:@"ApplicationId"]]) {
            twitterApplication_ = [twitterApplication retain];
            break;
        }
    }

    if (twitterApplication_) {
        tweetButton.enabled = YES;
    } else {
        tweetButton.enabled = NO;
    }
}

#pragma mark - public methods

- (void)setNowPlaying
{
    MPMediaItem *mediaItem = [MPMusicPlayerController iPodMusicPlayer].nowPlayingItem;
    if (mediaItem) {
        textView.text = [NSString stringWithFormat:@"#nowplaying %@ - %@",
                         [mediaItem valueForProperty:MPMediaItemPropertyTitle],
                         [mediaItem valueForProperty:MPMediaItemPropertyArtist]];
    } else {
        textView.text = [NSString stringWithFormat:@"#nowplaying is nothing"];
    }
    restLabel.text = [NSString stringWithFormat:@"%d", 140 - [textView.text length]];
}

#pragma mark - IBAction

- (IBAction)tapSettingButton:(id)sender
{
    ConfigViewController *configViewController = [[ConfigViewController alloc] initWithNibName:@"ConfigViewController" bundle:nil];
    configViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:configViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [configViewController release];
}

- (IBAction)tapReloadButton:(id)sender
{
    GA_TRACK_METHOD

    [self setNowPlaying];
}

- (IBAction)tapCopyButton:(id)sender
{
    GA_TRACK_METHOD

    [[UIPasteboard generalPasteboard] setValue:textView.text forPasteboardType:@"public.utf8-plain-text"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"nowplaying"
                                                        message:@"Copied!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (IBAction)tapTweetButton:(id)sender
{
    if (twitterApplication_ == nil) {
        //ボタンを押せない制御をしているので論理的にはここには入らない
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"nowplaying"
                                                            message:@"No selection Twitter application."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }

    GA_TRACK_EVENT(NSStringFromClass([self class]),  NSStringFromSelector(_cmd), [twitterApplication_ objectForKey:@"ApplicationId"], -1);

    //TwitterクライアントにURLスキームを送る
    NSString *status = [((NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                            (CFStringRef)textView.text,
                                                                            NULL,
                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                            kCFStringEncodingUTF8)) autorelease];
    NSString* url = [NSString stringWithFormat:[twitterApplication_ objectForKey:@"URLScheme"], status];
    //NSLog(@"URL: %@", url);
    NSURL* twitterUrl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:twitterUrl]) {
        [[UIApplication sharedApplication] openURL:twitterUrl];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"nowplaying"
                                                            message:@"Can not open Twitter application."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

#pragma mark - ConfigViewControllerDelegate

- (void)didChooseApplication
{
    [self setTwitterApplication];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)aTextView
{
    restLabel.text = [NSString stringWithFormat:@"%d", 140 - [aTextView.text length]];
}

#pragma mark - UIKeyboardNotification

//キーボードが表示された場合
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //キーボードのCGRectを取得
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //キーボードのanimationDurationを取得
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    //textViewの高さとoperationPanelの位置を調整
    CGRect textFrame = textView.frame;
    textFrame.size.height = originalTextViewHeight_ - keyboardRect.size.height;
    CGRect panelFrame = operationPanel.frame;
    panelFrame.origin.y = originalOperationPanelTop_ - keyboardRect.size.height;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         textView.frame = textFrame;
                         operationPanel.frame = panelFrame;
                     }];
}

//キーボードが非表示にされた場合
- (void)keyboardWillHide:(NSNotification *)aNotification {
    //textViewの高さとoperationPanelの位置を調整
    CGRect textFrame = textView.frame;
    textFrame.size.height = originalTextViewHeight_;
    textView.frame = textFrame;
    CGRect panelFrame = operationPanel.frame;
    panelFrame.origin.y = originalOperationPanelTop_;
    operationPanel.frame = panelFrame;
}

@end
