//
//  FindMenuItemViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 7/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    CurrentMenuTab = 1,
    AllMenusTab = 2
};
typedef NSInteger FindMenuItemTab;

@interface FindMenuItemViewController : UIViewController <UITabBarDelegate>

@property (nonatomic, strong) IBOutlet UITabBar *tabBar;

@end
