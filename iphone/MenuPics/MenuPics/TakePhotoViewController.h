//
//  TakePhotoViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GMGridView.h"

@class TakePhotoViewController;
@class CameraOverlayView;
@class MenuItem;

@protocol TakePhotoDelegate <NSObject>

- (void)takePhotoViewController:(TakePhotoViewController *)takePhotoViewController didSavePhotos:(BOOL)didSavePhotos;

@end

@interface TakePhotoViewController : UIViewController <CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GMGridViewDataSource, GMGridViewActionDelegate>

@property (nonatomic, strong) id<TakePhotoDelegate> delegate;

@property NSInteger displayedPhotoIndex;
@property (nonatomic, strong) NSArray *savedPhotos;

@property (nonatomic, strong) CameraOverlayView *cameraOverlay;
@property (nonatomic, strong) UIView *portraitView;
@property (nonatomic, strong) UIView *landscapeView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (strong) IBOutlet UIImageView *preview;
@property (nonatomic, strong) NSString *previewPhotoFileLocation;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) GMGridView *portraitGridView;
@property (nonatomic, strong) GMGridView *landscapeGridView;

@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) NSNumber *restaurantId;
@property (nonatomic, strong) NSNumber *menuItemId;
@property (nonatomic, strong) MenuItem *menuItem;

- (IBAction)toggleSelectionBox:(id)sender;
- (IBAction)savePhotos:(id)sender;

- (void)cancelPicture;
- (void)donePicture;
- (void)takePicture;
- (void)toggleFlash;

@end
