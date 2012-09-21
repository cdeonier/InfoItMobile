//
//  PhotosViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "PhotosViewController.h"

#import "MenuPicsDBClient.h"
#import "PhotoThumbnailCell.h"
#import "SavedPhoto.h"
#import "User.h"

@interface PhotosViewController ()

@property (nonatomic, strong) NSMutableArray *photos;

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
    
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.parentViewController setTitle:@"Photos"];
    
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
    self.photos = [MenuPicsDBClient fetchResultsFromDB:@"SavedPhoto" withPredicate:predicateString];
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

@end
