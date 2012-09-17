//
//  MenuItemViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/7/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "MenuItemViewController.h"

#import "JSONCachedResponse.h"
#import "MenuItem.h"
#import "MenuPicsAPIClient.h"
#import "UIImageView+WebCache.h"

@interface MenuItemViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MenuItemViewController

@synthesize menuItem = _menuItem;

@synthesize profileImage = _profileImage;
@synthesize nameLabel = _nameLabel;
@synthesize collectionView = _collectionView;

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
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:_menuItem.profilePhotoUrl]];
    [self.nameLabel setText:_menuItem.name];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Web Service

- (void)fetchMenuItem:(NSNumber *)menuItemId
{
    id pastJsonResponse = [JSONCachedResponse recentJsonResponse:self withIdentifier:self.menuItem.entityId];
    
    if (pastJsonResponse) {
        [self loadMenuItemFromJson:pastJsonResponse];
    }
    
    void (^didFetchMenuItemBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didFetchMenuItemBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [JSONCachedResponse saveJsonResponse:self withJsonResponse:JSON withIdentifier:self.menuItem.entityId];
        
        [self loadMenuItemFromJson:JSON];
        
        
    };
    
    [MenuPicsAPIClient fetchMenuItem:self.menuItem.entityId success:didFetchMenuItemBlock];
}

- (void)loadMenuItemFromJson:(id)json
{
    MenuItem *menuItem = [[MenuItem alloc] initWithJson:json];
    self.menuItem = menuItem;
}

- (void)loadMenuItemThumbnailsFromJson:(id)json
{
    
}

@end
