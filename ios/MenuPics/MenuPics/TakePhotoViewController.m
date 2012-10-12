//
//  TakePhotoViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/7/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "TakePhotoViewController.h"

#import "MenuItem.h"
#import "Photo.h"

@interface TakePhotoViewController ()

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UIButton *flashAutoButton;
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;
@property (weak, nonatomic) IBOutlet UIButton *flashOffButton;
@property (weak, nonatomic) IBOutlet UIButton *flashAutoButton5;
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton5;
@property (weak, nonatomic) IBOutlet UIButton *flashOffButton5;
@property (weak, nonatomic) IBOutlet UIView *viewFinder;
@property (weak, nonatomic) IBOutlet UIView *cropView;
@property (strong, nonatomic) UIView *overlayView;


@property (nonatomic) BOOL didTakePhoto;


- (IBAction)pressFlashAuto:(id)sender;
- (IBAction)pressFlashOn:(id)sender;
- (IBAction)pressFlashOff:(id)sender;

- (IBAction)done:(id)sender;

@end


@implementation TakePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setHidden:YES];
    
    [self performSelector:@selector(startImagePicker) withObject:nil afterDelay:0.5];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)pressFlashAuto:(id)sender
{
    _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    [self.flashAutoButton setHidden:YES];
    [self.flashAutoButton5 setHidden:YES];
    [self.flashOnButton setHidden:NO];
    [self.flashOnButton5 setHidden:NO];
}

- (IBAction)pressFlashOn:(id)sender
{
    _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    [self.flashOnButton setHidden:YES];
    [self.flashOnButton5 setHidden:YES];
    [self.flashOffButton setHidden:NO];
    [self.flashOffButton5 setHidden:NO];
}

- (IBAction)pressFlashOff:(id)sender
{
    _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    [self.flashOffButton setHidden:YES];
    [self.flashOffButton5 setHidden:YES];
    [self.flashAutoButton setHidden:NO];
    [self.flashAutoButton5 setHidden:NO];
}


- (IBAction)done:(id)sender
{
    [self.delegate didTakePhoto:self];
}

#pragma mark Helper Functions

- (void)startImagePicker
{
    int displayHeight = [UIScreen mainScreen].bounds.size.height;
    UIView *overlay;
    if (displayHeight == 568) {
        //iPhone 5
        overlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView5" owner:self options:nil] objectAtIndex:0];
    } else {
        overlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil] objectAtIndex:0];
    }
    self.overlayView = overlay;
    [self.overlayView setHidden:YES];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:NO];
    [imagePicker setShowsCameraControls:YES];
    [imagePicker setCameraOverlayView:overlay];
    self.imagePicker = imagePicker;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:nil object:nil];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    [self presentViewController:imagePicker animated:YES completion:^{
        [self.view setHidden:NO];
        
        while ([currentDevice isGeneratingDeviceOrientationNotifications]) {
            [currentDevice endGeneratingDeviceOrientationNotifications];
        }
    }];
}

- (void)revealCameraControls
{
    //[self.viewFinder setBackgroundColor:[UIColor clearColor]];
    
    if (self.imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeAuto) {
        [self.flashAutoButton setHidden:NO];
        [self.flashAutoButton5 setHidden:NO];
    } else if (self.imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn) {
        [self.flashOnButton setHidden:NO];
        [self.flashOnButton5 setHidden:NO];
    } else {
        [self.flashOffButton setHidden:NO];
        [self.flashOffButton5 setHidden:NO];
    }
    
}

- (void)hideCameraControls
{
    [self.flashAutoButton setHidden:YES];
    [self.flashAutoButton5 setHidden:YES];
    [self.flashOnButton setHidden:YES];
    [self.flashOnButton5 setHidden:YES];
    [self.flashOffButton setHidden:YES];
    [self.flashOffButton5 setHidden:YES];
}

- (void)notificationReceived:(NSNotification *)notification
{
    // We started the image picker.  This reveals the overlay after the closed-iris is displayed
    // on the screen, giving the appearance we're "opening" to the overlay view.
    if ([notification.name isEqualToString:@"PLCameraControllerPreviewStartedNotification"]) {
        [self.overlayView setHidden:NO];
        [self revealCameraControls];
    }
    
    // We pressed the camera button to take a picture.  We introduce a slight delay to remove the
    // jerkiness of taking away the overlay view.  We hid the overlay view to show the full iris
    // closing, else the overlay view obstructs the view of the top and bottom of the iris.
    if ([notification.name isEqualToString:@"Recorder_WillCapturePhoto"]) {
        [self performSelector:@selector(hideCameraOverlay) withObject:nil afterDelay:0.1];
    }
    
    // We successfully took the picture, and the iris is closed.  Now we show the overlay view again,
    // minus the camera controls because the button should not be pressable in the preview mode.
    if ([notification.name isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        [self.overlayView setHidden:NO];
        [self hideCameraControls];
    }
    
    // We rejected the previewed photo, so back to camera mode.  Show the camera controls again
    if ([notification.name isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        [self revealCameraControls];
    }
    
    // Application is closing, hide overlay to prevent it covering iris when we resume
    if ([notification.name isEqualToString:@"UIApplicationSuspendedNotification"]) {
        [self.overlayView setHidden:YES];
    }
}

- (void)hideCameraOverlay
{
    [self.overlayView setHidden:YES];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *cameraImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //Width is relative-- imagepicker thinks "up" as if the image is in landscape view
    int viewfinderWidth = 240;
    int cropWidth = 93;
    int overlayWidth = 426;
    
    CGImageRef cameraImageRef = cameraImage.CGImage;
    CGFloat croppedImageOffset = CGImageGetWidth(cameraImageRef) * cropWidth / overlayWidth;
    CGFloat croppedImageHeight = CGImageGetWidth(cameraImageRef) * viewfinderWidth / overlayWidth;
    CGFloat croppedImageWidth = CGImageGetHeight(cameraImageRef);
    //Since cropped image is presently on it's side, reverse x & y to draw it in the right box shape
    CGImageRef imageRef = CGImageCreateWithImageInRect(cameraImageRef, CGRectMake(croppedImageOffset, 0, croppedImageHeight, croppedImageWidth));
    UIImage *croppedCameraImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:cameraImage.imageOrientation];
    
    CGSize scaledSize = CGSizeMake(1024, 768);
    UIGraphicsBeginImageContext(scaledSize);
    [croppedCameraImage drawInRect:CGRectMake(0,0,scaledSize.width,scaledSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.previewImage setImage:scaledImage];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //Create thumbnail
        CGFloat height = scaledImage.size.height;
        CGFloat offset = (scaledImage.size.width - scaledImage.size.height) / 2;
        CGImageRef preThumbnailSquare = CGImageCreateWithImageInRect(scaledImage.CGImage, CGRectMake(offset, 0, height, height));
        
        //For Selecting Photos
        CGSize thumbnailSize = CGSizeMake(200, 200);
        UIGraphicsBeginImageContext(thumbnailSize);
        [[UIImage imageWithCGImage:preThumbnailSquare] drawInRect:CGRectMake(0,0,thumbnailSize.width,thumbnailSize.height)];
        UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.photo = [Photo didTakeNewPhoto:self.menuItem image:scaledImage thumbnail:thumbnail];
    });
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
