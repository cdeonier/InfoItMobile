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

@synthesize cameraOverlay = _cameraOverlay;
@synthesize imagePicker = _imagePicker;
@synthesize preview = _preview;

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
    [cameraOverlay setViewController:self];
    
    self.cameraOverlay = cameraOverlay;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationPortrait) {
        [self setPortraitView];
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {
        [self setLandscapeLeftView];
    } else {
        [self setLandscapeRightView];
    }

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [self setImagePicker:imagePicker];
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
    
    
    //For some reason, the orientation is reversed for landscape
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        [self setPortraitView];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self setLandscapeLeftView];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        [self setLandscapeRightView];
    }
}

- (void) setPortraitView
{
    UIView *portraitView = [self.cameraOverlay viewWithTag:10];
    [portraitView setHidden:NO];
    UIView *landscapeLeftView = [self.cameraOverlay viewWithTag:20];
    [landscapeLeftView setHidden:YES];
    UIView *landscapeRightView = [self.cameraOverlay viewWithTag:30];
    [landscapeRightView setHidden:YES];
}

- (void) setLandscapeLeftView
{
    UIView *portraitView = [self.cameraOverlay viewWithTag:10];
    [portraitView setHidden:YES];
    UIView *landscapeLeftView = [self.cameraOverlay viewWithTag:20];
    [landscapeLeftView setHidden:NO];
    UIView *landscapeRightView = [self.cameraOverlay viewWithTag:30];
    [landscapeRightView setHidden:YES];
}

- (void) setLandscapeRightView
{
    UIView *portraitView = [self.cameraOverlay viewWithTag:10];
    [portraitView setHidden:YES];
    UIView *landscapeLeftView = [self.cameraOverlay viewWithTag:20];
    [landscapeLeftView setHidden:YES];
    UIView *landscapeRightView = [self.cameraOverlay viewWithTag:30];
    [landscapeRightView setHidden:NO];
}


- (void)cancelPicture
{
    [[self imagePicker] dismissModalViewControllerAnimated:YES];
}

- (void)takePicture
{
    [self.imagePicker takePicture];
}

- (void)toggleFlash
{
    if ([self.imagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeAuto) {
        [self.imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
    } else if ([self.imagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeOn) {
        [self.imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
    } else {
        [self.imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeAuto];
    }
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[self imagePicker] dismissModalViewControllerAnimated:YES];
    UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIView *portraitView = [self.cameraOverlay viewWithTag:10];
    if (![portraitView isHidden]) {
        CGImageRef portraitImage = [self CGImageRotatedByAngle:[picture CGImage] angle:-90];
        CGFloat croppedImageOffset = CGImageGetHeight(portraitImage) * 115 / 426;
        CGFloat croppedImageHeight = CGImageGetHeight(portraitImage) * 240 / 426;
        CGFloat croppedImageWidth = CGImageGetWidth(portraitImage);
        CGImageRef imageRef = CGImageCreateWithImageInRect(portraitImage, CGRectMake(0, croppedImageOffset, croppedImageWidth, croppedImageHeight));
        UIImage *croppedPicture = [UIImage imageWithCGImage:imageRef];
        [self.preview setImage:croppedPicture];
    } else {
        [self.preview setImage:picture];
    }
}

//https://gist.github.com/585377
- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle
{
	CGFloat angleInRadians = angle * (M_PI / 180);
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
    
	CGRect imgRect = CGRectMake(0, 0, width, height);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL, rotatedRect.size.width, rotatedRect.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGContextSetAllowsAntialiasing(bmContext, YES);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(bmContext,
						  +(rotatedRect.size.width/2),
						  +(rotatedRect.size.height/2));
	CGContextRotateCTM(bmContext, angleInRadians);
	CGContextDrawImage(bmContext, CGRectMake(-width/2, -height/2, width, height),
					   imgRef);
    
	CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
	CFRelease(bmContext);
    
	return rotatedImage;
}

@end
