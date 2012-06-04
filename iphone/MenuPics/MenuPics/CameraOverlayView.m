//
//  CameraOverlayView.m
//  MenuPics
//
//  Created by Christian Deonier on 5/27/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "CameraOverlayView.h"
#import "TakePhotoViewController.h"

@implementation CameraOverlayView

@synthesize view = _view;
@synthesize flashMode = _flashMode;

@synthesize viewController = _viewController;
@synthesize portraitFlashButton = _portraitFlashButton;
@synthesize landscapeLeftFlashButton = _landscapeLeftFlashButton;
@synthesize landscapeRightFlashButton = _landscapeRightFlashButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
        [self addSubview:self.view];
        self.flashMode = UIImagePickerControllerCameraFlashModeAuto;
    }
    return self;
}

- (IBAction)cancelPicture:(id)sender
{
    [self.viewController cancelPicture];
}

- (IBAction)donePicture:(id)sender
{
    [self.viewController donePicture];
}

- (IBAction)takePicture:(id)sender
{
    [self.viewController takePicture];
}

- (IBAction)toggleFlash:(id)sender
{
    if (self.flashMode == UIImagePickerControllerCameraFlashModeAuto) {
        self.flashMode = UIImagePickerControllerCameraFlashModeOn;
        [self.portraitFlashButton setImage:[UIImage imageNamed:@"flash_button_on"] forState:UIControlStateNormal];
        [self.viewController toggleFlash];
    } else if (self.flashMode == UIImagePickerControllerCameraFlashModeOn) {
        self.flashMode = UIImagePickerControllerCameraFlashModeOff;
        [self.portraitFlashButton setImage:[UIImage imageNamed:@"flash_button_off"] forState:UIControlStateNormal];
        [self.viewController toggleFlash];
    } else {
        self.flashMode = UIImagePickerControllerCameraFlashModeAuto;
        [self.portraitFlashButton setImage:[UIImage imageNamed:@"flash_button_auto"] forState:UIControlStateNormal];
        [self.viewController toggleFlash];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
