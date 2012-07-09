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
#import "AFNetworking.h"

@interface ViewProfileViewController ()

@end

@implementation ViewProfileViewController


@synthesize tabBar = _tabBar;
@synthesize actionSheet = _actionSheet;
@synthesize profileView = _profileView;
@synthesize accountButton = _accountButton;
@synthesize profilePhotoButton = _profilePhotoButton;
@synthesize popularPhotosGridView = _popularPhotosGridView;
@synthesize recentPhotosGridView = _recentPhotosGridView;
@synthesize didUpdateProfilePhoto = _didUpdateProfilePhoto;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self populatePhotosGridView];
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
    [[self photos] addObject:syncedPhoto];
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
    [self dismissModalViewControllerAnimated:YES];
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
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[self.photos objectAtIndex:index] thumbnail]];
        [imageView.layer setBorderWidth:1.0];
        [imageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        
        cell.contentView = imageView;
    }
    
    [(UIImageView *)cell.contentView setImage:[[self.photos objectAtIndex:index] thumbnail]];
    
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
            NSArray *segmentedControlItems = [[NSArray alloc] initWithObjects:@"All", @"Tagged", nil];
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
            [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
            [segmentedControl setTintColor:[UIColor navBarButtonColor]];
            [segmentedControl setSelectedSegmentIndex:0];
            
            [self.photosGridView setHidden:NO];
            
            self.navigationItem.titleView = segmentedControl;
            self.navigationItem.rightBarButtonItem = nil;
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
    [_popularPhotosGridView setLayoutStrategy:[GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal]];
}

- (void)initializeRecentPhotosGridView
{
    
}

- (void)populatePhotosGridView
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"username == nil or username == '%@'", [[User currentUser] username]]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    [self setPhotos:mutableFetchResults];

    [self.photosGridView reloadData];
}

- (void)syncProfile
{
    [self populatePhotosGridView];
    
    [self uploadPendingImages];
    [self downloadPendingImages];
    
    NSString *urlString = [NSString stringWithFormat:@"https://infoit.heroku.com/services/user_profile?access_token=%@", [[User currentUser] accessToken]];

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
            //NSLog(@"Photo Entry: %@", photoEntry);
            
            NSString *photoFilename = [[photoEntry valueForKey:@"photo"] valueForKey:@"photo_filename"];
            
            if (![photosOnPhone objectForKey:photoFilename] && ![photoFilename isEqualToString:@"profile_photo"]) {
                SavedPhoto *photo = (SavedPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"SavedPhoto" inManagedObjectContext:context];
                [photo setFileName:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_filename"]];
                [photo setPhotoId:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_id"]];
                [photo setFileUrl:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_original"]];
                [photo setThumbnailUrl:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_thumbnail_200x200"]];
                [photo setDidUpload:[NSNumber numberWithBool:YES]];
                [photo setDidDelete:[NSNumber numberWithBool:NO]];
                [photo setDidTag:[NSNumber numberWithBool:[[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_original"] boolValue]]];
                [photo setUsername:[[User currentUser] username]];

                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                NSString *creationDateWithLetters = [[photoEntry valueForKey:@"photo"] valueForKey:@"photo_taken_date"];
                NSString *creationDate = [[creationDateWithLetters componentsSeparatedByCharactersInSet:[NSCharacterSet letterCharacterSet]] componentsJoinedByString:@" "];
                [photo setCreationDate:[formatter dateFromString:creationDate]];
            }
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
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

@end
