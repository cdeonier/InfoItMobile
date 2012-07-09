//
//  FindMenuItemViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 7/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  OrderedDictionary;

enum {
    FindCurrentMenuTab = 1,
    FindAllMenusTab = 2
};
typedef NSInteger FindMenuItemTab;

@interface FindMenuItemViewController : UIViewController <UITabBarDelegate, UIActionSheetDelegate>

@property (nonatomic) NSInteger photoId;

@property (nonatomic, strong) IBOutlet UITabBar *tabBar;
@property (nonatomic) NSInteger *restaurantIdentifier;
@property (nonatomic, strong) NSMutableArray *menuTypes;
@property (nonatomic, strong) OrderedDictionary *restaurantMenus;
@property (nonatomic, strong) NSString *currentMenuType;
@property (nonatomic, strong) OrderedDictionary *currentMenu;

@property (nonatomic, strong) UIActionSheet *actionSheet;

/* Current Menu */
@property (nonatomic, strong) IBOutlet UITableView *currentMenuTable;

/* All Menus */
@property (nonatomic, strong) IBOutlet UITableView *allMenusTable;

@end
