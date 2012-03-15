//
//  UIViewController+Menu.h
//  InfoIt
//
//  Created by Christian Deonier on 3/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MenuStateNone,
    MenuStateLeft,
    MenuStateRight,
} MenuState;

@interface UIViewController (Menu)

@property (nonatomic, assign) MenuState menuState;

- (CGRect)applicationViewFrame;

@end
