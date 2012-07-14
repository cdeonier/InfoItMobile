//
//  MenuItemViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/22/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignInViewController.h"
#import "TakePhotoViewController.h"
#import "GMGridView.h"

@class MenuItem;
@class Photo;

enum {
    NoAction = 0,
    LikeButtonAction = 1,
    PhotoButtonAction = 2,
    UpvoteButtonAction = 3
};
typedef NSInteger ButtonAction;

@interface MenuItemViewController : UIViewController <SignInDelegate, TakePhotoDelegate, GMGridViewDataSource, GMGridViewActionDelegate>

@property (nonatomic, strong) IBOutlet UIView *contentContainer;
@property (nonatomic, strong) IBOutlet UIView *separator;
@property (nonatomic, strong) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) IBOutlet UILabel *menuItemName;
@property (nonatomic, strong) IBOutlet UILabel *description;

@property (nonatomic, strong) IBOutlet UIView *photoView;
@property (nonatomic, strong) IBOutlet UIButton *usernameButton;
@property (nonatomic, strong) IBOutlet UIButton *upvoteButton;
@property (nonatomic, strong) IBOutlet UILabel *points;
@property (nonatomic, strong) IBOutlet UIView *photoPointsBackground;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) Photo *displayedPhoto;
@property (nonatomic, strong) IBOutlet UIImageView *profileImage;

@property (nonatomic, strong) MenuItem *menuItem;

@property (nonatomic, strong) NSMutableArray *menuItemPhotos;

@property (nonatomic) ButtonAction buttonAction;

@property (strong) GMGridView *gridView;

- (IBAction)pressUpvoteButton:(id)sender;
- (IBAction)pressMenuButton:(id)sender;
- (IBAction)pressLikeButton:(id)sender;
- (IBAction)pressRestaurantButton:(id)sender;

@end
