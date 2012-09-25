//
//  MenuItemViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/7/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "MenuItemViewController.h"

#import "AddPhotoCell.h"
#import "JSONCachedResponse.h"
#import "MenuItem.h"
#import "MenuItemThumbnailCell.h"
#import "MenuPicsAPIClient.h"
#import "Photo.h"
#import "UIImageView+WebCache.h"

@interface MenuItemViewController ()

@property (strong, nonatomic) NSMutableArray *menuItemPhotos;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MenuItemViewController

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
    
    if (self.menuItem.photoUrl) {
        [self.profileImage setImageWithURL:[NSURL URLWithString:self.menuItem.photoUrl]];
    } else if (self.menuItem.photoFileLocation) {
        //We've taken a photo, but it hasn't uploaded yet, so we load from file
        UIImage *profilePhoto = [UIImage imageWithContentsOfFile:self.menuItem.photoFileLocation];
        [self.profileImage setImage:profilePhoto];
        [self checkForUpdatedThumbnails:self.menuItem];
    } else {
        UIImage *profilePhoto = [UIImage imageNamed:@"profile_no_image.jpg"];
        [self.profileImage setImage:profilePhoto];
    }
    
    [self.nameLabel setText:self.menuItem.name];
    
    [self fetchMenuItem:self.menuItem.entityId];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Web Service

- (void)fetchMenuItem:(NSNumber *)menuItemId
{
    id pastJsonResponse = [JSONCachedResponse recentJsonResponse:self withIdentifier:self.menuItem.entityId];
    
    if (pastJsonResponse) {
        [self loadMenuItemFromJson:pastJsonResponse];
        [self loadMenuItemPhotosFromJson:pastJsonResponse];
        [self.collectionView reloadData];
    }
    
    SuccessBlock didFetchMenuItemBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [JSONCachedResponse saveJsonResponse:self withJsonResponse:JSON withIdentifier:self.menuItem.entityId];
        
        [self loadMenuItemFromJson:JSON];
        [self loadMenuItemPhotosFromJson:JSON];
        [self.collectionView reloadData];
    };
    
    [MenuPicsAPIClient fetchMenuItem:menuItemId success:didFetchMenuItemBlock];
}

- (void)loadMenuItemFromJson:(id)json
{
    MenuItem *menuItem = [[MenuItem alloc] initWithJson:json];
    self.menuItem = menuItem;
}

- (void)loadMenuItemPhotosFromJson:(id)json
{
    self.menuItemPhotos = [Photo menuItemPhotosFromJson:json];
}

#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.menuItemPhotos.count + 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        AddPhotoCell *addPhotoCell = (AddPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AddPhotoCell" forIndexPath:indexPath];
        [addPhotoCell.layer setBorderWidth:1.0];
        [addPhotoCell.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        return addPhotoCell;
    } else {
        Photo *menuItemPhoto = [self.menuItemPhotos objectAtIndex:indexPath.row - 1];
        
        MenuItemThumbnailCell *thumbnailCell = (MenuItemThumbnailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MenuItemThumbnailCell" forIndexPath:indexPath];
        [thumbnailCell.layer setBorderWidth:1.0];
        [thumbnailCell.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [thumbnailCell.thumbnailImage setImageWithURL:[NSURL URLWithString:menuItemPhoto.thumbnailUrl]];
        return thumbnailCell;
    }
}

#pragma mark Helper Functions

- (void)checkForUpdatedThumbnails:(MenuItem *)menuItem
{
    if (menuItem.photoUrl) {
        [self fetchMenuItem:menuItem.entityId];
    } else {
        [self performSelector:@selector(checkForUpdatedThumbnails:) withObject:menuItem afterDelay:1];
    }
}

@end
