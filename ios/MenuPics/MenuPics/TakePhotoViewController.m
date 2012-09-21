//
//  TakePhotoViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/7/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "TakePhotoViewController.h"

@interface TakePhotoViewController ()

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UIButton *flashAutoButton;
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;
@property (weak, nonatomic) IBOutlet UIButton *flashOffButton;
@property (weak, nonatomic) IBOutlet UIView *viewFinder;

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
    
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"toolbar_gradient"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    self.photo = [UIImage imageNamed:@"photo"];
    [self.previewImage setImage:self.photo];
    
    [self performSelector:@selector(startImagePicker) withObject:nil afterDelay:0.01];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)pressFlashAuto:(id)sender
{
    _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    [self.flashAutoButton setHidden:YES];
    [self.flashOnButton setHidden:NO];
}

- (IBAction)pressFlashOn:(id)sender
{
    _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    [self.flashOnButton setHidden:YES];
    [self.flashOffButton setHidden:NO];
}

- (IBAction)pressFlashOff:(id)sender
{
    _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    [self.flashOffButton setHidden:YES];
    [self.flashAutoButton setHidden:NO];
}


- (IBAction)done:(id)sender
{
    [self.delegate didTakePhoto:self];
}

#pragma mark Helper Functions

- (void)startImagePicker
{
    UIView *overlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil] objectAtIndex:0];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:NO];
    [imagePicker setShowsCameraControls:YES];
    [imagePicker setCameraOverlayView:overlay];
    [self presentViewController:imagePicker animated:YES completion:^{
        [self.view setHidden:NO];
        [self performSelector:@selector(revealCameraControls) withObject:nil afterDelay:0.2];
    }];
    _imagePicker = imagePicker;
}

- (void)revealCameraControls
{
    [self.viewFinder setBackgroundColor:[UIColor clearColor]];
    [self.flashAutoButton setHidden:NO];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
