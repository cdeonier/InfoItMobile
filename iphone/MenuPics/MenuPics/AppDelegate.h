//
//  AppDelegate.h
//  MenuPics
//
//  Created by Christian Deonier on 5/1/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBiOSSDK/FacebookSDK.h>

extern NSString *const MenuPicsFacebookNotification;

@class ViewController;
@class NavController;
@class IIViewDeckController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) NavController *navController;
@property (strong, nonatomic) IIViewDeckController *deckController;
@property (strong, nonatomic) UIViewController *centerViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)disableNavigationMenu;
- (void)enableNavigationMenu;

- (void)openFacebookSession;

@end
