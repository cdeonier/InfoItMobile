//
//  ViewProfileViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "User.h"
#import "UpdateAccountViewController.h"
#import "MWPhotoBrowser.h"

@class SavedPhoto;

enum {
    ProfileTab = 1,
    PhotosTab = 2
};
typedef NSInteger ViewProfileTab;

@protocol SyncPhotoDelegate <NSObject>

- (void)didSyncPhoto:(SavedPhoto *)syncedPhoto;

@end

@interface ViewProfileViewController : UIViewController <MWPhotoBrowserDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, SyncPhotoDelegate, SyncUserDelegate, UITabBarDelegate, GMGridViewDataSource, GMGridViewActionDelegate, UIActionSheetDelegate, UpdateAccountDelegate>

@property (nonatomic, strong) IBOutlet UITabBar *tabBar;
@property (nonatomic, strong) UIActionSheet *actionSheet;

//Profile
@property (nonatomic, strong) IBOutlet UIView *profileView;
@property (nonatomic, strong) UIBarButtonItem *accountButton;
@property (nonatomic, strong) IBOutlet UIButton *profilePhotoButton;
@property (nonatomic, strong) IBOutlet UILabel *profileUsername;
@property (nonatomic, strong) IBOutlet UILabel *profilePoints;
@property (nonatomic, strong) IBOutlet UILabel *profilePointsCalculatingLabel;
@property (nonatomic, strong) IBOutlet GMGridView *popularPhotosGridView;
@property (nonatomic, strong) IBOutlet UILabel *popularPhotosHeader;
@property (nonatomic, strong) NSMutableArray *popularPhotos;
@property (nonatomic, strong) IBOutlet GMGridView *recentPhotosGridView;
@property (nonatomic, strong) NSMutableArray *recentPhotos;
@property (nonatomic) BOOL didUpdateProfilePhoto;
@property (nonatomic, strong) IBOutlet UILabel *noPhotosLabel;

//Photos
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) GMGridView *photosGridView;

@property (nonatomic, strong) MWPhotoBrowser *photoBrowser;
@property (nonatomic, strong) NSMutableArray *photoBrowserArray;

- (IBAction)signOut:(id)sender;
- (IBAction)updateProfilePhoto:(id)sender;

@end
