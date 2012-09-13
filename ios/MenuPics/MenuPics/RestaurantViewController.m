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
}

@end
