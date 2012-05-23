//
//  MenuItemViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/22/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuItem;

@interface MenuItemViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *menuButtonLabel;
@property (nonatomic, strong) IBOutlet UILabel *likeButtonLabel;
@property (nonatomic, strong) IBOutlet UILabel *restaurantButtonLabel;
@property (nonatomic, strong) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) MenuItem *menuItem;

- (IBAction)touchMenuButton:(id)sender;
- (IBAction)touchLikeButton:(id)sender;
- (IBAction)touchRestaurantButton:(id)sender;
- (IBAction)releaseMenuButton:(id)sender;
- (IBAction)releaseLikeButton:(id)sender;
- (IBAction)releaseRestaurantButton:(id)sender;
- (IBAction)pressMenuButton:(id)sender;
- (IBAction)pressLikeButton:(id)sender;
- (IBAction)pressRestaurantButton:(id)sender;

@end
