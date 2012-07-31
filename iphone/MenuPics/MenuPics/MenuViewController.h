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

@interface MenuViewController : UIViewController <UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, TakePhotoDelegate, SignInDelegate>

/* General */
@property (nonatomic, strong) IBOutlet UITabBar *tabBar;
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
@property (nonatomic, strong) IBOutlet UIScrollView *restaurantScrollView;
@property (nonatomic, strong) IBOutlet UILabel *restaurantName;
@property (nonatomic, strong) IBOutlet UILabel *restaurantDescription;
@property (nonatomic, strong) IBOutlet UIView *addressContainer;
@property (nonatomic, strong) IBOutlet UILabel *addressOne;
@property (nonatomic, strong) IBOutlet UILabel *addressTwo;
@property (nonatomic, strong) IBOutlet UILabel *cityStateZip;
@property (nonatomic, strong) IBOutlet UILabel *phoneNumber;

/* All Menus */
@property (nonatomic, strong) IBOutlet UITableView *allMenusTable;

@end
