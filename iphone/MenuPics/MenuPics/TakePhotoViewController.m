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
#import "SVProgressHUD.h"
#import "ImageUtil.h"

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
@synthesize photos = _photos;
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
    portraitGridView.minEdgeInsets = UIEdgeInsetsMake(18, 10, 18, 10);
    portraitGridView.centerGrid = NO;
    portraitGridView.dataSource = self;
    portraitGridView.actionDelegate = self;
    self.portraitGridView = portraitGridView;
    [self.portraitView addSubview:portraitGridView];
    
    GMGridView *landscapeGridView = [[GMGridView alloc] initWithFrame:CGRectMake(357, 0, 123, 228)];
    landscapeGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    landscapeGridView.minEdgeInsets = UIEdgeInsetsMake(5, 11, 5, 12);
    landscapeGridView.centerGrid = NO;
    landscapeGridView.dataSource = self;
    landscapeGridView.actionDelegate = self;
    self.landscapeGridView = landscapeGridView;
    [self.landscapeView addSubview:landscapeGridView];
    [self.landscapeView sendSubviewToBack:landscapeGridView];
    
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
    
    [self setPhotos:[[NSMutableArray alloc] initWithCapacity:20]];
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

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Called didFinishPickingMediaWithInfo");
    /* 
     * Basically 3 tasks that need to be done, each with their own async:
     *
     * 1) If this is the first photo, we need to update the preview image.
     * 2) We need create thumbnail images to add to gridview.
     * 3) We need to save the images to cache directory, in preparation for Save Photos.
     *
     */
    
    //Update preview image, if necessary
    if ([self.photos count] == 0) {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //Crop image if portrait view
            UIImage *photoImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            if (![[self.cameraOverlay viewWithTag:CameraOverlayPortraitView] isHidden]) {
                CGSize scaledSize = CGSizeMake(852, 640);
                UIGraphicsBeginImageContext(scaledSize);
                [photoImage drawInRect:CGRectMake(0,0,scaledSize.width,scaledSize.height)];
                UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                CGImageRef portraitImage = scaledImage.CGImage;
                CGFloat croppedImageOffset = CGImageGetHeight(portraitImage) * 115 / 426;
                CGFloat croppedImageHeight = CGImageGetHeight(portraitImage) * 240 / 426;
                CGFloat croppedImageWidth = CGImageGetWidth(portraitImage);
                CGImageRef imageRef = CGImageCreateWithImageInRect(portraitImage, CGRectMake(0, croppedImageOffset, croppedImageWidth, croppedImageHeight));
                photoImage = [UIImage imageWithCGImage:imageRef];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *portraitPreview = (UIImageView *)[self.portraitView viewWithTag:1];
                UIImageView *landscapePreview = (UIImageView *)[self.landscapeView viewWithTag:1];
                [portraitPreview setImage:photoImage];
                [landscapePreview setImage:photoImage];
            });
        });
    }
    
    Photo *photo = [[Photo alloc] init];
    [self.photos addObject:photo];

    //Save image to disk & create thumbnail
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *photoImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //Crop if portrait
        if (![[self.cameraOverlay viewWithTag:CameraOverlayPortraitView] isHidden]) {
            //Expensive rotation, ~1.5-2s
            CGImageRef portraitImage = [self CGImageRotatedByAngle:[photoImage CGImage] angle:-90];
            
            CGFloat croppedImageOffset = CGImageGetHeight(portraitImage) * 115 / 426;
            CGFloat croppedImageHeight = CGImageGetHeight(portraitImage) * 240 / 426;
            CGFloat croppedImageWidth = CGImageGetWidth(portraitImage);
            CGImageRef imageRef = CGImageCreateWithImageInRect(portraitImage, CGRectMake(0, croppedImageOffset, croppedImageWidth, croppedImageHeight));
            photoImage = [UIImage imageWithCGImage:imageRef];
        }
        
        //Then save to disk
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        });
        
        //Create thumbnail
        CGFloat height = photoImage.size.height;
        CGFloat offset = (photoImage.size.width - photoImage.size.height) / 2;
        CGImageRef preThumbnailSquare = CGImageCreateWithImageInRect(photoImage.CGImage, CGRectMake(offset, 0, height, height));
        
        //Compress to thumbnail size (expensive, ~0.5-1s)
        CGSize thumbnailSize = CGSizeMake(200, 200);
        UIGraphicsBeginImageContext(thumbnailSize);
        [[UIImage imageWithCGImage:preThumbnailSquare] drawInRect:CGRectMake(0,0,thumbnailSize.width,thumbnailSize.height)];
        UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [photo setThumbnail:thumbnail];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.portraitGridView reloadData];
            [self.landscapeGridView reloadData];
        });
    });
                   
    //Create Thumbnail and add to gridview
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Crop if portrait
        if (![[self.cameraOverlay viewWithTag:CameraOverlayPortraitView] isHidden]) {
            
        }
        
        //Then save
    });
               
                   
                   
    
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
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
	CGContextDrawImage(bmContext, CGRectMake(-width/2, -height/2, width, height),
					   imgRef);
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"Draw operation took %2.5f seconds", end-start);
	CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
	CFRelease(bmContext);
    
	return rotatedImage;
}

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.photos count];
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
        
        UIImageView *thumbnail = [[UIImageView alloc] initWithImage:[[self.photos objectAtIndex:index] thumbnail]];
        [thumbnail.layer setMasksToBounds:YES];
        [thumbnail.layer setCornerRadius:5];
        [thumbnail.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [thumbnail.layer setBorderWidth:1.0];
        
        cell.contentView = thumbnail;
    }
    
    [(UIImageView *)cell.contentView setImage:[[self.photos objectAtIndex:index] thumbnail]];
    
    return cell;
}

#pragma mark GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    UIImageView *previewImagePortrait = (UIImageView *)[self.portraitView viewWithTag:1];
    UIImageView *previewImageLandscape = (UIImageView *)[self.landscapeView viewWithTag:1];
    
    //[previewImagePortrait setImage:[self.dummyImages objectAtIndex:position]];
    //[previewImageLandscape setImage:[self.dummyImages objectAtIndex:position]];
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
