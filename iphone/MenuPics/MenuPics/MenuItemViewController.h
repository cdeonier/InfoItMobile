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

@class MenuItem;

enum {
    NoAction = 0,
    LikeButtonAction = 1,
    PhotoButtonAction = 2
};
typedef NSInteger ButtonAction;

@interface MenuItemViewController : UIViewController <SignInDelegate, TakePhotoDelegate>

@property (nonatomic, strong) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) MenuItem *menuItem;

@property (nonatomic) ButtonAction buttonAction;

- (IBAction)pressMenuButton:(id)sender;
- (IBAction)pressLikeButton:(id)sender;
- (IBAction)pressRestaurantButton:(id)sender;
- (IBAction)takePhoto;

@end
