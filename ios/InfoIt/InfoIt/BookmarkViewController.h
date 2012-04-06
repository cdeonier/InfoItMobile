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

@interface BookmarkViewController : UIViewController <MenuDelegate>

@property (nonatomic, strong) NavigationMenuViewController *navigationMenuViewController;

@end
