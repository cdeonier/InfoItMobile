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
#import "MenuViewController.h"
#import "UIImageView+WebCache.h"
#import "SignInViewController.h"
#import "SVProgressHUD.h"
#import "User.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *nearbyLocations;

- (IBAction)pressAccountButton:(id)sender;

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
    
    [self initializeLocationManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
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
    
    void (^didReceiveNearbyLocationsBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didReceiveNearbyLocationsBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
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
        NSString *distance = [location valueForKey:@"distance"];
        NSNumber *entityId = [location valueForKey:@"id"];
        NSString *thumbnailUrl = [location valueForKey:@"profile_photo_thumbnail_100x100"];
        
        [locationRecord setName:name];
        [locationRecord setDistance:distance];
        [locationRecord setEntityId:entityId];
        [locationRecord setThumbnailUrl:thumbnailUrl];
        
        [self.nearbyLocations addObject:locationRecord];
    }
    
    [self.tableView reloadData];
}

#pragma mark Table Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    
    Location *location = [self.nearbyLocations objectAtIndex:indexPath.row];
    
    [cell.name setText:[location name]];
    [cell.distance setText:[[NSString alloc] initWithFormat:@"%@%@", [location distance], @" miles"]];
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:[location thumbnailUrl]]];
    
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
        [self performSegueWithIdentifier:@"ViewProfileSegue" sender:self];
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

- (IBAction)pressAccountButton:(id)sender
{
    User *user = [User currentUser];
    
    if (user) {
        [self performSegueWithIdentifier:@"ViewProfileSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"HomeSignInSegue" sender:self];
    }
}

@end
