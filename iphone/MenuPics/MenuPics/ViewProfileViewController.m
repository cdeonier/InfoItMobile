//
//  ViewProfileViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewProfileViewController.h"
#import "UpdateAccountViewController.h"
#import "IIViewDeckController.h"
#import "UIColor+ExtendedColor.h"
#import "AppDelegate.h"
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "AFNetworking.h"
#import "User.h"
#import "SavedPhoto.h"
#import "SavedPhoto+Syncing.h"
#import "Photo.h"
#import "AFNetworking.h"
#import "SmallThumbnail.h"
#import "LargeThumbnail.h"
#import "MWPhoto.h"

@interface ViewProfileViewController ()

@end

@implementation ViewProfileViewController


@synthesize tabBar = _tabBar;
@synthesize actionSheet = _actionSheet;
@synthesize profileView = _profileView;
@synthesize accountButton = _accountButton;
@synthesize profilePhotoButton = _profilePhotoButton;
@synthesize profileUsername = _profileUsername;
@synthesize profilePoints = _profilePoints;
@synthesize profilePointsCalculatingLabel = _profilePointsCalculatingLabel;
@synthesize popularPhotosGridView = _popularPhotosGridView;
@synthesize popularPhotosHeader = _popularPhotosHeader;
@synthesize popularPhotos = _popularPhotos;
@synthesize recentPhotosGridView = _recentPhotosGridView;
@synthesize photoBrowser = _photoBrowser;
@synthesize photoBrowserArray = _photoBrowserArray;
@synthesize recentPhotos = _recentPhotos;
@synthesize didUpdateProfilePhoto = _didUpdateProfilePhoto;
@synthesize noPhotosLabel = _noPhotosLabel;

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
    
    [self initializePhotosGridView];
    [self initializePopularPhotosGridView];
    [self initializeRecentPhotosGridView];
    
    [self.view insertSubview:self.photosGridView atIndex:0];
    [self.photosGridView setHidden:YES];
    
    UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStylePlain target:self action:@selector(displayAccountActionSheet)];
    accountButton.tintColor = [UIColor navBarButtonColor];
    _accountButton = accountButton;
    
    self.navigationItem.rightBarButtonItem = _accountButton;
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                               delegate:self 
                                      cancelButtonTitle:@"Cancel" 
                                 destructiveButtonTitle:@"Sign Out" 
                                      otherButtonTitles:@"Update Account", nil];
    
    UIImage *profilePhoto = [[User currentUser] profilePhoto];
    if (profilePhoto) {
        [self loadUserProfilePhoto];
    }
    
    [_profileUsername setText:[[User currentUser] username]];
    
    _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [_photoBrowser setWantsFullScreenLayout:YES];
    [_photoBrowser setDisplayActionButton:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self populatePhotosGridView];
    [self populateRecentPhotosGridView];
    [self syncProfile];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)signOut:(id)sender
{
    [User signOutUser];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *cameraImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    CGSize scaledSize = CGSizeMake(200, 200);
    UIGraphicsBeginImageContext(scaledSize);
    [cameraImage drawInRect:CGRectMake(0,0,scaledSize.width,scaledSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[User currentUser] setProfilePhoto:scaledImage];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error saving to Core Data");
    }
    
    [self loadUserProfilePhoto];
    [self setDidUpdateProfilePhoto:YES];
    
    User *currentUser = [User currentUser];
    currentUser.syncDelegate = self;
    [User uploadProfilePhoto:currentUser withImage:scaledImage];
    
    [picker dismissModalViewControllerAnimated:YES];
}

- (IBAction)updateProfilePhoto:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:YES];
    [imagePicker setShowsCameraControls:YES];
    [self presentModalViewController:imagePicker animated:YES];
}

#pragma mark SyncPhotoDelegate

- (void)didSyncPhoto:(SavedPhoto *)syncedPhoto 
{
    [[self photosGridView] reloadData];
}

#pragma mark SyncUserDelegate

- (void)didSyncProfilePhoto
{
    [self loadUserProfilePhoto];
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self changeViewForTabIndex:item.tag];
}

#pragma mark UIActionSheet Delegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self signOut:self];
    } else if (buttonIndex == 1) {
        UpdateAccountViewController *viewController = [[UpdateAccountViewController alloc] initWithNibName:@"UpdateAccountViewController" bundle:nil];
        [viewController setDelegate:self];
        [self presentModalViewController:viewController animated:YES];
    } else {
        NSLog(@"Cancel");
    }
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{

}

- (void)displayAccountActionSheet
{
    [_actionSheet showFromTabBar:_tabBar];
}

#pragma mark UpdateAccountDelegate

- (void)updateAccountViewController:(UpdateAccountViewController *)updateAccountViewController didUpdateAccount:(BOOL)didUpdateAccount
{
    [_profileUsername setText:[[User currentUser] username]];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    if (gridView == _photosGridView) {
        return [self.photos count];
    } else if (gridView == _recentPhotosGridView) {
        return [_recentPhotos count];
    } else if (gridView == _popularPhotosGridView) {
        return [_popularPhotos count];
    } else {
        return 0;
    }
    
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (gridView == _photosGridView) {
        return CGSizeMake(75, 75);
    } else if (gridView == _recentPhotosGridView) {
        return CGSizeMake(50, 50);
    } else if (gridView == _popularPhotosGridView) {
        return CGSizeMake(50, 50);
    } else {
        return CGSizeMake(0, 0);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (gridView == _photosGridView) {
        if (!cell) 
        {
            cell = [[GMGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            LargeThumbnail *contentView = [[LargeThumbnail alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            [[contentView thumbnail].layer setBorderWidth:1.0];
            [[contentView thumbnail].layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
            cell.contentView = contentView;
        }
        
        LargeThumbnail *contentView = (LargeThumbnail *)cell.contentView;
        Photo *photo = [_photos objectAtIndex:index];
        
        if ([[_photos objectAtIndex:index] thumbnail]) {
            [[contentView thumbnail] setImage:[[_photos objectAtIndex:index] thumbnail]];
        } else {
            [[contentView thumbnail] setImageWithURL:[NSURL URLWithString:[[_photos objectAtIndex:index] thumbnailUrl]]];
        }
        
        if ([photo points] && [[photo points] intValue] > 0) {
            [contentView.points setText:[[photo points] stringValue]];
            [contentView.pointsBackground setHidden:NO];
            [contentView.points setHidden:NO];
        } else {
            [contentView.pointsBackground setHidden:YES];
            [contentView.points setHidden:YES];
        }
    } else if (gridView == _recentPhotosGridView) {
        if (!cell) 
        {
            cell = [[GMGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[[self.recentPhotos objectAtIndex:index] thumbnail]];
            [imageView.layer setBorderWidth:1.0];
            [imageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
            cell.contentView = imageView;
        }
        
        if ([[self.recentPhotos objectAtIndex:index] thumbnail]) {
            [(UIImageView *)cell.contentView setImage:[[self.recentPhotos objectAtIndex:index] thumbnail]];
        } else {
            [(UIImageView *)cell.contentView setImageWithURL:[NSURL URLWithString:[[self.recentPhotos objectAtIndex:index] thumbnailUrl]]];
        }
    } else if (gridView == _popularPhotosGridView) {
        if (!cell) 
        {
            cell = [[GMGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            SmallThumbnail *contentView = [[SmallThumbnail alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            [[contentView thumbnail].layer setBorderWidth:1.0];
            [[contentView thumbnail].layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
            cell.contentView = contentView;
        }
        
        SmallThumbnail *contentView = (SmallThumbnail *)cell.contentView;
        if ([[self.popularPhotos objectAtIndex:index] thumbnail]) {
            [[contentView thumbnail] setImage:[[self.popularPhotos objectAtIndex:index] thumbnail]];
        } else {
            [[contentView thumbnail] setImageWithURL:[NSURL URLWithString:[[self.popularPhotos objectAtIndex:index] thumbnailUrl]]];
        }
        [contentView.points setText:[[[self.popularPhotos objectAtIndex:index] points] stringValue]];
        
    } else {
        NSLog(@"Unrecognized gridview");
    }
    
    return cell;
}

#pragma mark GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if (gridView == _photosGridView) {
        _photoBrowserArray = _photos;
    } else if (gridView == _recentPhotosGridView) {
        _photoBrowserArray = _recentPhotos;
    } else if (gridView == _popularPhotosGridView) {
        _photoBrowserArray = _popularPhotos;
    }
    
    [_photoBrowser reloadData];
    [_photoBrowser setInitialPageIndex:position];
     
    [self.navigationController pushViewController:_photoBrowser animated:YES];
}

#pragma mark MWPhotoBrowser Delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photoBrowserArray.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photoBrowserArray.count) {
        Photo *photo = [_photoBrowserArray objectAtIndex:index];
        
        MWPhoto *mwPhoto;
        if ([photo fileLocation]) {
            mwPhoto = [MWPhoto photoWithFilePath:[photo fileLocation]];
            [mwPhoto setPhoto:photo];
            
            if ([[photo menuItemId] intValue] > 0) {
                NSString *format = @"%@ @ %@";
                NSString *caption = [NSString stringWithFormat:format, [photo menuItemName], [photo restaurantName]];
                [mwPhoto setCaption:caption];
            } else if ([[photo restaurantId] intValue] > 0) {
                NSString *format = @"@ %@";
                NSString *caption = [NSString stringWithFormat:format, [photo restaurantName]];
                [mwPhoto setCaption:caption];
            }
        } else {
            mwPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:[photo photoUrl]]];
            [mwPhoto setPhoto:photo];
            
            if ([[photo menuItemId] intValue] > 0) {
                NSString *format = @"%@ @ %@";
                NSString *caption = [NSString stringWithFormat:format, [photo menuItemName], [photo restaurantName]];
                [mwPhoto setCaption:caption];
            } else if ([[photo restaurantId] intValue] > 0) {
                NSString *format = @"@ %@";
                NSString *caption = [NSString stringWithFormat:format, [photo restaurantName]];
                [mwPhoto setCaption:caption];
            }
        }
        return mwPhoto;
    }

    return nil;
}

#pragma mark Helper Functions

- (void) changeViewForTabIndex:(ViewProfileTab)tab
{
    //Tab tag index starts at 1
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:(tab - 1)]];
    
    switch (tab) {
        case ProfileTab: {
            [self setTitle:@"Profile"];
            [[self profileView] setHidden:NO];
            [self.navigationController.navigationBar setTranslucent:NO];
            self.navigationItem.titleView = nil;
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
            self.navigationItem.rightBarButtonItem = _accountButton;
            [self.photosGridView setHidden:YES];
            
            break;
        }
        case PhotosTab: {
            [self setTitle:@"Photos"];
            [[self profileView] setHidden:YES];
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_translucent"] forBarMetrics:UIBarMetricsDefault];
            [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
            [self.navigationController.navigationBar setTranslucent:YES];
            self.navigationItem.rightBarButtonItem = nil;
            /*NSArray *segmentedControlItems = [[NSArray alloc] initWithObjects:@"All", @"Tagged", nil];
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
            [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
            [segmentedControl setTintColor:[UIColor navBarButtonColor]];
            [segmentedControl setSelectedSegmentIndex:0];
            self.navigationItem.titleView = segmentedControl;*/
            
            [self.photosGridView setHidden:NO];

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

- (void)initializePopularPhotosGridView
{
    [_popularPhotosGridView setItemSpacing:12];
    [_popularPhotosGridView setLayoutStrategy:[GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical]];
    [_popularPhotosGridView setMinEdgeInsets:UIEdgeInsetsMake(0, 11, 0, 11)];
    [_popularPhotosGridView setCenterGrid:NO];
}

- (void)initializeRecentPhotosGridView
{
    [_recentPhotosGridView setItemSpacing:12];
    [_recentPhotosGridView setLayoutStrategy:[GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal]];
    [_recentPhotosGridView setMinEdgeInsets:UIEdgeInsetsMake(0, 11, 0, 11)];
    [_recentPhotosGridView setCenterGrid:NO];
}

- (void)populatePhotosGridView
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"username == '%@'", [[User currentUser] username]]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    NSMutableArray *photosArray = [[NSMutableArray alloc] initWithCapacity:[mutableFetchResults count]];
    for (SavedPhoto *savedPhoto in mutableFetchResults) {
        Photo *photo = [[Photo alloc] initWithSavedPhoto:savedPhoto];
        [photosArray addObject:photo];
    }
    
    [self setPhotos:photosArray];

    [self.photosGridView reloadData];
}

- (void)populateRecentPhotosGridView
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSDate *today = [NSDate date];
    NSDate *thisWeek  = [today dateByAddingTimeInterval:-604800.0];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(creationDate > %@) and (username == %@)", thisWeek, [[User currentUser] username]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    NSMutableArray *photosArray = [[NSMutableArray alloc] initWithCapacity:[mutableFetchResults count]];
    for (SavedPhoto *savedPhoto in mutableFetchResults) {
        Photo *photo = [[Photo alloc] initWithSavedPhoto:savedPhoto];
        [photosArray addObject:photo];
    }
    [self setRecentPhotos:photosArray];
    
    if ([photosArray count] > 0) {
        [_noPhotosLabel setHidden:YES];
    } else {
        [_noPhotosLabel setHidden:NO];
    }
    
    [_recentPhotosGridView reloadData];
}

- (void)populatePopularPhotosGridView:(id)JSON
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *coreDataRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [coreDataRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"username == '%@'", [[User currentUser] username]]];
    [coreDataRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:coreDataRequest error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    NSMutableDictionary *photosOnPhone = [[NSMutableDictionary alloc] initWithCapacity:200];
    for (SavedPhoto *coreDataPhoto in mutableFetchResults) {
        [photosOnPhone setObject:coreDataPhoto forKey:[coreDataPhoto fileName]];
    }
    
    _popularPhotos = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (id photoEntry in [[JSON valueForKey:@"user"] valueForKey:@"photos"]) {
        if ([[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"]) {
            Photo *photo = [[Photo alloc] initWithSavedPhoto:[photosOnPhone objectForKey:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_filename"]]];
            [photo setPoints:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"photo_points"]];
            [photo setMenuItemName:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"menu_item_name"]];
            [photo setMenuItemId:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"menu_item_id"]];
            [photo setRestaurantName:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"restaurant_name"]];
            [photo setRestaurantId:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"restaurant_id"]];
            [_popularPhotos addObject:photo];
        }
    }
    
    if ([_popularPhotos count] > 0) {
        [_popularPhotosHeader setHidden:NO];
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    _popularPhotos = [NSMutableArray arrayWithArray:[_popularPhotos sortedArrayUsingDescriptors:sortDescriptors]];
    
    if ([_popularPhotos count] > 10)
        _popularPhotos = [NSMutableArray arrayWithArray:[_popularPhotos subarrayWithRange:NSMakeRange(0, 10)]];
    
    [_popularPhotosGridView reloadData];
}

- (void)syncProfile
{
    [self populatePhotosGridView];
    
    [self uploadPendingImages];
    [self downloadPendingImages];
    
    NSString *urlString = [NSString stringWithFormat:@"https://infoit-app.herokuapp.com/services/user_profile?access_token=%@", [[User currentUser] accessToken]];

    NSLog(@"URL String: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
    {
        NSLog(@"JSON: %@", JSON);
        
        if (![self didUpdateProfilePhoto]) {
            User *currentUser = [User currentUser];
            currentUser.syncDelegate = self;
            [User downloadProfilePhoto:currentUser withURL:[[JSON valueForKey:@"user"] valueForKey:@"profile_photo"]];
        }
        
        NSMutableDictionary *photosOnPhone = [[NSMutableDictionary alloc] initWithCapacity:200];
        for (SavedPhoto *coreDataPhoto in self.photos) {
            [photosOnPhone setObject:coreDataPhoto forKey:[coreDataPhoto fileName]];
        }
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        for (id photoEntry in [[JSON valueForKey:@"user"] valueForKey:@"photos"]) {
            NSLog(@"Photo Entry: %@", photoEntry);
            
            NSString *photoFilename = [[photoEntry valueForKey:@"photo"] valueForKey:@"photo_filename"];
            
            if (![photosOnPhone objectForKey:photoFilename] && ![photoFilename isEqualToString:@"profile_photo"]) {
                SavedPhoto *photo = (SavedPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"SavedPhoto" inManagedObjectContext:context];
                [photo setFileName:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_filename"]];
                [photo setPhotoId:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_id"]];
                [photo setFileUrl:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_original"]];
                [photo setThumbnailUrl:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_thumbnail_200x200"]];
                [photo setDidUpload:[NSNumber numberWithBool:YES]];
                [photo setDidDelete:[NSNumber numberWithBool:NO]];
                [photo setDidTag:[NSNumber numberWithBool:[[[photoEntry valueForKey:@"photo"] valueForKey:@"is_tagged"] boolValue]]];
                [photo setUsername:[[User currentUser] username]];

                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                NSString *creationDateWithLetters = [[photoEntry valueForKey:@"photo"] valueForKey:@"photo_taken_date"];
                NSString *creationDate = [[creationDateWithLetters componentsSeparatedByCharactersInSet:[NSCharacterSet letterCharacterSet]] componentsJoinedByString:@" "];
                [photo setCreationDate:[formatter dateFromString:creationDate]];
            }
            
            NSString *fileName = [[photoEntry valueForKey:@"photo"] valueForKey:@"photo_filename"];
            if (![fileName isEqualToString:@"profile_photo"] && [[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"photo_points"] > 0) {
                SavedPhoto *savedPhoto = [SavedPhoto photoWithFilename:fileName];
                [savedPhoto setPoints:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"photo_points"]];
                [savedPhoto setMenuItemId:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"menu_item_id"]];
                [savedPhoto setMenuItemName:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"menu_item_name"]];
                [savedPhoto setRestaurantId:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"restaurant_id"]];
                [savedPhoto setRestaurantName:[[[photoEntry valueForKey:@"photo"] valueForKey:@"tagged_info"] valueForKey:@"restaurant_name"]];
                [savedPhoto setDidTag:[NSNumber numberWithBool:YES]];
            } else {
                SavedPhoto *savedPhoto = [SavedPhoto photoWithFilename:fileName];
                [savedPhoto setPoints:nil];
                [savedPhoto setDidTag:[NSNumber numberWithBool:NO]];
            }
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
        //Update photos first, since some methods depend on populated photo array (such as updatePoints)
        [self populatePhotosGridView];
        
        [self updatePoints];
        
        [self populateRecentPhotosGridView];
        
        [self populatePopularPhotosGridView:JSON];
                
        [self downloadPendingImages];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"Profile Sync Failure");
    }];
    [operation start];
}

- (void)uploadPendingImages
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didUpload == 0"];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    if ([mutableFetchResults count] > 0) {
        NSLog(@"Uploading %i photos.", [mutableFetchResults count]);
    }
    
    for (SavedPhoto *photo in mutableFetchResults) {
        [SavedPhoto uploadPhoto:photo];
    }
}

- (void)downloadPendingImages
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"thumbnail == nil"];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];

    for (SavedPhoto *photo in mutableFetchResults) {
        [photo setSyncDelegate:self];
        [SavedPhoto downloadThumbnail:photo];
    }
}

- (void)loadUserProfilePhoto
{
    UIImage *profilePhoto = [[User currentUser] profilePhoto];
    [_profilePhotoButton setImage:profilePhoto forState:UIControlStateNormal];
    [_profilePhotoButton.layer setBorderWidth:1.0];
    [_profilePhotoButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [_profilePhotoButton setImage:nil forState:UIControlStateHighlighted];
}

- (void)updatePoints
{
    int totalPoints = 0;
    for (Photo *photo in _photos) {
        if ([photo points] > 0) {
            totalPoints += [[photo points] intValue];
        }
    }
    
    NSString *pointsString;
    if (totalPoints == 1) {
        pointsString = @"1 Point";
    } else {
        pointsString = [NSString stringWithFormat:@"%d Points", totalPoints];
    }
    [_profilePoints setText:pointsString];
    [_profilePoints setHidden:NO];
    [_profilePointsCalculatingLabel setHidden:YES];
}

@end
