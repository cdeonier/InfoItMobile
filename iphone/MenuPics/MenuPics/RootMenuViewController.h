//
//  MenuViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TakePhotoViewController.h"
#import "SignInViewController.h"

@class OrderedDictionary;
@class Restaurant;

enum {
    CurrentMenuTab = 1,
    MostLikedTab = 2,
    TakePhotoTab = 3,
    RestaurantTab = 4,
    AllMenusTab = 5
};
typedef NSInteger MenuTab;

@interface RootMenuViewController : UIViewController <UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, TakePhotoDelegate, SignInDelegate>

/* General */
@property (nonatomic, strong) IBOutlet UITabBar *tabBar;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) NSNumber *restaurantIdentifier;
@property (nonatomic, strong) NSMutableArray *menuTypes;
@property (nonatomic, strong) OrderedDictionary *restaurantMenus;
@property (nonatomic, strong) NSString *currentMenuType;
@property (nonatomic, strong) OrderedDictionary *currentMenu;
@property (nonatomic, strong) NSString *requestedTab;

/* Current Menu */
@property (nonatomic, strong) IBOutlet UITableView *currentMenuTable;

/* Most Liked Menu */
@property (nonatomic, strong) IBOutlet UITableView *mostLikedTable;
@property (nonatomic, strong) NSArray *mostLikedMenuItems;

/* Restaurant */
@property (nonatomic, strong) Restaurant *restaurant;

/* All Menus */
@property (nonatomic, strong) IBOutlet UITableView *allMenusTable;

@end
