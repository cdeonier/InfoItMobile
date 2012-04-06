//
//  UIViewController+Menu.m
//  InfoIt
//
//  Created by Christian Deonier on 3/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "UIViewController+Menu.h"
#import "UINavigationItem+Menu.h"
#import "MenuDelegate.h"
#import <objc/runtime.h>

@interface UIViewController (MenuPrivate)

- (void)revealLeftMenu:(BOOL)showLeftMenu;
- (void)revealRightMenu:(BOOL)showRightMenu;

@end

@implementation UIViewController (Menu)

static char *menuStateKey;

- (void)setMenuState:(MenuState)menuState {
    
    MenuState currentState = self.menuState;
    
    objc_setAssociatedObject(self, &menuStateKey, [NSNumber numberWithInt:menuState], OBJC_ASSOCIATION_RETAIN);
    
    switch (currentState) {
        case MenuStateNone:
            if (menuState == MenuStateLeft) {
                [self revealLeftMenu:YES];
            } else if (menuState == MenuStateRight) {
                [self revealRightMenu:YES];
            } else {
                // Do Nothing
            }
            break;
        case MenuStateLeft:
            if (menuState == MenuStateNone) {
                [self revealLeftMenu:NO];
            } else if (menuState == MenuStateRight) {
                [self revealLeftMenu:NO];
                [self revealRightMenu:YES];
            } else {
                [self revealLeftMenu:YES];
            }
            break;
        case MenuStateRight:
            if (menuState == MenuStateNone) {
                [self revealRightMenu:NO];
            } else if (menuState == MenuStateLeft) {
                [self revealRightMenu:NO];
                [self revealLeftMenu:YES];
            } else {
                [self revealRightMenu:YES];
            }
        default:
            break;
    }
}

- (MenuState)menuState {
    return (MenuState)[objc_getAssociatedObject(self, &menuStateKey) intValue];
}

- (CGRect)applicationViewFrame {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect expectedFrame = [self.view convertRect:appFrame fromView:nil];
    return expectedFrame;
}

@end

#define MENU_TAG 10000

@implementation UIViewController (MenuPrivate)

- (UIViewController *)selectedViewController {
    return self;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    UIView *view = [self.view.superview viewWithTag:(int)context];
    [view removeFromSuperview];
}

- (void)revealLeftMenu:(BOOL)showLeftMenu {
    
    id <MenuDelegate> delegate = [self selectedViewController].navigationItem.menuDelegate;
    
    if ( ! [delegate respondsToSelector:@selector(viewForLeftMenu)]) {
        return;
    }
    
    UIView *revealedView = [delegate viewForLeftMenu];
    revealedView.tag = MENU_TAG;
    CGFloat width = CGRectGetWidth(revealedView.frame);
    
    if (showLeftMenu) {
        [self.view.superview insertSubview:revealedView belowSubview:self.view];
        
        [UIView beginAnimations:@"" context:nil];
        
        self.view.frame = CGRectOffset(self.view.frame, width, 0);
        
    } else {
        [UIView beginAnimations:@"hideMenu" context:(void *)MENU_TAG];
        
        self.view.frame = (CGRect){CGPointZero, self.view.frame.size};
        
        
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
    }
    
    [UIView commitAnimations];
}

- (void)revealRightMenu:(BOOL)showRightMenu {
    
    id <MenuDelegate> delegate = [self selectedViewController].navigationItem.menuDelegate;
    
    if ( ! [delegate respondsToSelector:@selector(viewForRightMenu)]) {
        return;
    }
    
    UIView *revealedView = [delegate viewForRightMenu];
    revealedView.tag = MENU_TAG;
    CGFloat width = CGRectGetWidth(revealedView.frame);
    revealedView.frame = (CGRect){self.view.frame.size.width - width, revealedView.frame.origin.y, revealedView.frame.size};
    
    if (showRightMenu) {
        [self.view.superview insertSubview:revealedView belowSubview:self.view];
        
        [UIView beginAnimations:@"" context:nil];
        
        self.view.frame = CGRectOffset(self.view.frame, -width, 0);
    } else {
        [UIView beginAnimations:@"hideMenu" context:(void *)MENU_TAG];
        self.view.frame = (CGRect){CGPointZero, self.view.frame.size};
        
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
    }
    
    [UIView commitAnimations];
}

@end