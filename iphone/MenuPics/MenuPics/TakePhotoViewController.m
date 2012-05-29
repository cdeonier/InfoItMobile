//
//  TakePhotoViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "TakePhotoViewController.h"
#import "CameraOverlayView.h"

@interface TakePhotoViewController ()

@end

@implementation TakePhotoViewController

@synthesize captureSessionManager = _captureSessionManager;
@synthesize cameraOverlay = _cameraOverlay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CameraOverlayView *cameraOverlay = [[CameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIView *landscapeOverlay = (UIView *)[cameraOverlay viewWithTag:20];
    [landscapeOverlay setHidden:YES];
    
    self.cameraOverlay = cameraOverlay;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:NO];
    [imagePicker setShowsCameraControls:NO];
    [imagePicker setCameraOverlayView:self.cameraOverlay];
    [self presentModalViewController:imagePicker animated:YES];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOrientation:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) didOrientation: (id)object 
{
    UIInterfaceOrientation interfaceOrientation = [[object object] orientation];
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        UIView *portraitView = [self.cameraOverlay viewWithTag:10];
        [portraitView setHidden:NO];
        UIView *landscapeView = [self.cameraOverlay viewWithTag:20];
        [landscapeView setHidden:YES];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        UIView *portraitView = [self.cameraOverlay viewWithTag:10];
        [portraitView setHidden:YES];
        UIView *landscapeView = [self.cameraOverlay viewWithTag:20];
        [landscapeView setHidden:NO];
        UIButton *cameraButton = (UIButton *)[landscapeView viewWithTag:4];
        [cameraButton setImage:[UIImage imageNamed:@"camera_button_ccw"] forState:UIControlStateNormal];
        [cameraButton setImage:[UIImage imageNamed:@"camera_button_ccw_pressed"] forState:UIControlStateHighlighted];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ){
        UIView *portraitView = [self.cameraOverlay viewWithTag:10];
        [portraitView setHidden:YES];
        UIView *landscapeView = [self.cameraOverlay viewWithTag:20];
        [landscapeView setHidden:NO];
        UIButton *cameraButton = (UIButton *)[landscapeView viewWithTag:4];
        [cameraButton setImage:[UIImage imageNamed:@"camera_button_cw"] forState:UIControlStateNormal];
        [cameraButton setImage:[UIImage imageNamed:@"camera_button_cw_pressed"] forState:UIControlStateHighlighted];
    }
}


- (void) cancelPhoto
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController popViewControllerAnimated:YES];

}

@end
