//
//  ViewProfileViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"

@class CreateAccountViewController;
@class SavedPhoto;

enum {
    ProfileTab = 1,
    PhotosTab = 2
};
typedef NSInteger ViewProfileTab;

@protocol SyncPhotoDelegate <NSObject>

- (void)didSyncPhoto:(SavedPhoto *)syncedPhoto;

@end

@interface ViewProfileViewController : UIViewController <SyncPhotoDelegate, UITabBarDelegate, GMGridViewDataSource, GMGridViewActionDelegate>

@property (nonatomic, strong) IBOutlet UITabBar *tabBar;

//Profile
@property (nonatomic, strong) IBOutlet UIView *profileView;

//Photos
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) GMGridView *photosGridView;

- (IBAction)signOut:(id)sender;

@end
