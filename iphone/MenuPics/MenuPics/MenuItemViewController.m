//
//  MenuItemViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/22/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "MenuItemViewController.h"
#import "RootMenuViewController.h"
#import "ImageUtil.h"
#import "UIColor+ExtendedColor.h"
#import "MenuItem.h"

@interface MenuItemViewController ()

@end

@implementation MenuItemViewController

@synthesize menuButtonLabel = _menuButtonLabel;
@synthesize likeButtonLabel = _likeButtonLabel;
@synthesize restaurantButtonLabel = _restaurantButtonLabel;
@synthesize likeButton = _likeButton;
@synthesize menuItem = _menuItem;

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
    
    [self setTitle:@"Menu Item"];
    
    UILabel *name = (UILabel *)[self.view viewWithTag:3];
    [name setText:[self.menuItem name]];
    
    [self initializeDescriptionView];
    [self initializeProfileImage];
    
    
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

- (void) initializeDescriptionView
{
    UILabel *description = (UILabel *)[self.view viewWithTag:4];
    [description setText:[self.menuItem description]];
    UIFont *descriptionFont = [UIFont fontWithName:@"GillSans" size:13.0];
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize expectedLabelSize = [[self.menuItem description] sizeWithFont:descriptionFont
                                                       constrainedToSize:maximumLabelSize
                                                           lineBreakMode:UILineBreakModeWordWrap]; 
    CGRect newFrame = description.frame;
    newFrame.size.height = expectedLabelSize.height;
    description.frame = newFrame;
}

- (void) initializeProfileImage
{
    [ImageUtil initializeProfileImage:self.view withUrl:[self.menuItem profilePictureUrl]];
}

#pragma mark Button Actions

- (IBAction)touchMenuButton:(id)sender
{
    [self.menuButtonLabel setTextColor:[UIColor whiteColor]];
}

- (IBAction)touchLikeButton:(id)sender
{
    [sender setImage:[UIImage imageNamed:@"like_button_pressed"] forState:UIControlStateHighlighted];
    [self.likeButtonLabel setTextColor:[UIColor whiteColor]];
    [sender setHighlighted:YES];
}

- (IBAction)touchRestaurantButton:(id)sender
{
    [self.restaurantButtonLabel setTextColor:[UIColor whiteColor]];
}

- (IBAction)releaseMenuButton:(id)sender
{
    [self.menuButtonLabel setTextColor:[UIColor normalButtonColor]];
}

- (IBAction)releaseLikeButton:(id)sender
{
    [self.likeButtonLabel setTextColor:[UIColor normalButtonColor]];
}

- (IBAction)releaseRestaurantButton:(id)sender
{
    [self.restaurantButtonLabel setTextColor:[UIColor normalButtonColor]];
}

- (IBAction)pressMenuButton:(id)sender
{
    [self.menuButtonLabel setTextColor:[UIColor normalButtonColor]];
    
    RootMenuViewController *viewController = [[RootMenuViewController alloc] initWithNibName:@"RootMenuViewController" bundle:nil];
    viewController.restaurantIdentifier = [self.menuItem restaurantId];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)pressLikeButton:(id)sender
{
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"like_button"] forState:UIControlStateNormal];
        [self.likeButtonLabel setTextColor:[UIColor normalButtonColor]];
        [sender setSelected:NO];
    }else {
        [sender setImage:[UIImage imageNamed:@"like_button_pressed"] forState:UIControlStateSelected];
        [self.likeButtonLabel setTextColor:[UIColor whiteColor]];
        [sender setSelected:YES];
    }
}

- (IBAction)pressRestaurantButton:(id)sender
{
    [self.restaurantButtonLabel setTextColor:[UIColor normalButtonColor]];
    
    RootMenuViewController *viewController = [[RootMenuViewController alloc] initWithNibName:@"RootMenuViewController" bundle:nil];
    viewController.restaurantIdentifier = [self.menuItem restaurantId];
    viewController.requestedTab = @"Restaurant";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
