//
//  MenuItemViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/7/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SignInViewController.h"
#import "TakePhotoViewController.h"

@class MenuItem;
@class MenuViewController;

@interface MenuItemViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, TakePhotoDelegate, SignInDelegate>

@property (nonatomic, strong) MenuItem *menuItem;
@property (nonatomic, strong) MenuViewController *menuViewController;

@end
