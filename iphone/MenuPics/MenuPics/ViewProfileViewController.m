//
//  ViewProfileViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewProfileViewController.h"
#import "IIViewDeckController.h"
#import "UIColor+ExtendedColor.h"
#import "Photo.h"
#import "AppDelegate.h"
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"

@interface ViewProfileViewController ()

@end

@implementation ViewProfileViewController

@synthesize tabBar = _tabBar;
@synthesize photos = _photos;
@synthesize photosGridView = _photosGridView;

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
    
    [self setTitle:@"Profile"];
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    if ([mutableFetchResults count] == 0) {
        [self populateCoreData];
        [self populateCoreData];
        [self populateCoreData];
        [self populateCoreData];
        [self populateCoreData];
        [self populateCoreData];
    }
    
    [self initializePhotosGridView];
    
    [self.view insertSubview:self.photosGridView atIndex:0];
    [self.photosGridView setHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self populatePhotosGridView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self changeViewForTabIndex:item.tag];
}

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.photos count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(75, 75);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[GMGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[self.photos objectAtIndex:index] smallThumbnail]];
        [imageView.layer setBorderWidth:1.0];
        [imageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        
        cell.contentView = imageView;
    }
    
    [(UIImageView *)cell.contentView setImage:[[self.photos objectAtIndex:index] smallThumbnail]];
    
    return cell;
}

#pragma mark GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{

}

#pragma mark Helper Functions

- (void) changeViewForTabIndex:(ViewProfileTab)tab
{
    //Tab tag index starts at 1
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:(tab - 1)]];
    
    switch (tab) {
        case ProfileTab: {
            [self setTitle:@"Profile"];
            [self.navigationController.navigationBar setTranslucent:NO];
            self.navigationItem.titleView = nil;
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
            
            [self.photosGridView setHidden:YES];
            
            break;
        }
        case PhotosTab: {
            [self setTitle:@"Photos"];
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_translucent"] forBarMetrics:UIBarMetricsDefault];
            [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
            [self.navigationController.navigationBar setTranslucent:YES];
            NSArray *segmentedControlItems = [[NSArray alloc] initWithObjects:@"All", @"Tagged", nil];
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
            [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
            [segmentedControl setTintColor:[UIColor navBarButtonColor]];
            [segmentedControl setSelectedSegmentIndex:0];
            
            [self.photosGridView setHidden:NO];
            
            self.navigationItem.titleView = segmentedControl;
            break;
        }
        default:
            break;
    }
}

- (void)initializePhotosGridView
{
    GMGridView *gridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    [gridView setItemSpacing:4];
    [gridView setLayoutStrategy:[GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical]];
    [gridView setMinEdgeInsets:UIEdgeInsetsMake(48, 4, 54, 4)];
    [gridView setCenterGrid:NO];
    [gridView setDataSource:self];
    [gridView setActionDelegate:self];
    //Ideally, we'd like this, but there's a bug with GMGridView which causes this to not display correctly
    [gridView setShowsVerticalScrollIndicator:NO];
    [self setPhotosGridView:gridView];
}

- (void)populatePhotosGridView
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    [self setPhotos:mutableFetchResults];

    [self.photosGridView reloadData];
}


- (void)populateCoreData
{
    NSLog(@"Populate Core Data");
    
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    Photo *photo = [self processImage:image];
    image = [UIImage imageNamed:@"2.jpg"];
    photo = [self processImage:image];
    image = [UIImage imageNamed:@"3.jpg"];
    photo = [self processImage:image];
    image = [UIImage imageNamed:@"4.jpg"];
    photo = [self processImage:image];
    image = [UIImage imageNamed:@"5.jpg"];
    photo = [self processImage:image];
    image = [UIImage imageNamed:@"6.jpg"];
    photo = [self processImage:image];
}

- (Photo *)processImage:(UIImage *)image
{
    NSLog(@"Begin process image");
    //Basic steps: Take original image and scale it down (cropping if necessary for portrait, which will take ~50% longer because of rotation)
    //If first image, set preview image to scaled image
    //Save image to disk on its own async
    //Create a thumbnail and add to gridview
    UIImage *cameraImage = image;
    Photo *photo = [[Photo alloc] init];
    
    //dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        
        [photo setIsSelected:YES];
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *takePhotosDirectory = [docsDir stringByAppendingPathComponent:@"takePhotos"];
        
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
        [photo setThumbnail:thumbnail];
        
        //For Photos in View Profile page
        thumbnailSize = CGSizeMake(150, 150);
        UIGraphicsBeginImageContext(thumbnailSize);
        [[UIImage imageWithCGImage:preThumbnailSquare] drawInRect:CGRectMake(0,0,thumbnailSize.width,thumbnailSize.height)];
        thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [photo setSmallThumbnail:thumbnail];
        
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        NSString *imageFileName = [NSString stringWithFormat:@"%f", currentTime];
        imageFileName = [imageFileName stringByReplacingOccurrencesOfString:@"." withString:@""];
        imageFileName = [imageFileName stringByAppendingString:@".jpg"];
        [photo setFileName:imageFileName];
        NSString *filePath = [takePhotosDirectory stringByAppendingPathComponent:imageFileName];
        NSData *imageData = UIImageJPEGRepresentation(scaledImage, 0.8);
        [imageData writeToFile:filePath atomically:YES];
        [photo setFileLocation:filePath];
        [self savePhoto:photo];
    //});
    
    NSLog(@"End process image");
    return photo;
}

- (void)savePhoto:(Photo *)photo
{
    NSLog(@"Begin save photo");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *photosDirectory = [docsDir stringByAppendingPathComponent:@"photos"];
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();

    if ([photo isSelected]) {
        [fileManager moveItemAtPath:[photo fileLocation] toPath:[photosDirectory stringByAppendingPathComponent:[photo fileName]] error:nil];
        [photo setFileLocation:[photosDirectory stringByAppendingPathComponent:[photo fileName]]];
    }

    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"Move operation took %2.5f seconds", end-start);
    
    NSArray *selectedPhotos = [[NSArray alloc] initWithObjects:photo, nil];
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:1 longitude:1];
    [Photo savePhotos:selectedPhotos creationDate:[NSDate date] creationLocation:newLocation];
    
    NSLog(@"End save photo");
}

@end
