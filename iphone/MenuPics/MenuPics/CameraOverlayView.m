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
@synthesize viewController = _viewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (IBAction)cancelPicture:(id)sender
{
    [self.viewController cancelPicture];
}

- (IBAction)takePicture:(id)sender
{
    [self.viewController takePicture];
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
