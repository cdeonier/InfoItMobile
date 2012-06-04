//
//  TakePhotoViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "TakePhotoViewController.h"
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "CameraOverlayView.h"
#import <QuartzCore/QuartzCore.h>
#import "IIViewDeckController.h"
#import "Photo.h"

@interface TakePhotoViewController ()

@end

NSInteger const CameraOverlayPortraitView = 10;
NSInteger const CameraFlashOverlayPortrait = 11;
NSInteger const CameraPortraitCancelButton = 12;
NSInteger const CameraPortraitDoneButton = 13;
NSInteger const CameraOverlayLandscapeLeftView = 20;
NSInteger const CameraFlashOverlayLandscapeLeft = 21;
NSInteger const CameraLandscapeLeftCancelButton = 22;
NSInteger const CameraLandscapeLeftDoneButton = 23;
NSInteger const CameraOverlayLandscapeRightView = 30;
NSInteger const CameraFlashOverlayLandscapeRight = 31;
NSInteger const CameraLandscapeRightCancelButton = 32;
NSInteger const CameraLandscapeRightDoneButton = 33;

@implementation TakePhotoViewController

@synthesize cameraOverlay = _cameraOverlay;
@synthesize portraitView = _portraitView;
@synthesize landscapeView = _landscapeView;
@synthesize imagePicker = _imagePicker;
@synthesize preview = _preview;
@synthesize dummyThumbs = _dummyThumbs;
@synthesize dummyImages = _dummyImages;
@synthesize landscapeGridView = _landscapeGridView;
@synthesize portraitGridView = _portraitGridView;
@synthesize locationManager = _locationManager;
@synthesize presentLocation = _presentLocation;

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
    
    [self setTitle:@"Select and Save"];
    
    self.portraitView = [[[NSBundle mainBundle] loadNibNamed:@"TakePhotoViewPortrait" owner:self options:nil] objectAtIndex:0];
    self.landscapeView = [[[NSBundle mainBundle] loadNibNamed:@"TakePhotoViewLandscape" owner:self options:nil] objectAtIndex:0];

    GMGridView *portraitGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 240, 320, 136)];
    portraitGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    portraitGridView.minEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    portraitGridView.dataSource = self;
    portraitGridView.actionDelegate = self;
    self.portraitGridView = portraitGridView;
    [self.portraitView addSubview:portraitGridView];
    
    GMGridView *landscapeGridView = [[GMGridView alloc] initWithFrame:CGRectMake(357, 0, 123, 228)];
    landscapeGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    landscapeGridView.minEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    landscapeGridView.dataSource = self;
    landscapeGridView.actionDelegate = self;
    self.landscapeGridView = landscapeGridView;
    [self.landscapeView addSubview:landscapeGridView];
    [self.landscapeView sendSubviewToBack:landscapeGridView];
    
    [self populateData];
    
    CameraOverlayView *cameraOverlay = [[CameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [cameraOverlay setViewController:self];
    
    self.cameraOverlay = cameraOverlay;
    
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (deviceOrientation == UIInterfaceOrientationPortrait) {
        [self setPortraitView];
    } else if (deviceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self setLandscapeLeftView];
    } else {
        [self setLandscapeRightView];
    }
    
    [self initializeLocationManager];

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [self setImagePicker:imagePicker];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:NO];
    [imagePicker setShowsCameraControls:NO];
    [imagePicker setCameraOverlayView:self.cameraOverlay];
    [self presentModalViewController:imagePicker animated:NO];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOrientation:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Need to disable ViewDeck scrolling because it interferes with gridview.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate disableNavigationMenu];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    //View disappears when presenting image picker-- but only stop locations when we leave actual view
    if ([self imagePicker] == nil) {
        [self finishUpdatingLocation];
    }
    
    //Anytime we're done with this view, we should be able to 
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate enableNavigationMenu];
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
    UIView *portraitView = [self.cameraOverlay viewWithTag:CameraOverlayPortraitView];
    [portraitView setHidden:NO];
    UIView *landscapeLeftView = [self.cameraOverlay viewWithTag:CameraOverlayLandscapeLeftView];
    [landscapeLeftView setHidden:YES];
    UIView *landscapeRightView = [self.cameraOverlay viewWithTag:CameraOverlayLandscapeRightView];
    [landscapeRightView setHidden:YES];
    
    self.view = self.portraitView;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if ([navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void) setLandscapeLeftView
{
    UIView *portraitView = [self.cameraOverlay viewWithTag:CameraOverlayPortraitView];
    [portraitView setHidden:YES];
    UIView *landscapeLeftView = [self.cameraOverlay viewWithTag:CameraOverlayLandscapeLeftView];
    [landscapeLeftView setHidden:NO];
    UIView *landscapeRightView = [self.cameraOverlay viewWithTag:CameraOverlayLandscapeRightView];
    [landscapeRightView setHidden:YES];
    
    self.view = self.landscapeView;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if ([navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background_landscape"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void) setLandscapeRightView
{
    UIView *portraitView = [self.cameraOverlay viewWithTag:CameraOverlayPortraitView];
    [portraitView setHidden:YES];
    UIView *landscapeLeftView = [self.cameraOverlay viewWithTag:CameraOverlayLandscapeLeftView];
    [landscapeLeftView setHidden:YES];
    UIView *landscapeRightView = [self.cameraOverlay viewWithTag:CameraOverlayLandscapeRightView];
    [landscapeRightView setHidden:NO];
    
    self.view = self.landscapeView;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if ([navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background_landscape"] forBarMetrics:UIBarMetricsDefault];
    }
}


- (void)cancelPicture
{
    [[self imagePicker] dismissModalViewControllerAnimated:YES];
    [self setImagePicker:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)donePicture
{
    [[self imagePicker] dismissModalViewControllerAnimated:YES];
    [self setImagePicker:nil];
}

- (void)takePicture
{
    if (![[self.cameraOverlay viewWithTag:CameraOverlayPortraitView] isHidden]) {
        [self setCancelAndDoneButtons];
        
        UIView *portraitFlashOverlay = [self.cameraOverlay viewWithTag:CameraFlashOverlayPortrait];
        [portraitFlashOverlay setAlpha:1.0f];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [portraitFlashOverlay setAlpha:0.0f];
        [UIView commitAnimations];
    } else if (![[self.cameraOverlay viewWithTag:CameraOverlayLandscapeLeftView] isHidden]) {
        [self setCancelAndDoneButtons];
        
        UIView *portraitFlashOverlay = [self.cameraOverlay viewWithTag:CameraFlashOverlayLandscapeLeft];
        [portraitFlashOverlay setAlpha:1.0f];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [portraitFlashOverlay setAlpha:0.0f];
        [UIView commitAnimations];
    } else if (![[self.cameraOverlay viewWithTag:CameraOverlayLandscapeRightView] isHidden]) {
        [self setCancelAndDoneButtons];
        
        UIView *portraitFlashOverlay = [self.cameraOverlay viewWithTag:CameraFlashOverlayLandscapeRight];
        [portraitFlashOverlay setAlpha:1.0f];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [portraitFlashOverlay setAlpha:0.0f];
        [UIView commitAnimations];
    }
    
    
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

- (void)setCancelAndDoneButtons
{
    UIButton *portraitDoneButton = (UIButton *)[[self.cameraOverlay viewWithTag:CameraOverlayPortraitView] viewWithTag:CameraPortraitDoneButton];
    if ([portraitDoneButton isHidden]) {
        UIButton *landscapeLeftDoneButton = (UIButton *)[[self.cameraOverlay viewWithTag:CameraOverlayLandscapeLeftView] viewWithTag:CameraLandscapeLeftDoneButton];
        UIButton *landscapeRightDoneButton = (UIButton *)[[self.cameraOverlay viewWithTag:CameraOverlayLandscapeRightView] viewWithTag:CameraLandscapeRightDoneButton];
        UIButton *portraitCancelButton = (UIButton *)[[self.cameraOverlay viewWithTag:CameraOverlayPortraitView] viewWithTag:CameraPortraitCancelButton];
        UIButton *landscapeLeftCancelButton = (UIButton *)[[self.cameraOverlay viewWithTag:CameraOverlayLandscapeLeftView] viewWithTag:CameraLandscapeLeftCancelButton];
        UIButton *landscapeRightCancelButton = (UIButton *)[[self.cameraOverlay viewWithTag:CameraOverlayLandscapeRightView] viewWithTag:CameraLandscapeRightCancelButton];
        [portraitDoneButton setHidden:NO];
        [landscapeLeftDoneButton setHidden:NO];
        [landscapeRightDoneButton setHidden:NO];
        [portraitCancelButton setHidden:YES];
        [landscapeLeftCancelButton setHidden:YES];
        [landscapeRightCancelButton setHidden:YES];
    }
}

- (void)populateData
{
    self.dummyThumbs = [[NSMutableArray alloc] initWithCapacity:20];
    [self.dummyThumbs addObject:[UIImage imageNamed:@"1.jpg"]];
    [self.dummyThumbs addObject:[UIImage imageNamed:@"2.jpg"]];
    [self.dummyThumbs addObject:[UIImage imageNamed:@"3.jpg"]];
    [self.dummyThumbs addObject:[UIImage imageNamed:@"4.jpg"]];
    [self.dummyThumbs addObject:[UIImage imageNamed:@"5.jpg"]];
    [self.dummyThumbs addObject:[UIImage imageNamed:@"6.jpg"]];
    [self.portraitGridView reloadData];
    [self.landscapeGridView reloadData];
    
    self.dummyImages = [[NSMutableArray alloc] initWithCapacity:10];
    [self.dummyImages addObject:[UIImage imageNamed:@"1_1.jpg"]];
    [self.dummyImages addObject:[UIImage imageNamed:@"2_2.jpg"]];
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //[[self imagePicker] dismissModalViewControllerAnimated:YES];
    NSLog(@"Called didFinishPickingMediaWithInfo");
    
//    UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
//    UIView *portraitView = [self.cameraOverlay viewWithTag:CameraOverlayPortraitView];
//    if (![portraitView isHidden]) {
//        CGImageRef portraitImage = [self CGImageRotatedByAngle:[picture CGImage] angle:-90];
//        CGFloat croppedImageOffset = CGImageGetHeight(portraitImage) * 115 / 426;
//        CGFloat croppedImageHeight = CGImageGetHeight(portraitImage) * 240 / 426;
//        CGFloat croppedImageWidth = CGImageGetWidth(portraitImage);
//        CGImageRef imageRef = CGImageCreateWithImageInRect(portraitImage, CGRectMake(0, croppedImageOffset, croppedImageWidth, croppedImageHeight));
//        UIImage *croppedPicture = [UIImage imageWithCGImage:imageRef];
//        
//        CLLocation *location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
//        [Photo uploadPhotoAtLocation:location image:croppedPicture];
//    } else {
//        
//    }
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

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.dummyThumbs count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(100, 100);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[GMGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        UIImageView *thumbnail = [[UIImageView alloc] initWithImage:[self.dummyThumbs objectAtIndex:index]];
        [thumbnail.layer setMasksToBounds:YES];
        [thumbnail.layer setCornerRadius:5];
        [thumbnail.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [thumbnail.layer setBorderWidth:1.0];
        
        cell.contentView = thumbnail;
    }
    
    [(UIImageView *)cell.contentView setImage:[self.dummyThumbs objectAtIndex:index]];
    
    return cell;
}

#pragma mark GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    UIImageView *previewImagePortrait = (UIImageView *)[self.portraitView viewWithTag:1];
    UIImageView *previewImageLandscape = (UIImageView *)[self.landscapeView viewWithTag:1];
    
    [previewImagePortrait setImage:[self.dummyImages objectAtIndex:position]];
    [previewImageLandscape setImage:[self.dummyImages objectAtIndex:position]];
}

#pragma mark Location

#pragma mark Location

- (void)initializeLocationManager 
{
    if (nil == [self locationManager])
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    [self performSelector:@selector(finishUpdatingLocation) withObject:nil afterDelay:20.0];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    /* Refuse updates more than an hour old */
    if (abs([newLocation.timestamp timeIntervalSinceNow]) > 3600.0) {
        return;
    }
    /* Save the new location to an instance variable */
    [self setPresentLocation:newLocation];
    
    /* If it's accurate enough (<=10m), cancel the timer */
    if (newLocation.horizontalAccuracy <= 10.0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self 
                                                 selector:@selector(finishUpdatingLocation) 
                                                   object:nil];
        /* And fire it manually instead */
        [self finishUpdatingLocation];
    }
}

- (void)finishUpdatingLocation 
{
    [[self locationManager] stopUpdatingLocation];
}

@end
