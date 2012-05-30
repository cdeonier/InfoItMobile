//
//  TakePhotoViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakePhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (retain, strong) UIView *cameraOverlay;
@property (retain, strong) UIImagePickerController *imagePicker;

@property (retain, strong) IBOutlet UIImageView *preview;

- (void) cancelPicture;
- (void) takePicture;

@end
