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

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

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
    
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"toolbar_gradient"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    //UIView *cameraOverlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil] objectAtIndex:0];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:NO];
    [imagePicker setShowsCameraControls:YES];
    //[imagePicker setCameraOverlayView:cameraOverlay];
    //[self presentViewController:imagePicker animated:YES completion:nil];
    //_imagePicker = imagePicker;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)save:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancel:self];
}

@end
