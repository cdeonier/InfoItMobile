//
//  TakePhotoViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"

@interface TakePhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (retain) CaptureSessionManager *captureSessionManager;
@property (retain, strong) UIView *cameraOverlay;

- (void) cancelPhoto;

@end
