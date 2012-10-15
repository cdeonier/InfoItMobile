//
//  PhotosViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "PhotosViewController.h"

#import "MenuPicsAPIClient.h"
#import "MenuPicsDBClient.h"
#import "MWPhotoBrowser.h"
#import "Photo.h"
#import "PhotoThumbnailCell.h"
#import "SavedPhoto.h"
#import "User.h"

@interface PhotosViewController ()

@property (nonatomic, strong) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotosViewController

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
    
    [self fetchProfile];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Use this for tab bar
    //[self.parentViewController setTitle:@"Photos"];
    
    [self setTitle:@"Photos"];
    
    UIImage *translucentNavBar = [UIImage imageNamed:@"nav_bar_translucent"];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:translucentNavBar forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIImage *defaultNavBarImage = [UIImage imageNamed:@"nav_bar_background"];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:defaultNavBarImage forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)reloadData
{
    NSString *predicateString = [NSString stringWithFormat:@"(username == '%@') and (didDelete != 1)", [[User currentUser] username]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    NSMutableArray *savedPhotos = [MenuPicsDBClient fetchResultsFromDB:@"SavedPhoto" withPredicate:predicateString];
    [savedPhotos sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.photos = savedPhotos;
    
    [self.collectionView reloadData];
}

#pragma mark Web Service

- (void)fetchProfile
{
    User *currentUser = [User currentUser];
    
    SuccessBlock didFetchUserProfileBlock;
    didFetchUserProfileBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *userPhotos = [Photo userPhotosFromJson:JSON];
        [SavedPhoto syncPhotos:userPhotos viewController:self];
    };
    
    [MenuPicsAPIClient fetchProfile:currentUser.userId success:didFetchUserProfileBlock];
}

#pragma mark Helper Functions

- (void)addNewPhoto:(SavedPhoto *)photo
{
    [self.photos addObject:photo];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    [self.photos sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SavedPhoto *savedPhoto = [self.photos objectAtIndex:indexPath.row];
    PhotoThumbnailCell *thumbnail = (PhotoThumbnailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoThumbnailCell" forIndexPath:indexPath];
    [thumbnail.layer setBorderWidth:1.0];
    [thumbnail.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [thumbnail.thumbnailImage setImage:savedPhoto.thumbnail];
    return thumbnail;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PhotoBrowserSegue" sender:self];
}

#pragma mark MWPhotoBrowser Delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        SavedPhoto *photo = [self.photos objectAtIndex:index];
        
        MWPhoto *mwPhoto;
        if ([photo fileLocation]) {
            mwPhoto = [MWPhoto photoWithFilePath:[photo fileLocation]];
        } else {
            mwPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:[photo photoUrl]]];
        }
        
        if ([[photo menuItemId] intValue] > 0) {
            NSString *format = @"%@ at %@";
            NSString *caption = [NSString stringWithFormat:format, [photo menuItemName], [photo restaurantName]];
            [mwPhoto setCaption:caption];
        } else if ([[photo restaurantId] intValue] > 0) {
            NSString *format = @"Taken at %@";
            NSString *caption = [NSString stringWithFormat:format, [photo restaurantName]];
            [mwPhoto setCaption:caption];
        }
        
        return mwPhoto;
    }
    
    return nil;
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index
{
    SavedPhoto *photo = [self.photos objectAtIndex:index];
    
    MWPhoto *mwPhoto;
    if ([photo fileLocation]) {
        mwPhoto = [MWPhoto photoWithFilePath:[photo fileLocation]];
    } else {
        mwPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:[photo photoUrl]]];
    }
    
    if ([[photo menuItemId] intValue] > 0) {
        NSString *format = @"%@ at %@";
        NSString *caption = [NSString stringWithFormat:format, [photo menuItemName], [photo restaurantName]];
        [mwPhoto setCaption:caption];
    } else if ([[photo restaurantId] intValue] > 0) {
        NSString *format = @"Taken at %@";
        NSString *caption = [NSString stringWithFormat:format, [photo restaurantName]];
        [mwPhoto setCaption:caption];
    }
    
    return [[MWCaptionView alloc] initWithPhoto:mwPhoto];
}

- (void)deletePhotoFromPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    int index = photoBrowser.currentPageIndex;
    
    SavedPhoto *photo = [self.photos objectAtIndex:index];
    
    [self.photos removeObjectAtIndex:index];
    [SavedPhoto deletePhoto:photo];
    
    [self.collectionView reloadData];
}

#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PhotoBrowserSegue"]) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        MWPhotoBrowser *photoBrowser = (MWPhotoBrowser *)segue.destinationViewController;
        
        if ([photoBrowser init])
            photoBrowser.delegate = self;
        
        [photoBrowser setDisplayActionButton:YES];
        [photoBrowser reloadData];
        [photoBrowser setInitialPageIndex:selectedIndexPath.row];
        
    }
}

@end
