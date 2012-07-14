//
//  ShellNavigationController.m
//  MenuPics
//
//  Created by Christian Deonier on 6/12/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "ShellNavigationController.h"
#import "ViewProfileViewController.h"

@interface ShellNavigationController ()

@end

@implementation ShellNavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *targetViewController = [self.viewControllers objectAtIndex:([self.viewControllers count] - 2)];
    if ([targetViewController isKindOfClass:[ViewProfileViewController class]]) {
        ViewProfileViewController *viewProfileController = (ViewProfileViewController *)targetViewController;
        UITabBarItem *selectedTabItem = [viewProfileController.tabBar selectedItem];
        UITabBarItem *photosTabItem = [viewProfileController.tabBar.items objectAtIndex:1];
        if (selectedTabItem == photosTabItem) {
            [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_translucent"] forBarMetrics:UIBarMetricsDefault];
            [self.navigationBar setTranslucent:YES];
        }
    } else {
        [self.navigationBar setTranslucent:NO];
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    }
    return [super popViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    [super pushViewController:viewController animated:animated];
}

@end
