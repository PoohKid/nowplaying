//
//  ConfigViewController.m
//  nowplaying
//
//  Created by プー坊 on 11/09/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"


@implementation ConfigViewController

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [twitterApplications_ release], twitterApplications_ = nil;
    [chooseApplication_ release], chooseApplication_ = nil;
    [doneButton release], doneButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    GA_TRACK_CLASS

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TwitterApplications" ofType:@"plist"];
    twitterApplications_ = [[[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"Root"] retain];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    chooseApplication_ = [[userDefaults stringForKey:@"ChooseApplication"] retain];

    self.title = @"Config";
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewDidUnload
{
    [twitterApplications_ release], twitterApplications_ = nil;
    [chooseApplication_ release], chooseApplication_ = nil;
    [doneButton release], doneButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Choose Twitter application";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [twitterApplications_ count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.textLabel.text = @"none";
        if (chooseApplication_ == nil) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        NSDictionary *twitterApplication = [twitterApplications_ objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = [twitterApplication objectForKey:@"ApplicationName"];
        if ([chooseApplication_ isEqualToString:[twitterApplication objectForKey:@"ApplicationId"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [chooseApplication_ release], chooseApplication_ = nil;
    if (indexPath.row == 0) {
        chooseApplication_ = nil;
    } else {
        NSDictionary *twitterApplication = [twitterApplications_ objectAtIndex:indexPath.row - 1];
        chooseApplication_ = [[twitterApplication objectForKey:@"ApplicationId"] retain];
    }
    [userDefaults setObject:chooseApplication_ forKey:@"ChooseApplication"];
    [userDefaults synchronize];
    [tableView reloadData];
}

#pragma mark - IBAction

- (IBAction)tapDoneButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    if ([delegate respondsToSelector:@selector(didChooseApplication)]) {
        [delegate didChooseApplication];
    }
}
@end
