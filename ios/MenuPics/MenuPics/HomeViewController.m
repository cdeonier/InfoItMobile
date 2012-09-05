//
//  HomeViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "HomeViewController.h"

#import "JSONResponse.h"
#import "Location.h"
#import "LocationCell.h"
#import "MenuPicsAPIClient.h"
#import "MenuViewController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"

@interface HomeViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *nearbyLocations;

@end

@implementation HomeViewController

@synthesize tableView = _tableView;

@synthesize locationManager = _locationManager;
@synthesize nearbyLocations = _nearbyLocations;


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
    
    [_tableView setTableFooterView:[UIView new]];
    
    [self initializeLocationManager];
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
    [self getNearbyLocations:newLocation];
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark Web Service

- (void)getNearbyLocations:(CLLocation *)location
{
    id pastJsonResponse = [JSONResponse recentJsonResponse:self];
    
    if (!pastJsonResponse) {
        [SVProgressHUD showWithStatus:@"Loading"];
    } else {
        [self populateTableData:pastJsonResponse];
    }
    
    void (^didReceiveNearbyLocationsBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didReceiveNearbyLocationsBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [JSONResponse saveJsonResponse:self withJsonResponse:JSON];
        
        [self populateTableData:JSON];
        
        [SVProgressHUD dismiss];
    };
    
    [MenuPicsAPIClient getNearbyLocationsAtLocation:location success:didReceiveNearbyLocationsBlock];
}

- (void)populateTableData:(id)json
{
    _nearbyLocations = [[NSMutableArray alloc] init];
    
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
        
        [_nearbyLocations addObject:locationRecord];
    }
    
    [_tableView reloadData];
}

#pragma mark Table Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    
    Location *location = [_nearbyLocations objectAtIndex:indexPath.row];
    
    [cell.name setText:[location name]];
    [cell.distance setText:[[NSString alloc] initWithFormat:@"%@%@", [location distance], @" miles"]];
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:[location thumbnailUrl]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuViewController *menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
    [self.navigationController pushViewController:menuViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_nearbyLocations count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


@end
