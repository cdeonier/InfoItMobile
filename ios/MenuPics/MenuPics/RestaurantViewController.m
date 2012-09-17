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
    [self.profileImage setImageWithURL:[NSURL URLWithString:[self.restaurant profilePhotoUrl]]];
    [self.nameLabel setText:self.restaurant.name];
    [self.descriptionLabel setText:self.restaurant.description];
    [self.addressOneLabel setText:self.restaurant.streetOne];
    [self.addressTwoLabel setText:self.restaurant.streetTwo];
    [self.cityStateZipLabel setText:[NSString stringWithFormat:@"%@, %@ %@", self.restaurant.city, self.restaurant.state, self.restaurant.zipCode]];
    [self.phoneNumberLabel setText:self.restaurant.phone];
    
    if (self.restaurant.streetTwo == nil || [self.restaurant.streetTwo isEqualToString:@""]) {
        UILabel *addressOneLabel = self.addressOneLabel;
        UILabel *cityStateZipLabel = self.cityStateZipLabel;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[addressOneLabel][cityStateZipLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(addressOneLabel, cityStateZipLabel)]];
        [self.addressTwoLabel removeFromSuperview];
    }
    
    if (self.restaurant.description == nil || [self.restaurant.description isEqualToString:@""]) {
        UILabel *nameLabel = self.nameLabel;
        UILabel *addressOneLabel = self.addressOneLabel;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameLabel]-10-[addressOneLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(nameLabel, addressOneLabel)]];
        [self.descriptionLabel removeFromSuperview];
    }
}

@end
