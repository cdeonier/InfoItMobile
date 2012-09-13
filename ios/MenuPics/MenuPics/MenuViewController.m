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
    
    _currentMenuController = [[self viewControllers] objectAtIndex:0];
    _popularMenuController = [[self viewControllers] objectAtIndex:1];
    _restaurantController = [[self viewControllers] objectAtIndex:2];
    _allMenusController = [[self viewControllers] objectAtIndex:3];
    
    
    [self setSelectedViewController:_currentMenuController];
	
    [self getMenu:_restaurantId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITabBarDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController == _currentMenuController) {
        [self setTitle:_currentMenuType];
    } else if (viewController == _popularMenuController) {
        [self setTitle:@"Popular Items"];
    } else if (viewController == _restaurantController) {
        [self setTitle:[[_restaurantController restaurant] name]];
    } else if (viewController == _allMenusController) {
        [self setTitle:@"Choose Menu"];
    }
}

#pragma mark Web Service

- (void)getMenu:(NSNumber *)restaurantId
{
    id pastJsonResponse = [JSONCachedResponse recentJsonResponse:self withIdentifier:_restaurantId];
    
    if (!pastJsonResponse) {
        [SVProgressHUD showWithStatus:@"Loading"];
    } else {
        [self loadMenuFromJson:pastJsonResponse];
    }
    
    void (^didGetMenuBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didGetMenuBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [JSONCachedResponse saveJsonResponse:self withJsonResponse:JSON withIdentifier:_restaurantId];
        
        [self loadMenuFromJson:JSON];
        
        [SVProgressHUD dismiss];
    };
    
    [MenuPicsAPIClient getMenu:restaurantId success:didGetMenuBlock];
}

- (void)loadMenuFromJson:(id)json
{
    Restaurant *restaurant = [[Restaurant alloc] initWithJson:json];
    [_restaurantController setRestaurant:restaurant];
    [_restaurantController reloadData];
    
    NSArray *menuItemsJson = [json valueForKeyPath:@"entity.place_details.menu_items"];
    _menuTypes = [[NSMutableArray alloc] init];
    _restaurantMenus = [[OrderedDictionary alloc] init];
    
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
            
            [_restaurantMenus setObject:menu forKey:currentMenuType];
            [_menuTypes addObject:currentMenuType];
        }
        
        if (![menuItemCategory isEqualToString:currentCategory]) {
            currentCategory = menuItemCategory;
            categoryItems = [[NSMutableArray alloc] init];
            [menu setObject:categoryItems forKey:currentCategory];
        }
        
        MenuItem *menuItemRecord = [[MenuItem alloc] initWithJson:menuItem];
        [menuItemRecord setRestaurantId:_restaurantId];
        
        [categoryItems addObject:menuItemRecord];
    }
    
    _allMenusController.menuTypes = _menuTypes;
    [_allMenusController reloadData];
    
    _currentMenuType = [_menuTypes objectAtIndex:0];
    
    [self changeMenu:_currentMenuType];
    
    if ([self selectedViewController] == _currentMenuController) {
        [self setTitle:_currentMenuType];
    }
}

#pragma mark Helper Functions

- (void)selectMenu:(NSString *)menuType
{
    [self changeMenu:menuType];
    [self setTitle:_currentMenuType];
    [self setSelectedViewController:_currentMenuController];
}

- (void)changeMenu:(NSString *)menuType
{
    _currentMenuType = menuType;
    _currentMenu = [_restaurantMenus objectForKey:_currentMenuType];
    
    [_currentMenuController setMenu:_currentMenu];
    [_currentMenuController reloadData];
    
    [self populatePopularTable];
}

- (void)populatePopularTable
{
    NSMutableArray *allCurrentMenuItems = [[NSMutableArray alloc] init];
    for (NSString *key in _currentMenu) {
        for (MenuItem *menuItemInSection in [_currentMenu objectForKey:key]) {
            if ([[menuItemInSection likeCount] intValue] > 0)
                [allCurrentMenuItems addObject:menuItemInSection];
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"likeCount" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *popularItems = [allCurrentMenuItems sortedArrayUsingDescriptors:sortDescriptors];
    
    [_popularMenuController setPopularItems:popularItems];
    [_popularMenuController reloadData];
}

@end
