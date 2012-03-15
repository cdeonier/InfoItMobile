//
//  UINavigationItem+Menu.m
//  InfoIt
//
//  Created by Christian Deonier on 3/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "UINavigationItem+Menu.h"
#import <objc/runtime.h>

@implementation UINavigationItem (Menu)

static char *menuDelegateKey;

- (void)setMenuDelegate:(id<MenuDelegate>)menuDelegate {
    objc_setAssociatedObject(self, &menuDelegateKey, menuDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id <MenuDelegate>)menuDelegate {
    return (id <MenuDelegate>)objc_getAssociatedObject(self, &menuDelegateKey);
}

@end
