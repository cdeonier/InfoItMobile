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

@property (strong, nonatomic) NSMutableArray *userNewPhotos;

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
    
    [self setTitle:@"Menu Item"];
    
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
    
    self.menuItemPhotos = [[NSMutableArray alloc] initWithCapacity:5];
    self.userNewPhotos = [[NSMutableArray alloc] initWithCapacity:5];
    
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
        //[self loadMenuItemFromJson:pastJsonResponse];
        [self loadMenuItemPhotosFromJson:pastJsonResponse];
        [self.collectionView reloadData];
    }
    
    SuccessBlock didFetchMenuItemBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [JSONCachedResponse saveJsonResponse:self withJsonResponse:JSON withIdentifier:self.menuItem.entityId];
        
        //[self loadMenuItemFromJson:JSON];
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
    
    [self loadNewUserPhotos];
}

- (void)loadNewUserPhotos
{
    for (Photo *photo in self.userNewPhotos) {
        NSString *photoFileName = photo.fileName;
        
        NSIndexSet *indexes = [self.menuItemPhotos indexesOfObjectsPassingTest:^BOOL(id menuItemPhoto, NSUInteger idx, BOOL *stop) {
            NSString *menuItemPhotoFileName = [(Photo *)menuItemPhoto fileName];
            return [photoFileName isEqualToString:menuItemPhotoFileName];
        }];
        
        if (indexes.count == 0) {
            [self.menuItemPhotos addObject:photo];
        }
    }
    
    [self.collectionView reloadData];
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
        
        if (menuItemPhoto.thumbnail) {
            [thumbnailCell.thumbnailImage setImage:menuItemPhoto.thumbnail];
        } else {
           [thumbnailCell.thumbnailImage setImageWithURL:[NSURL URLWithString:menuItemPhoto.thumbnailUrl]]; 
        }
        
        return thumbnailCell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *menuItemPhoto = [self.menuItemPhotos objectAtIndex:indexPath.row - 1];
    
    if (menuItemPhoto.fileLocation) {
        UIImage *profilePhoto = [UIImage imageWithContentsOfFile:menuItemPhoto.fileLocation];
        [self.profileImage setImage:profilePhoto];
    } else {
        [self.profileImage setImageWithURL:[NSURL URLWithString:menuItemPhoto.photoUrl]];
    }
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark TakePhotoDelegate

- (void)didTakePhoto:(TakePhotoViewController *)viewController
{
    if (!self.menuItem.thumbnailUrl) {
        [self.menuItem setThumbnail:viewController.photo.thumbnail];
    }
    
    Photo *newPhoto = viewController.photo;
    [self.userNewPhotos addObject:newPhoto];
    [self loadNewUserPhotos];
    UIImage *profilePhoto = [UIImage imageWithContentsOfFile:newPhoto.fileLocation];
    [self.profileImage setImage:profilePhoto];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.menuItemPhotos.count inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark SignInDelegate

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn
{
    
}

#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[TakePhotoViewController class]]) {
        TakePhotoViewController *takePhotoViewController = [segue destinationViewController];
        [takePhotoViewController setDelegate:self];
        [takePhotoViewController setMenuItem:self.menuItem];
    } else if ([segue.destinationViewController isKindOfClass:[SignInViewController class]]) {
        [(SignInViewController *)segue.destinationViewController setDelegate:sender];
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
