//
//  MenuItemCell.m
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MenuItemCell.h"

#import "CurrentMenuViewController.h"
#import "MenuItem.h"
#import "PopularMenuViewController.h"
#import "UIImageView+WebCache.h"
#import "User.h"

@implementation MenuItemCell

@synthesize thumbnail = _thumbnail;
@synthesize name = _name;
@synthesize price = _price;
@synthesize favoriteIcon = _favoriteIcon;
@synthesize numberFavorites = _numberFavorites;
@synthesize description = _description;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)styleCell:(MenuItem *)menuItem
{
    if ([menuItem thumbnailUrl]) {
        [_thumbnail setImageWithURL:[NSURL URLWithString:[menuItem thumbnailUrl]]];
    } else {
        [_thumbnail setImage:menuItem.thumbnail];
    }
    
    [_thumbnail.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [_thumbnail.layer setBorderWidth:1.0];
    
    [_name setText:[menuItem name]];
    [_name sizeToFit];
    
    [_price setText:[NSString stringWithFormat:@"$%@",[menuItem price]]];
    
    if ([[menuItem likeCount] intValue] > 0) {
        [_favoriteIcon setHidden:NO];
        [_numberFavorites setHidden:NO];
        [_numberFavorites setText:[[menuItem likeCount] stringValue]];
    } else {
        [_favoriteIcon setHidden:YES];
        [_numberFavorites setHidden:YES];
    }
    
    [_description setText:[menuItem description]];
}

- (IBAction)addPhoto:(id)sender
{
    if ([User currentUser]) {
        if ([self.viewController isKindOfClass:[CurrentMenuViewController class]]) {
            [self.viewController performSegueWithIdentifier:@"CurrentMenuTakePhotoSegue" sender:self];
        } else if ([self.viewController isKindOfClass:[PopularMenuViewController class]]) {
            [self.viewController performSegueWithIdentifier:@"PopularMenuTakePhotoSegue" sender:self];
        }
    } else {
        if ([self.viewController isKindOfClass:[CurrentMenuViewController class]]) {
            [self.viewController performSegueWithIdentifier:@"CurrentMenuSignInSegue" sender:self];
        } else if ([self.viewController isKindOfClass:[PopularMenuViewController class]]) {
            [self.viewController performSegueWithIdentifier:@"PopularMenuSignInSegue" sender:self];
        }
    }
}

#pragma mark SignInDelegate

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn
{
    if (didSignIn) {
        [signInViewController.navigationController popViewControllerAnimated:YES];
        if ([self.viewController isKindOfClass:[CurrentMenuViewController class]]) {
            [self.viewController performSegueWithIdentifier:@"CurrentMenuTakePhotoSegue" sender:self];
        } else if ([self.viewController isKindOfClass:[PopularMenuViewController class]]) {
            [self.viewController performSegueWithIdentifier:@"PopularMenuTakePhotoSegue" sender:self];
        }
    }
}

@end
