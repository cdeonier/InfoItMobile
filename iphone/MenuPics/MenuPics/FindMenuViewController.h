//
//  NearbyLocationsViewController.h
//  InfoIt
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FindMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>
{
    IBOutlet UITableViewCell *locationCell;
}

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locationsTableData;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

- (void)initializeLocationManager;

@end