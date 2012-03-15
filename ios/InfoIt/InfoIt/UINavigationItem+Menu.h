//
//  UINavigationItem+Menu.h
//  InfoIt
//
//  Created by Christian Deonier on 3/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuDelegate;

@interface UINavigationItem (Menu)

@property (nonatomic, assign) id <MenuDelegate> menuDelegate;

@end
