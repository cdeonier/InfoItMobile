//
//  MenuViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITabBarController <UITabBarControllerDelegate>

@property (nonatomic, strong) NSNumber *restaurantId;

- (void)selectMenu:(NSString *)menuType;
- (void)reloadData;

@end
