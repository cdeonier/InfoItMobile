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
@synthesize focusAnimation = _focusAnimation;

@synthesize viewController = _viewController;
@synthesize portraitFlashButton = _portraitFlashButton;
@synthesize landscapeLeftFlashButton = _landscapeLeftFlashButton;
@synthesize landscapeRightFlashButton = _landscapeRightFlashButton;
@synthesize numberPhotosIcon = _numberPhotosIcon;
@synthesize numberPhotosStatus = _numberPhotosStatus;
@synthesize cancelButton = _cancelButton;
@synthesize doneButton = _doneButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
        [self addSubview:self.view];
        self.flashMode = UIImagePickerControllerCameraFlashModeAuto;
        
        UIImageView *focusAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [focusAnimation setAnimationImages:[NSArray arrayWithObjects:
                                              [UIImage imageNamed:@"focus_indicator"],[UIImage imageNamed:@"focus_indicator_dark"],
                                              [UIImage imageNamed:@"focus_indicator"],[UIImage imageNamed:@"focus_indicator_dark"],
                                              [UIImage imageNamed:@"focus_indicator"],[UIImage imageNamed:@"focus_indicator_dark"],
                                              [UIImage imageNamed:@"focus_indicator"],nil]];
        [focusAnimation setAnimationDuration:1.5f];
        [focusAnimation setAnimationRepeatCount:1];
        [self setFocusAnimation:focusAnimation];
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
    [self.cancelButton setHidden:YES];
    [self.doneButton setHidden:NO];
    [self.numberPhotosStatus setHidden:NO];
    [self.numberPhotosIcon setHidden:NO];
    int numberPhotos = [self.numberPhotosStatus.text intValue] + 1;
    [self.numberPhotosStatus setText:[NSString stringWithFormat:@"%i", numberPhotos]];
}

- (IBAction)toggleFlash:(id)sender
{
    if (self.flashMode == UIImagePickerControllerCameraFlashModeAuto) {
        self.flashMode = UIImagePickerControllerCameraFlashModeOn;
        [self.portraitFlashButton setImage:[UIImage imageNamed:@"flash_button_on"] forState:UIControlStateNormal];
        [self.landscapeLeftFlashButton setImage:[UIImage imageNamed:@"left_flash_on"] forState:UIControlStateNormal];
        [self.landscapeLeftFlashButton setImage:[UIImage imageNamed:@"left_flash_on_pressed"] forState:UIControlStateHighlighted];
        [self.landscapeRightFlashButton setImage:[UIImage imageNamed:@"right_flash_on"] forState:UIControlStateNormal];
        [self.landscapeRightFlashButton setImage:[UIImage imageNamed:@"right_flash_on_pressed"] forState:UIControlStateHighlighted];
        [self.viewController toggleFlash];
    } else if (self.flashMode == UIImagePickerControllerCameraFlashModeOn) {
        self.flashMode = UIImagePickerControllerCameraFlashModeOff;
        [self.portraitFlashButton setImage:[UIImage imageNamed:@"flash_button_off"] forState:UIControlStateNormal];
        [self.landscapeLeftFlashButton setImage:[UIImage imageNamed:@"left_flash_off"] forState:UIControlStateNormal];
        [self.landscapeLeftFlashButton setImage:[UIImage imageNamed:@"left_flash_off_pressed"] forState:UIControlStateHighlighted];
        [self.landscapeRightFlashButton setImage:[UIImage imageNamed:@"right_flash_off"] forState:UIControlStateNormal];
        [self.landscapeRightFlashButton setImage:[UIImage imageNamed:@"right_flash_off_pressed"] forState:UIControlStateHighlighted];
        [self.viewController toggleFlash];
    } else {
        self.flashMode = UIImagePickerControllerCameraFlashModeAuto;
        [self.portraitFlashButton setImage:[UIImage imageNamed:@"flash_button_auto"] forState:UIControlStateNormal];
        [self.landscapeLeftFlashButton setImage:[UIImage imageNamed:@"left_flash_auto"] forState:UIControlStateNormal];
        [self.landscapeLeftFlashButton setImage:[UIImage imageNamed:@"left_flash_auto_pressed"] forState:UIControlStateHighlighted];
        [self.landscapeRightFlashButton setImage:[UIImage imageNamed:@"right_flash_auto"] forState:UIControlStateNormal];
        [self.landscapeRightFlashButton setImage:[UIImage imageNamed:@"right_flash_auto_pressed"] forState:UIControlStateHighlighted];
        [self.viewController toggleFlash];
    }
}

-(IBAction)showFocusIndicator:(id)sender
{
    UIGestureRecognizer *gestureRecognizer = (UIGestureRecognizer *)sender;
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    UIView *portrait = (UIView *)[self viewWithTag:10];
    UIView *landscapeLeft = (UIView *)[self viewWithTag:20];
    UIView *landscapeRight = (UIView *)[self viewWithTag:30];
    
    [[self focusAnimation] stopAnimating];
    
    if (![portrait isHidden]) {
        UIView *focusIndicatorView = [portrait viewWithTag:14];
        [focusIndicatorView addSubview:[self focusAnimation]];
        [[self focusAnimation] setCenter:touchPoint];
        [[self focusAnimation] startAnimating];
    } else if (![landscapeLeft isHidden]) {
        UIView *focusIndicatorView = [landscapeLeft viewWithTag:24];
        [focusIndicatorView addSubview:[self focusAnimation]];
        [[self focusAnimation] setCenter:touchPoint];
        [[self focusAnimation] startAnimating];
    } else if (![landscapeRight isHidden]) {
        UIView *focusIndicatorView = [landscapeRight viewWithTag:34];
        [focusIndicatorView addSubview:[self focusAnimation]];
        [[self focusAnimation] setCenter:touchPoint];
        [[self focusAnimation] startAnimating];
    }
}

- (void)initializeFlash
{
    _flashMode = UIImagePickerControllerCameraFlashModeAuto;
    [_portraitFlashButton setImage:[UIImage imageNamed:@"flash_button_auto"] forState:UIControlStateNormal];
    [_landscapeLeftFlashButton setImage:[UIImage imageNamed:@"left_flash_auto"] forState:UIControlStateNormal];
    [_landscapeLeftFlashButton setImage:[UIImage imageNamed:@"left_flash_auto_pressed"] forState:UIControlStateHighlighted];
    [_landscapeRightFlashButton setImage:[UIImage imageNamed:@"right_flash_auto"] forState:UIControlStateNormal];
    [_landscapeRightFlashButton setImage:[UIImage imageNamed:@"right_flash_auto_pressed"] forState:UIControlStateHighlighted];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
