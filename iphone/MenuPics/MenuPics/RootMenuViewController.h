//
//  MenuViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderedDictionary;

enum {
    CurrentMenuTab = 1,
    MostLikedTab = 2,
    TakePhotoTab = 3,
    RestaurantTab = 4,
    AllMenusTab = 5
};
typedef NSInteger MenuTab;

@interface RootMenuViewController : UIViewController <UITabBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableViewCell *menuItemCell;
}

@property (nonatomic, strong) IBOutlet UITabBar *tabBar;
@property (nonatomic, strong) IBOutlet UITableView *currentMenuTable;
@property (nonatomic, strong) IBOutlet UITableView *mostLikedTable;
@property (nonatomic, strong) IBOutlet UITableView *allMenusTable;

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) NSNumber *restaurantIdentifier;
@property (nonatomic, strong) NSMutableArray *menuTypes;
@property (nonatomic, strong) OrderedDictionary *restaurantMenus;

@property (nonatomic, strong) NSString *currentMenuType;
@property (nonatomic, strong) OrderedDictionary *currentMenu;

@property (nonatomic, strong) NSArray *mostLikedMenuItems;

- (void)restGetRestaurantMenus:(NSNumber *)restaurantIdentifier;

@end
