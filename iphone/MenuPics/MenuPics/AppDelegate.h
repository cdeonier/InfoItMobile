//
//  AppDelegate.h
//  MenuPics
//
//  Created by Christian Deonier on 5/1/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class NavController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) NavController *navController;
@property (strong, nonatomic) UIViewController *centerViewController;

@end
