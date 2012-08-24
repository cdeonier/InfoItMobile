//
//  MenuItemCell.h
//  MenuPics
//
//  Created by Christian Deonier on 6/27/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignInViewController.h"
#import "TakePhotoViewController.h"

@class MenuItem;
@class MenuViewController;

@interface MenuItemCell : UITableViewCell <SignInDelegate, TakePhotoDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *price;
@property (nonatomic, strong) UILabel *description;
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UIButton *addPhotoButton;
@property (nonatomic, strong) UIImageView *likeIcon;
@property (nonatomic, strong) UILabel *likeCount;

- (IBAction)takePhoto:(id)sender;
- (IBAction)handleLongPress:(id)sender;

@property (nonatomic, strong) MenuItem *menuItem;
@property (nonatomic, strong) MenuViewController *parentController; 

- (void)loadMenuItem:(MenuItem *)menuItem;


@end
