//
//  HomeViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "HomeViewController.h"

#import "JSONCachedResponse.h"
#import "Location.h"
#import "LocationCell.h"
#import "MenuPicsAPIClient.h"
#import "MenuPicsDBClient.h"
#import "MenuViewController.h"
#import "UIImageView+WebCache.h"
#import "SignInViewController.h"
#import "SVProgressHUD.h"
#import "User.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *buttonBackground;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

@property (nonatomic, strong) UIBarButtonItem *accountButton;
@property (nonatomic, strong) UIBarButtonItem *photosButton;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *nearbyLocations;

@property (nonatomic, strong) UIActionSheet *actionSheet;

- (IBAction)highlightFeedbackButton:(id)sender;
- (IBAction)unhighlightFeedbackButton:(id)sender;
- (IBAction)pressFeedbackButton:(id)sender;

@end

@implementation HomeViewController

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
	
    UIImage *navigationLogo = [UIImage imageNamed:@"nav_logo"];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:navigationLogo];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar.topItem setTitleView:titleView];
    
    [self.tableView setTableFooterView:[UIView new]];
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Sign Out"
                                          otherButtonTitles:@"Update Account", nil];
    
    self.accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStyleBordered target:self action:@selector(displayActionSheet:)];
    self.accountButton.tintColor = self.navigationItem.backBarButtonItem.tintColor;
    
    self.photosButton = [[UIBarButtonItem alloc] initWithTitle:@"Photos" style:UIBarButtonItemStyleBordered target:self action:@selector(pressPhotosButton)];
    self.photosButton.tintColor = self.navigationItem.backBarButtonItem.tintColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initializeLocationManager];
    
    NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];

    NSMutableArray *savedPhotos = [MenuPicsDBClient fetchResultsFromDB:@"SavedPhoto" withPredicate:nil];
    
    if (savedPhotos.count > 0) {
        [self.navigationItem setRightBarButtonItem:self.photosButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    if ([User currentUser]) {
        [self.navigationItem setLeftBarButtonItem:self.accountButton animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Location

- (void)initializeLocationManager
{
    if (nil == [self locationManager])
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500;
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self fetchNearbyLocations:newLocation];
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark Web Service

- (void)fetchNearbyLocations:(CLLocation *)location
{
    id pastJsonResponse = [JSONCachedResponse recentJsonResponse:self withIdentifier:nil];
    
    if (!pastJsonResponse) {
        [SVProgressHUD showWithStatus:@"Loading"];
    } else {
        [self populateTableData:pastJsonResponse];
    }
    
    SuccessBlock didReceiveNearbyLocationsBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [JSONCachedResponse saveJsonResponse:self withJsonResponse:JSON withIdentifier:nil];
        
        [self populateTableData:JSON];
        
        [SVProgressHUD dismiss];
    };
    
    [MenuPicsAPIClient fetchNearbyLocationsAtLocation:location success:didReceiveNearbyLocationsBlock];
}

- (void)populateTableData:(id)json
{
    self.nearbyLocations = [[NSMutableArray alloc] init];
    
    for (id locationJson in json) {
        NSDictionary *location = [locationJson valueForKey:@"entity"];
        
        Location *locationRecord = [[Location alloc] init];
        
        NSString *name = [location valueForKey:@"name"];
        NSNumber *entityId = [location valueForKey:@"id"];
        NSString *thumbnailUrl = [location valueForKey:@"profile_photo_thumbnail_100x100"];
        
        NSNumber *distance = [location valueForKey:@"distance"];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode:NSNumberFormatterRoundDown];
        NSString *distanceString = [formatter stringFromNumber:[NSNumber numberWithFloat:[distance floatValue]]];
        
        [locationRecord setName:name];
        [locationRecord setDistance:distanceString];
        [locationRecord setEntityId:entityId];
        [locationRecord setThumbnailUrl:thumbnailUrl];
        
        [self.nearbyLocations addObject:locationRecord];
    }
    
    [self.tableView reloadData];
}

#pragma mark UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [User signOutUser];
        self.navigationItem.leftBarButtonItem = nil;
    } else if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"UpdateAccountSegue" sender:self];
    }
}

#pragma mark Table Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    
    Location *location = [self.nearbyLocations objectAtIndex:indexPath.row];
    
    [cell.name setText:[location name]];
    [cell.distance setText:[[NSString alloc] initWithFormat:@"%@%@", [location distance], @" miles"]];
    
    UIImage *placeholderImage = [UIImage imageNamed:@"restaurant_placeholder"];
    
    if (location.thumbnailUrl) {
        [cell.thumbnail setImageWithURL:[NSURL URLWithString:[location thumbnailUrl]] placeholderImage:placeholderImage];
    } else {
        [cell.thumbnail setImage:placeholderImage];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nearbyLocations count];
}

#pragma mark SignInDelegate

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn
{
    if (didSignIn) {
        [self.navigationItem setLeftBarButtonItem:self.accountButton animated:YES];
        
        [signInViewController.navigationController popViewControllerAnimated:YES];
        [self performSelector:@selector(doDelayedUserPhotosSegue) withObject:nil afterDelay:0.4];
    }
}

#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MenuSegue"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Location *selectedRestaurant = [self.nearbyLocations objectAtIndex:selectedIndexPath.row];
        
        MenuViewController *menuViewController = [segue destinationViewController];
        [menuViewController setRestaurantId:[selectedRestaurant entityId]];
    } else if ([[segue identifier] isEqualToString:@"HomeSignInSegue"]) {
        
        SignInViewController *signInViewController = [segue destinationViewController];
        [signInViewController setDelegate:self];
    }
}

- (void)pressPhotosButton
{
    User *user = [User currentUser];
    
    if (user) {
        [self performSegueWithIdentifier:@"UserPhotosSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"HomeSignInSegue" sender:self];
    }
}

- (void)displayActionSheet:(id)sender
{
    [self.actionSheet showInView:self.view];
}

-(void)doDelayedUserPhotosSegue
{
    [self performSegueWithIdentifier:@"UserPhotosSegue" sender:self];
}

- (IBAction)highlightFeedbackButton:(id)sender {
    self.buttonBackground.hidden = NO;
}

- (IBAction)unhighlightFeedbackButton:(id)sender {
    self.buttonBackground.hidden = YES;
}

- (IBAction)pressFeedbackButton:(id)sender {
    self.buttonBackground.hidden = YES;
    
    [self performSegueWithIdentifier:@"FeedbackSegue" sender:self];
}

@end
