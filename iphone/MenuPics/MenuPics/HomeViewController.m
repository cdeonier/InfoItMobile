//
//  HomeViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "HomeViewController.h"
#import "FindMenuViewController.h"
#import "TakePhotoViewController.h"
#import "IIViewDeckController.h"
#import "UIColor+ExtendedColor.h"

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
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor navBarButtonColor];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if ([navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    }
    [navigationBar.topItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.viewDeckController.view.frame = [[UIScreen mainScreen] applicationFrame];
    [self.viewDeckController.view setNeedsDisplay];
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
    backButton.tintColor = [UIColor navBarButtonColor];
    self.navigationItem.backBarButtonItem = backButton;
    [viewController setTitle:@"Restaurants"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)takePhoto:(id)sender
{
    TakePhotoViewController *viewController = [[TakePhotoViewController alloc] initWithNibName:@"TakePhotoViewController" bundle:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    backButton.tintColor = [UIColor navBarButtonColor];
    self.navigationItem.backBarButtonItem = backButton;
    [self.navigationController pushViewController:viewController animated:YES];
    
}


@end
