//
//  NavController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/2/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "NavController.h"
#import "FindRestaurantViewController.h"
#import "TakePhotoViewController.h"
#import "ViewProfileViewController.h"
#import "UIColor+ExtendedColor.h"
#import "IIViewDeckController.h"

@interface NavController ()

@end

@implementation NavController

@synthesize findMenuButton = _findMenuButton;
@synthesize takePhotoButton = _takePhotoButton;
@synthesize viewProfileButton = _viewProfileButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pressFindMenu:(id)sender
{
    [self.findMenuButton setBackgroundColor:[UIColor navButtonPressedColor]];   
}

- (IBAction)pressTakePhoto:(id)sender
{
    [self.takePhotoButton setBackgroundColor:[UIColor navButtonPressedColor]];   
}

- (IBAction)pressViewProfile:(id)sender
{
    [self.viewProfileButton setBackgroundColor:[UIColor navButtonPressedColor]];
}

- (IBAction)releaseFindMenu:(id)sender
{
    [self.findMenuButton setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)releaseTakePhoto:(id)sender
{
    [self.takePhotoButton setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)releaseViewProfile:(id)sender
{
    [self.viewProfileButton setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)findMenu:(id)sender 
{
    [self.findMenuButton setBackgroundColor:[UIColor clearColor]];
    
    NSArray *navigationStack = [(UINavigationController *)self.viewDeckController.centerController viewControllers];
    UINavigationController *topController = [navigationStack objectAtIndex:([navigationStack count] - 1)];
    
    if (![topController isKindOfClass:[FindRestaurantViewController class]]) {
        FindRestaurantViewController *viewController = [[FindRestaurantViewController alloc] initWithNibName:@"FindRestaurantViewController" bundle:nil];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[topController title] style:UIBarButtonItemStylePlain target:nil action:nil];
        backButton.tintColor = [UIColor navBarButtonColor];
        topController.navigationItem.backBarButtonItem = backButton;
        [topController.navigationController pushViewController:viewController animated:YES];
    }
    
    [self.viewDeckController toggleLeftView];
}

- (IBAction)takePhoto:(id)sender 
{
    [self.takePhotoButton setBackgroundColor:[UIColor clearColor]];
    
    NSArray *navigationStack = [(UINavigationController *)self.viewDeckController.centerController viewControllers];
    UINavigationController *topController = [navigationStack objectAtIndex:([navigationStack count] - 1)];
    TakePhotoViewController *viewController = [[TakePhotoViewController alloc] initWithNibName:@"TakePhotoViewController" bundle:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[topController title] style:UIBarButtonItemStylePlain target:nil action:nil];
    backButton.tintColor = [UIColor navBarButtonColor];
    topController.navigationItem.backBarButtonItem = backButton;
    [topController.navigationController pushViewController:viewController animated:YES];
    
    [self.viewDeckController toggleLeftView];
}

- (IBAction)viewProfile:(id)sender
{
    [self.viewProfileButton setBackgroundColor:[UIColor clearColor]];
    
    NSArray *navigationStack = [(UINavigationController *)self.viewDeckController.centerController viewControllers];
    UINavigationController *topController = [navigationStack objectAtIndex:([navigationStack count] - 1)];
    
    if (![topController isKindOfClass:[ViewProfileViewController class]]) {
        ViewProfileViewController *viewController = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[topController title] style:UIBarButtonItemStylePlain target:nil action:nil];
        backButton.tintColor = [UIColor navBarButtonColor];
        topController.navigationItem.backBarButtonItem = backButton;
        [topController.navigationController pushViewController:viewController animated:YES];
    }
    
    [self.viewDeckController toggleLeftView];
}


@end
