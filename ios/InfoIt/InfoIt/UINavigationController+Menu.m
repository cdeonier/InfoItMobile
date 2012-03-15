//
//  UINavigationController+Menu.m
//  InfoIt
//
//  Created by Christian Deonier on 3/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "UINavigationController+Menu.h"

@implementation UINavigationController (Menu)

- (UIViewController *)selectedViewController {
    return self.topViewController;
}

@end
