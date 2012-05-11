//
//  HomeViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "HomeViewController.h"
#import "FindMenuViewController.h"
#import "IIViewDeckController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize findMenuTitle = _findMenuTitle;
@synthesize takePhotoTitle = _takePhotoTitle;
@synthesize viewProfileTitle = _viewProfileTitle;

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
    
    UIFont *segoePrint = [UIFont fontWithName:@"Segoe Print" size:_findMenuTitle.font.pointSize];
    
    [_findMenuTitle setFont:segoePrint];
    [_takePhotoTitle setFont:segoePrint];
    [_viewProfileTitle setFont:segoePrint];
    
    UIImage *menuImage = [[UIImage imageNamed:@"nav_menu_icon.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self.viewDeckController action:@selector(toggleLeftView)];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if ([navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    }
    [navigationBar.topItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)findMenu:(id)sender
{
    FindMenuViewController *viewController = [[FindMenuViewController alloc] initWithNibName:@"FindMenuViewController" bundle:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
