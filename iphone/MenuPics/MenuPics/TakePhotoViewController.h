//
//  TakePhotoViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"

@interface TakePhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, GMGridViewDataSource, GMGridViewActionDelegate>

@property (retain, strong) UIView *cameraOverlay;
@property (retain, strong) UIView *portraitView;
@property (retain, strong) UIView *landscapeView;
@property (retain, strong) UIImagePickerController *imagePicker;

@property (retain, strong) IBOutlet UIImageView *preview;
@property (retain, strong) NSMutableArray *dummyThumbs;
@property (retain, strong) NSMutableArray *dummyImages;

@property (retain, strong) GMGridView *portraitGridView;
@property (retain, strong) GMGridView *landscapeGridView;

- (void)cancelPicture;
- (void)takePicture;
- (void)toggleFlash;

@end
