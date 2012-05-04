//
//  NavController.m
//  InfoIt
//
//  Created by Christian Deonier on 5/2/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "NavController.h"
#import "InfoChooserViewController.h"
#import "BookmarksViewController.h"
#import "RecentHistoryViewController.h"
#import "AccountViewController.h"

#import "UIColor+ExtendedColor.h"
#import "IIViewDeckController.h"

@interface NavController ()

@end

@implementation NavController

@synthesize infoButton = _infoButton;
@synthesize bookmarksButton = _bookmarksButton;
@synthesize historyButton = _historyButton;
@synthesize accountButton = _accountButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.infoButton setBackgroundColor:[UIColor navButtonPressedColor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pressedInfo:(id)sender 
{
    InfoChooserViewController *viewController = [[InfoChooserViewController alloc] initWithNibName:@"InfoChooserViewController" bundle:nil];
    self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self unpressNavigationButtons];
    [self.infoButton setBackgroundColor:[UIColor navButtonPressedColor]];
    [self.viewDeckController toggleLeftView];
}

- (IBAction)pressedBookmarks:(id)sender 
{
    BookmarksViewController *viewController = [[BookmarksViewController alloc] initWithNibName:@"BookmarksViewController" bundle:nil];
    self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self unpressNavigationButtons];
    [self.bookmarksButton setBackgroundColor:[UIColor navButtonPressedColor]];
    [self.viewDeckController toggleLeftView];
}

- (IBAction)pressedHistory:(id)sender
{
    RecentHistoryViewController *viewController = [[RecentHistoryViewController alloc] initWithNibName:@"RecentHistoryViewController" bundle:nil];
    self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self unpressNavigationButtons];
    [self.historyButton setBackgroundColor:[UIColor navButtonPressedColor]];
    [self.viewDeckController toggleLeftView];
}

- (IBAction)pressedAccount:(id)sender
{
    AccountViewController *viewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil];
    self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self unpressNavigationButtons];
    [self.accountButton setBackgroundColor:[UIColor navButtonPressedColor]];
    [self.viewDeckController toggleLeftView];
}

- (void)unpressNavigationButtons
{
    [self.infoButton setBackgroundColor:[UIColor clearColor]];
    [self.bookmarksButton setBackgroundColor:[UIColor clearColor]];
    [self.historyButton setBackgroundColor:[UIColor clearColor]];
    [self.accountButton setBackgroundColor:[UIColor clearColor]];
}

@end
