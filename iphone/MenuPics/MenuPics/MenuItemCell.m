//
//  MenuItemCell.m
//  MenuPics
//
//  Created by Christian Deonier on 6/27/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MenuItemCell.h"
#import "MenuItem.h"
#import "RootMenuViewController.h"
#import "AFNetworking.h"
#import "TakePhotoViewController.h"
#import "UIColor+ExtendedColor.h"
#import "User.h"

@implementation MenuItemCell

@synthesize name = _name;
@synthesize price = _price;
@synthesize description = _description;
@synthesize thumbnail = _thumbnail;
@synthesize addPhotoButton = _addPhotoButton;
@synthesize likeIcon = _likeIcon;
@synthesize likeCount = _likeCount;

@synthesize menuItem = _menuItem;
@synthesize parentController = _parentController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuItemCell" owner:self options:nil];
        UITableViewCell *nibView = [nibObjects objectAtIndex:0];
        [self.contentView addSubview:nibView.contentView];
    }
    return self;
}

- (void)loadMenuItem:(MenuItem *)menuItem
{
    [self setMenuItem:menuItem];
    
    NSString *nameString = [menuItem name];
    if ([nameString length] < 40) {
        [_name setText:nameString];
    } else {
        NSString *truncatedNameString = [nameString substringToIndex:37 ];
        [_name setText:[NSString stringWithFormat:@"%@...", truncatedNameString]];
    }
    [_name setNumberOfLines:0];
    [_name setFrame:CGRectMake(115, 5, 150, 45)];
    [_name sizeToFit];
    
    _price.text = [NSString stringWithFormat:@"$%@", menuItem.price];
    
    if ([[menuItem description] length] > 0) {
        NSString *descriptionString = menuItem.description;
        if ([descriptionString length] < 100) {
            [_description setText:descriptionString];
        } else {
            NSString *truncatedDescriptionString = [descriptionString substringToIndex:100];
            [_description setText:[NSString stringWithFormat:@"%@...", truncatedDescriptionString]];
        }
        
        _description.lineBreakMode = UILineBreakModeTailTruncation;
        [_description setNumberOfLines:0];
        [_description setFrame:CGRectMake(5, 110, 310, 40)];
        [_description sizeToFit];
    } else {
        [_description setHidden:YES];
    }
    
    [_thumbnail.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [_thumbnail.layer setBorderWidth:1.0];
    
    if (menuItem.smallThumbnailUrl) {    
        [_thumbnail setHidden:NO];
        [_addPhotoButton setHidden:YES];
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            [_thumbnail setImageWithURL:[NSURL URLWithString:menuItem.largeThumbnailUrl]];
        } else {
            [_thumbnail setImageWithURL:[NSURL URLWithString:menuItem.smallThumbnailUrl]];
        }
    } else {
        [_thumbnail setHidden:YES];
        [_addPhotoButton setHidden:NO];
        [_addPhotoButton.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [_addPhotoButton.layer setBorderWidth:1.0];
    }
    
    if ([[menuItem likeCount] intValue] > 1) {
        [_likeCount setText:[NSString stringWithFormat:@"%@ likes", [[menuItem likeCount] description]]];
    } else if ([[menuItem likeCount] intValue] > 0) {
        [_likeCount setText:[NSString stringWithFormat:@"%@ like", [[menuItem likeCount] description]]];
    } else {
        [_likeIcon setHidden:YES];
        [_likeCount setHidden:YES];
    }
}

- (IBAction)takePhoto:(id)sender
{
    if ([User currentUser]) {
        TakePhotoViewController *viewController = [[TakePhotoViewController alloc] initWithNibName:@"TakePhotoViewPortrait" bundle:nil];
        [viewController setDelegate:self];
        [viewController setMenuItemId:[_menuItem entityId]];
        [viewController setRestaurantId:[_menuItem restaurantId]];
        [viewController setMenuItem:_menuItem];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
        [backButton setTintColor:[UIColor navBarButtonColor]];
        _parentController.navigationItem.backBarButtonItem = backButton;
        
        [_parentController.navigationController pushViewController:viewController animated:YES];
    } else {
        SignInViewController *viewController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
        [viewController setDelegate:self];
        [_parentController presentModalViewController:viewController animated:YES];
    }
}

#pragma mark SignInDelegate

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn
{
    if (didSignIn) {
        [_parentController dismissModalViewControllerAnimated:NO];
        [self takePhoto:self];  
    } else {
        [_parentController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark TakePhotoDelegate

- (void)takePhotoViewController:(TakePhotoViewController *)takePhotoViewController didSavePhotos:(BOOL)didSavePhotos
{
    [_parentController.currentMenuTable reloadData];
    [_parentController.mostLikedTable reloadData];
    [_parentController dismissModalViewControllerAnimated:YES];
}

@end
