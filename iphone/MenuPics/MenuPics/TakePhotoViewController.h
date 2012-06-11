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

@interface TakePhotoViewController : UIViewController <CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GMGridViewDataSource, GMGridViewActionDelegate>

@property NSInteger displayedPhotoIndex;

@property (nonatomic, strong) UIView *cameraOverlay;
@property (strong) UIView *portraitView;
@property (strong) UIView *landscapeView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (strong) IBOutlet UIImageView *preview;
@property (strong) NSMutableArray *photos;
@property (strong) GMGridView *portraitGridView;
@property (strong) GMGridView *landscapeGridView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

- (IBAction)toggleSelectionBox:(id)sender;
- (IBAction)savePhotos:(id)sender;

- (void)cancelPicture;
- (void)donePicture;
- (void)takePicture;
- (void)toggleFlash;

@end
