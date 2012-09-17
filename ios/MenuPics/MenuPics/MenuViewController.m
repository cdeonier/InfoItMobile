//
//  MenuViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "MenuViewController.h"

#import "AllMenusViewController.h"
#import "CurrentMenuViewController.h"
#import "JSONCachedResponse.h"
#import "MenuItem.h"
#import "MenuPicsAPIClient.h"
#import "OrderedDictionary.h"
#import "PopularViewController.h"
#import "Restaurant.h"
#import "RestaurantViewController.h"
#import "SVProgressHUD.h"

@interface MenuViewController ()

@property (nonatomic, strong) CurrentMenuViewController *currentMenuController;
@property (nonatomic, strong) PopularViewController *popularMenuController;
@property (nonatomic, strong) RestaurantViewController *restaurantController;
@property (nonatomic, strong) AllMenusViewController *allMenusController;

@property (nonatomic, strong) NSString *currentMenuType;
@property (nonatomic, strong) NSMutableArray *menuTypes;
@property (nonatomic, strong) OrderedDictionary *currentMenu;
@property (nonatomic, strong) OrderedDictionary *restaurantMenus;

@end

@implementation MenuViewController

@synthesize restaurantId = _restaurantId;

@synthesize currentMenuController = _currentMenuController;
@synthesize popularMenuController = _popularMenuController;
@synthesize restaurantController = _restaurantController;
@synthesize allMenusController = _allMenusController;

@synthesize currentMenuType = _currentMenuType;
@synthesize menuTypes = _menuTypes;
@synthesize currentMenu = _currentMenu;
@synthesize restaurantMenus = _restaurantMenus;

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
    
    [self setDelegate:self];
    
    self.currentMenuController = [[self viewControllers] objectAtIndex:0];
    self.popularMenuController = [[self viewControllers] objectAtIndex:1];
    self.restaurantController = [[self viewControllers] objectAtIndex:2];
    self.allMenusController = [[self viewControllers] objectAtIndex:3];
    
    
    [self setSelectedViewController:self.currentMenuController];
	
    [self fetchMenu:self.restaurantId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITabBarDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController == self.currentMenuController) {
        [self setTitle:self.currentMenuType];
    } else if (viewController == self.popularMenuController) {
        [self setTitle:@"Most Popular"];
    } else if (viewController == self.restaurantController) {
        [self setTitle:[[self.restaurantController restaurant] name]];
    } else if (viewController == self.allMenusController) {
        [self setTitle:@"Choose Menu"];
    }
}

#pragma mark Web Service

- (void)fetchMenu:(NSNumber *)restaurantId
{
    id pastJsonResponse = [JSONCachedResponse recentJsonResponse:self withIdentifier:self.restaurantId];
    
    if (!pastJsonResponse) {
        [SVProgressHUD showWithStatus:@"Loading"];
    } else {
        [self loadMenuFromJson:pastJsonResponse];
    }
    
    void (^didFetchMenuBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didFetchMenuBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [JSONCachedResponse saveJsonResponse:self withJsonResponse:JSON withIdentifier:self.restaurantId];
        
        [self loadMenuFromJson:JSON];
        
        [SVProgressHUD dismiss];
    };
    
    [MenuPicsAPIClient fetchMenu:restaurantId success:didFetchMenuBlock];
}

- (void)loadMenuFromJson:(id)json
{
    Restaurant *restaurant = [[Restaurant alloc] initWithJson:json];
    [self.restaurantController setRestaurant:restaurant];
    
    NSArray *menuItemsJson = [json valueForKeyPath:@"entity.place_details.menu_items"];
    self.menuTypes = [[NSMutableArray alloc] init];
    self.restaurantMenus = [[OrderedDictionary alloc] init];
    
    OrderedDictionary *menu;
    NSMutableArray *categoryItems;
    
    NSString *currentMenuType = nil;
    NSString *currentCategory = nil;
    
    for (id menuItemJson in menuItemsJson) {
        id menuItem = [menuItemJson valueForKey:@"menu_item"];
        
        NSString *menuItemMenuType = [menuItem valueForKey:@"menu_type"];
        NSString *menuItemCategory = [menuItem valueForKey:@"menu_category"];
        
        if (![menuItemMenuType isEqualToString:currentMenuType]) {
            //New menu, so by default we have new category
            currentMenuType = menuItemMenuType;
            currentCategory = menuItemCategory;
            
            //Create new empty sets to fill up
            menu = [[OrderedDictionary alloc] init];
            categoryItems = [[NSMutableArray alloc] init];
            
            [menu setObject:categoryItems forKey:currentCategory];
            
            [self.restaurantMenus setObject:menu forKey:currentMenuType];
            [self.menuTypes addObject:currentMenuType];
        }
        
        if (![menuItemCategory isEqualToString:currentCategory]) {
            currentCategory = menuItemCategory;
            categoryItems = [[NSMutableArray alloc] init];
            [menu setObject:categoryItems forKey:currentCategory];
        }
        
        MenuItem *menuItemRecord = [[MenuItem alloc] initWithJson:menuItem];
        [menuItemRecord setRestaurantId:self.restaurantId];
        
        [categoryItems addObject:menuItemRecord];
    }
    
    self.allMenusController.menuTypes = self.menuTypes;
    [self.allMenusController reloadData];
    
    self.currentMenuType = [self.menuTypes objectAtIndex:0];
    
    [self changeMenu:self.currentMenuType];
    
    if ([self selectedViewController] == self.currentMenuController) {
        [self setTitle:self.currentMenuType];
    }
}

#pragma mark Helper Functions

- (void)selectMenu:(NSString *)menuType
{
    [self changeMenu:menuType];
    [self setTitle:self.currentMenuType];
    [self setSelectedViewController:self.currentMenuController];
}

- (void)changeMenu:(NSString *)menuType
{
    self.currentMenuType = menuType;
    self.currentMenu = [self.restaurantMenus objectForKey:self.currentMenuType];
    
    [self.currentMenuController setMenu:self.currentMenu];
    [self.currentMenuController reloadData];
    
    [self populatePopularTable];
}

- (void)populatePopularTable
{
    NSMutableArray *allCurrentMenuItems = [[NSMutableArray alloc] init];
    for (NSString *key in self.currentMenu) {
        for (MenuItem *menuItemInSection in [self.currentMenu objectForKey:key]) {
            if ([menuItemInSection.likeCount intValue] > 0)
                [allCurrentMenuItems addObject:menuItemInSection];
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"likeCount" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *popularItems = [allCurrentMenuItems sortedArrayUsingDescriptors:sortDescriptors];
    
    [self.popularMenuController setPopularItems:popularItems];
    [self.popularMenuController reloadData];
}

@end
