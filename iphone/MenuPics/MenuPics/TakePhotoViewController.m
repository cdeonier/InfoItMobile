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
#import "UIColor+ExtendedColor.h"

@interface TakePhotoViewController ()

@end

NSInteger const CameraOverlayPortraitView = 10;
NSInteger const CameraFlashOverlayPortrait = 11;
NSInteger const CameraOverlayLandscapeLeftView = 20;
NSInteger const CameraFlashOverlayLandscapeLeft = 21;
NSInteger const CameraOverlayLandscapeRightView = 30;
NSInteger const CameraFlashOverlayLandscapeRight = 31;


@implementation TakePhotoViewController

@synthesize displayedPhotoIndex = _displayedPhotoIndex;
@synthesize cameraOverlay = _cameraOverlay;
@synthesize portraitView = _portraitView;
@synthesize landscapeView = _landscapeView;
@synthesize imagePicker = _imagePicker;
@synthesize preview = _preview;
@synthesize photos = _photos;
@synthesize landscapeGridView = _landscapeGridView;
@synthesize portraitGridView = _portraitGridView;
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;

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
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(startImagePicker)];
    cameraButton.tintColor = [UIColor navBarButtonColor];
    self.navigationItem.rightBarButtonItem = cameraButton;
    
    [self setPortraitView:[[[NSBundle mainBundle] loadNibNamed:@"TakePhotoViewPortrait" owner:self options:nil] objectAtIndex:0]];
    [self setLandscapeView:[[[NSBundle mainBundle] loadNibNamed:@"TakePhotoViewLandscape" owner:self options:nil] objectAtIndex:0]];
    [self initializeGridViews];
    [self setPhotos:[[NSMutableArray alloc] initWithCapacity:20]];
    
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
    [self startImagePicker];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOrientation:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [self clearTakePhotosDirectory];
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

- (void)startImagePicker
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [self setImagePicker:imagePicker];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:NO];
    [imagePicker setShowsCameraControls:NO];
    [imagePicker setCameraOverlayView:self.cameraOverlay];
    [self presentModalViewController:imagePicker animated:NO];
}

- (void)takePicture
{
    [self.imagePicker takePicture];
    
    if (![[self.cameraOverlay viewWithTag:CameraOverlayPortraitView] isHidden]) {
        UIView *portraitFlashOverlay = [self.cameraOverlay viewWithTag:CameraFlashOverlayPortrait];
        [portraitFlashOverlay setAlpha:1.0f];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [portraitFlashOverlay setAlpha:0.0f];
        [UIView commitAnimations];
    } else if (![[self.cameraOverlay viewWithTag:CameraOverlayLandscapeLeftView] isHidden]) {
        UIView *portraitFlashOverlay = [self.cameraOverlay viewWithTag:CameraFlashOverlayLandscapeLeft];
        [portraitFlashOverlay setAlpha:1.0f];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [portraitFlashOverlay setAlpha:0.0f];
        [UIView commitAnimations];
    } else if (![[self.cameraOverlay viewWithTag:CameraOverlayLandscapeRightView] isHidden]) {
        UIView *portraitFlashOverlay = [self.cameraOverlay viewWithTag:CameraFlashOverlayLandscapeRight];
        [portraitFlashOverlay setAlpha:1.0f];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [portraitFlashOverlay setAlpha:0.0f];
        [UIView commitAnimations];
    }
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

- (void)clearTakePhotosDirectory 
{
    NSFileManager *filemgr =[NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *takePhotosDirectory = [docsDir stringByAppendingPathComponent:@"takePhotos"];
    NSArray *fileList = [filemgr contentsOfDirectoryAtPath:takePhotosDirectory error:NULL];
    int count = [fileList count];
    for (int i = 0; i < count; i++)
        [filemgr removeItemAtPath:[takePhotosDirectory stringByAppendingPathComponent:[fileList objectAtIndex:i]] error:nil];
}

- (IBAction)toggleSelectionBox:(id)sender
{
    Photo *previewedPhoto = [self.photos objectAtIndex:self.displayedPhotoIndex];
    [previewedPhoto setIsSelected:![previewedPhoto isSelected]];
    
    if ([previewedPhoto isSelected]) {
        [(UIButton *)[self.landscapeView viewWithTag:2] setImage:[UIImage imageNamed:@"selected_picture_yes"] forState:UIControlStateNormal];
        [(UIButton *)[self.portraitView viewWithTag:2] setImage:[UIImage imageNamed:@"selected_picture_yes"] forState:UIControlStateNormal];
    } else {
        [(UIButton *)[self.landscapeView viewWithTag:2] setImage:[UIImage imageNamed:@"selected_picture_no"] forState:UIControlStateNormal];
        [(UIButton *)[self.portraitView viewWithTag:2] setImage:[UIImage imageNamed:@"selected_picture_no"] forState:UIControlStateNormal];  
    }
    
    [self.portraitGridView reloadData];
    [self.landscapeGridView reloadData];
}

- (void)initializeGridViews
{
    GMGridView *portraitGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 240, 320, 136)];
    portraitGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    portraitGridView.minEdgeInsets = UIEdgeInsetsMake(13, 10, 13, 10);
    portraitGridView.centerGrid = NO;
    portraitGridView.dataSource = self;
    portraitGridView.actionDelegate = self;
    self.portraitGridView = portraitGridView;
    [self.portraitView addSubview:portraitGridView];
    
    GMGridView *landscapeGridView = [[GMGridView alloc] initWithFrame:CGRectMake(357, 0, 123, 228)];
    landscapeGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    landscapeGridView.minEdgeInsets = UIEdgeInsetsMake(5, 6, 5, 7);
    landscapeGridView.centerGrid = NO;
    landscapeGridView.dataSource = self;
    landscapeGridView.actionDelegate = self;
    self.landscapeGridView = landscapeGridView;
    [self.landscapeView addSubview:landscapeGridView];
    [self.landscapeView sendSubviewToBack:landscapeGridView];
}

- (IBAction)savePhotos:(id)sender
{    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *photosDirectory = [docsDir stringByAppendingPathComponent:@"photos"];
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    for (Photo *photo in self.photos) {
        if ([photo isSelected]) {
            [fileManager moveItemAtPath:[photo fileLocation] toPath:[photosDirectory stringByAppendingPathComponent:[photo fileName]] error:nil];
            [photo setFileLocation:[photosDirectory stringByAppendingPathComponent:[photo fileName]]];
        }
    }
    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"Move operation took %2.5f seconds", end-start);
    
    NSIndexSet *indexSet = [self.photos indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [(Photo *)obj isSelected]; 
    }];
    NSArray *selectedPhotos = [self.photos objectsAtIndexes:indexSet];
    NSLog(@"Selected photos count: %i", [selectedPhotos count]);
    
    [Photo savePhotos:selectedPhotos creationDate:[NSDate date] creationLocation:[self currentLocation]];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Basic steps: Take original image and scale it down (cropping if necessary for portrait, which will take ~50% longer because of rotation)
    //If first image, set preview image to scaled image
    //Save image to disk on its own async
    //Create a thumbnail and add to gridview
    UIImage *cameraImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *scaledImage;
        
        if ([cameraImage imageOrientation] == UIImageOrientationUp || [cameraImage imageOrientation] == UIImageOrientationDown) {
            CGSize scaledSize = CGSizeMake(1024, 768);
            UIGraphicsBeginImageContext(scaledSize);
            [cameraImage drawInRect:CGRectMake(0,0,scaledSize.width,scaledSize.height)];
            scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        } else {
            //We're doing the cropping as if the image is on its side because orientation gets lost.
            CGImageRef cameraImageRef = cameraImage.CGImage;
            CGFloat croppedImageOffset = CGImageGetWidth(cameraImageRef) * 115 / 426;
            CGFloat croppedImageHeight = CGImageGetWidth(cameraImageRef) * 240 / 426;
            CGFloat croppedImageWidth = CGImageGetHeight(cameraImageRef);
            //Since cropped image is presently on it's side, reverse x & y to draw it in the right box shape
            CGImageRef imageRef = CGImageCreateWithImageInRect(cameraImageRef, CGRectMake(croppedImageOffset, 0, croppedImageHeight, croppedImageWidth));
            UIImage *croppedCameraImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:cameraImage.imageOrientation];
            
            CGSize scaledSize = CGSizeMake(1024, 768);
            UIGraphicsBeginImageContext(scaledSize);
            [croppedCameraImage drawInRect:CGRectMake(0,0,scaledSize.width,scaledSize.height)];
            scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        if ([self.photos count] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setDisplayedPhotoIndex:0];
                
                UIImageView *portraitPreview = (UIImageView *)[self.portraitView viewWithTag:1];
                UIImageView *landscapePreview = (UIImageView *)[self.landscapeView viewWithTag:1];
                [portraitPreview setImage:scaledImage];
                [landscapePreview setImage:scaledImage];
            });
        }
        
        Photo *photo = [[Photo alloc] init];
        [self.photos addObject:photo];
        [photo setIsSelected:YES];
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *takePhotosDirectory = [docsDir stringByAppendingPathComponent:@"takePhotos"];
        
        //Then save to disk
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
            CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
            NSString *imageFileName = [NSString stringWithFormat:@"%f", currentTime];
            imageFileName = [imageFileName stringByReplacingOccurrencesOfString:@"." withString:@""];
            imageFileName = [imageFileName stringByAppendingString:@".jpg"];
            [photo setFileName:imageFileName];
            NSString *filePath = [takePhotosDirectory stringByAppendingPathComponent:imageFileName];
            NSData *imageData = UIImageJPEGRepresentation(scaledImage, 0.8);
            [imageData writeToFile:filePath atomically:YES];
            [photo setFileLocation:filePath];
        });
        
        //Create thumbnail
        CGFloat height = scaledImage.size.height;
        CGFloat offset = (scaledImage.size.width - scaledImage.size.height) / 2;
        CGImageRef preThumbnailSquare = CGImageCreateWithImageInRect(scaledImage.CGImage, CGRectMake(offset, 0, height, height));
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
}

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.photos count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(110, 110);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[GMGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        UIView *imageViewHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 110)];
        
        UIImageView *thumbnail = [[UIImageView alloc] initWithImage:[[self.photos objectAtIndex:index] thumbnail]];
        [thumbnail setFrame:CGRectMake(5, 5, 100, 100)];
        [thumbnail.layer setMasksToBounds:YES];
        [thumbnail.layer setCornerRadius:5];
        [thumbnail.layer setBorderWidth:1.0];
        
        UIView *deselectOverlay = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 100, 100)];
        [deselectOverlay.layer setMasksToBounds:YES];
        [deselectOverlay.layer setCornerRadius:5];
        [deselectOverlay setBackgroundColor:[UIColor blackColor]];
        [deselectOverlay setAlpha:0.0];
        
        [imageViewHolder addSubview:thumbnail];
        [imageViewHolder addSubview:deselectOverlay];
        
        cell.contentView = imageViewHolder;
    }
    
    UIImageView *thumbnail = [cell.contentView.subviews objectAtIndex:0];
    [thumbnail setImage:[[self.photos objectAtIndex:index] thumbnail]];

    UIView *selectionOverlay = [cell.contentView.subviews objectAtIndex:1];
    if ([[self.photos objectAtIndex:index] isSelected]) {
        [selectionOverlay setAlpha:0.0];
    } else {
        [selectionOverlay setAlpha:0.8];
    }
    
    if (index == [self displayedPhotoIndex]) {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grid_cell_selected_background"]]];
        thumbnail = [cell.contentView.subviews objectAtIndex:0];
        [thumbnail.layer setBorderColor:[[UIColor clearColor] CGColor]];
    } else {
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [thumbnail.layer setBorderColor:[[UIColor grayColor] CGColor]];
    }
    
    return cell;
}

#pragma mark GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    UIImageView *previewImagePortrait = (UIImageView *)[self.portraitView viewWithTag:1];
    UIImageView *previewImageLandscape = (UIImageView *)[self.landscapeView viewWithTag:1];
    
    [self setDisplayedPhotoIndex:position];
    
    Photo *tappedPhoto = [self.photos objectAtIndex:position];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSData *imageData = [NSData dataWithContentsOfFile:[tappedPhoto fileLocation]];
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [previewImagePortrait setImage:image];
            [previewImageLandscape setImage:image];
        });
    });

    if ([tappedPhoto isSelected]) {
        [(UIButton *)[self.portraitView viewWithTag:2] setImage:[UIImage imageNamed:@"selected_picture_yes"] forState:UIControlStateNormal];
        [(UIButton *)[self.landscapeView viewWithTag:2] setImage:[UIImage imageNamed:@"selected_picture_yes"] forState:UIControlStateNormal];
    } else {
        [(UIButton *)[self.portraitView viewWithTag:2] setImage:[UIImage imageNamed:@"selected_picture_no"] forState:UIControlStateNormal];
        [(UIButton *)[self.landscapeView viewWithTag:2] setImage:[UIImage imageNamed:@"selected_picture_no"] forState:UIControlStateNormal];
    }
    
    [self.portraitGridView reloadData];
    [self.landscapeGridView reloadData];
}

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
    [self setCurrentLocation:newLocation];
    
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
