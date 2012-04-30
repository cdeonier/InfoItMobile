//
//  BookmarkViewController.h
//  InfoIt
//
//  Created by Christian Deonier on 3/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuDelegate.h"

@class NavigationMenuViewController;
@class RestaurantActionMenuViewController;

@interface BookmarkViewController : UIViewController <MenuDelegate>

@property (nonatomic, strong) NavigationMenuViewController *navigationMenuViewController;
@property (nonatomic, strong) RestaurantActionMenuViewController *actionMenuViewController;

@end
