//
//  RestaurantViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "RestaurantViewController.h"

#import "Restaurant.h"
#import "UIImageView+WebCache.h"

@interface RestaurantViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateZipLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@end

@implementation RestaurantViewController

@synthesize restaurant = _restaurant;

@synthesize profileImage = _profileImage;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)reloadData
{
    [_profileImage setImageWithURL:[NSURL URLWithString:[_restaurant profilePhotoUrl]]];
    [_nameLabel setText:_restaurant.name];
    [_descriptionLabel setText:_restaurant.description];
    [_addressOneLabel setText:_restaurant.streetOne];
    [_addressTwoLabel setText:_restaurant.streetTwo];
    [_cityStateZipLabel setText:[NSString stringWithFormat:@"%@, %@ %@", _restaurant.city, _restaurant.state, _restaurant.zipCode]];
    [_phoneNumberLabel setText:_restaurant.phone];
    
    if (_restaurant.streetTwo == nil || [_restaurant.streetTwo isEqualToString:@""]) {
        UILabel *addressOneLabel = _addressOneLabel;
        UILabel *cityStateZipLabel = _cityStateZipLabel;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[addressOneLabel][cityStateZipLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(addressOneLabel, cityStateZipLabel)]];
        [_addressTwoLabel removeFromSuperview];
    }
    
    if (_restaurant.description == nil || [_restaurant.description isEqualToString:@""]) {
        UILabel *nameLabel = _nameLabel;
        UILabel *addressOneLabel = _addressOneLabel;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameLabel]-10-[addressOneLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(nameLabel, addressOneLabel)]];
        [_descriptionLabel removeFromSuperview];
    }
}

@end
