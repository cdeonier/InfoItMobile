//
//  CameraOverlayView.h
//  MenuPics
//
//  Created by Christian Deonier on 5/27/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TakePhotoViewController;

@interface CameraOverlayView : UIView 

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) TakePhotoViewController *viewController;

-(IBAction)cancelButton:(id)sender;

@end
