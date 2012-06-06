//
//  CameraOverlayView.h
//  MenuPics
//
//  Created by Christian Deonier on 5/27/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TakePhotoViewController;

@interface CameraOverlayView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) TakePhotoViewController *viewController;
@property (nonatomic) UIImagePickerControllerCameraFlashMode flashMode;
@property (nonatomic, strong) UIImageView *focusAnimation;

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UIButton *portraitFlashButton;
@property (nonatomic, strong) IBOutlet UIButton *landscapeLeftFlashButton;
@property (nonatomic, strong) IBOutlet UIButton *landscapeRightFlashButton;

-(IBAction)cancelPicture:(id)sender;
-(IBAction)donePicture:(id)sender;
-(IBAction)takePicture:(id)sender;
-(IBAction)toggleFlash:(id)sender;
-(IBAction)showFocusIndicator:(id)sender;

@end
