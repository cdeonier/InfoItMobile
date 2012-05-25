//
//  TakePhotoViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "TakePhotoViewController.h"

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
    
    [self setCaptureSessionManager:[[CaptureSessionManager alloc] init]];
    [[self captureSessionManager] addVideoInput];
    [[self captureSessionManager] addVideoPreviewLayer];
    CGRect layerRect = [[[self view] layer] bounds];
	[[[self captureSessionManager] previewLayer] setBounds:layerRect];
	[[[self captureSessionManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                         CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureSessionManager] previewLayer]];
    [[self.captureSessionManager captureSession] startRunning];
    
    [[self.navigationController navigationBar] setHidden:YES];
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

@end
