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
@class RootMenuViewController;

@interface MenuItemCell : UITableViewCell <SignInDelegate, TakePhotoDelegate>

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *price;
@property (nonatomic, strong) IBOutlet UILabel *description;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic, strong) IBOutlet UIButton *addPhotoButton;
@property (nonatomic, strong) IBOutlet UIImageView *likeIcon;
@property (nonatomic, strong) IBOutlet UILabel *likeCount;

- (IBAction)takePhoto:(id)sender;

@property (nonatomic, strong) MenuItem *menuItem;
@property (nonatomic, strong) RootMenuViewController *parentController; 

- (void)loadMenuItem:(MenuItem *)menuItem;


@end
