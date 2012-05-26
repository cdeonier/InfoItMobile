//
//  TakePhotoViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "TakePhotoViewController.h"
#import "IIViewDeckController.h"

@interface TakePhotoViewController ()

@end

@implementation TakePhotoViewController

@synthesize captureSessionManager = _captureSessionManager;

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
    
    [self wantsFullScreenLayout];

    [self.view.layer setBorderColor:[UIColor blueColor].CGColor];
    [self.view.layer setBorderWidth:1.0f];  


    [self setCaptureSessionManager:[[CaptureSessionManager alloc] init]];
    [[self captureSessionManager] addVideoInput];
    [[self captureSessionManager] addVideoPreviewLayer];

    
    [[self.captureSessionManager captureSession] startRunning];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self initPortraitUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.viewDeckController.view.frame = [[UIScreen mainScreen] applicationFrame];
    [self.viewDeckController.view setNeedsDisplay];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [self initLandscapeUI];
    }
    else
    {
        [self initPortraitUI];
    }
}

- (void) initPortraitUI
{
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview]; 
    }
    
    CGRect layerRect = [[[self view] layer] bounds];
	[[[self captureSessionManager] previewLayer] setBounds:layerRect];
	[[[self captureSessionManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                         CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureSessionManager] previewLayer]];
    
    //Crop image
    UIView *topCrop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    [topCrop setBackgroundColor:[UIColor blackColor]];
    [[self view] addSubview:topCrop];
    
    UIView *bottomCrop = [[UIView alloc] initWithFrame:CGRectMake(0, 360, 320, 120)];
    [bottomCrop setBackgroundColor:[UIColor blackColor]];
    [[self view] addSubview:bottomCrop];

    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setFrame:CGRectMake(0, 0, 45, 45)];
    [[self view] addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(cancelPhoto) forControlEvents:UIControlEventTouchUpInside];
}

- (void) initLandscapeUI
{
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview]; 
    }
    
    CGRect layerRect = [[[self view] layer] bounds];
	[[[self captureSessionManager] previewLayer] setBounds:layerRect];
	[[[self captureSessionManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                         CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureSessionManager] previewLayer]];
}

- (void) cancelPhoto
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController popViewControllerAnimated:YES];

}

@end
