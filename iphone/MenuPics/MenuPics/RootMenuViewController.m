//
//  MenuViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "RootMenuViewController.h"
#import "MenuItemViewController.h"
#import "OrderedDictionary.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+ExtendedColor.h"
#import "MenuItem.h"
#import "Restaurant.h"
#import "ImageUtil.h"
#import <QuartzCore/QuartzCore.h>

@interface RootMenuViewController ()

@end

@implementation RootMenuViewController

/* General */
@synthesize tabBar = _tabBar;
@synthesize responseData = _responseData;
@synthesize restaurantIdentifier = _restaurantIdentifier;
@synthesize restaurantMenus = _restaurantMenus;
@synthesize menuTypes = _menuTypes;
@synthesize currentMenuType = _currentMenuType;
@synthesize currentMenu = _currentMenu;
@synthesize requestedTab = _requestedTab;

/* Current Menu */
@synthesize currentMenuTable = _currentMenuTable;

/* Most Liked */
@synthesize mostLikedMenuItems = _mostLikedMenuItems;
@synthesize mostLikedTable = _mostLikedTable;

/* Restaurant */
@synthesize restaurant = _restaurant;

/* All Menus */
@synthesize allMenusTable = _allMenusTable;

#pragma mark View

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
    
    self.responseData = [[NSMutableData alloc] init];
    
    self.restaurantMenus = [[OrderedDictionary alloc] init];
    self.menuTypes = [[NSMutableArray alloc] init];
    
    self.restaurant = [[Restaurant alloc] init];

    if (![self.requestedTab isEqual:[NSNull null]] && [self.requestedTab isEqualToString:@"Restaurant"]) {
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:3]];
    } else {
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    }
    
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"CurrentMenuView" owner:self options:nil]; 
    UIView *currentMenuView = [xib objectAtIndex:0];
    [self.view addSubview:currentMenuView];
    
    self.currentMenuTable.tableFooterView = [UIView new];
    self.allMenusTable.tableFooterView = [UIView new];
    
    [self restGetRestaurantMenus:self.restaurantIdentifier];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Webservice Connection

- (void)restGetRestaurantMenus:(NSNumber *)restaurantIdentifier
{
    NSString *url = [NSString stringWithFormat:@"http://www.getinfoit.com/services/%@", [restaurantIdentifier description]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    (void) [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{        
    [self.responseData appendData:data]; 
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{    
    NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    NSError *myError = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSDictionary *entityJson = [jsonResponse objectForKey:@"entity"];
    NSDictionary *placeDetailsJson = [entityJson objectForKey:@"place_details"];
    NSDictionary *addressJson = [placeDetailsJson objectForKey:@"address"];
    NSArray *menuItemsJson = [placeDetailsJson objectForKey:@"menu_items"];
    
    [self.restaurant setName:[entityJson objectForKey:@"name"]];
    [self.restaurant setDescription:[entityJson objectForKey:@"description"]];
    [self.restaurant setProfilePictureUrl:[entityJson objectForKey:@"profile_photo_url"]];
    [self.restaurant setStreetOne:[addressJson objectForKey:@"street_address_one"]];
    [self.restaurant setStreetTwo:[addressJson objectForKey:@"street_address_two"]];
    [self.restaurant setCity:[addressJson objectForKey:@"city"]];
    [self.restaurant setState:[addressJson objectForKey:@"state"]];
    [self.restaurant setZipCode:[addressJson objectForKey:@"zip_code"]];
    
    OrderedDictionary *menu;
    NSMutableArray *categoryItems;
    
    NSString *currentMenuType = nil;
    NSString *currentCategory = nil;
    
    for (id menuItemJson in menuItemsJson) {
        NSDictionary *menuItem = [menuItemJson objectForKey:@"menu_item"];
        
        NSString *menuItemMenuType = [menuItem objectForKey:@"menu_type"];
        NSString *menuItemCategory = [menuItem objectForKey:@"menu_category"];
        
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
        
        MenuItem *menuItemRecord = [[MenuItem alloc] init];
        [menuItemRecord setName:[menuItem objectForKey:@"name"]];
        [menuItemRecord setDescription:[menuItem objectForKey:@"description"]];
        [menuItemRecord setCategory:[menuItem objectForKey:@"menu_category"]];
        [menuItemRecord setPrice:[menuItem objectForKey:@"price"]];
        [menuItemRecord setLikeCount:[menuItem objectForKey:@"like_count"]];
        [menuItemRecord setMenuType:[menuItem objectForKey:@"menu_type"]];
        [menuItemRecord setThumbnailUrl:[menuItem objectForKey:@"profile_photo_thumbnail_url"]];
        [menuItemRecord setProfilePictureUrl:[menuItem objectForKey:@"profile_photo_url"]];
        [menuItemRecord setEntityId:[menuItem objectForKey:@"entity_id"]];
        [menuItemRecord setRestaurantId:self.restaurantIdentifier];
        
        [categoryItems addObject:menuItemRecord];
    }
    
    self.currentMenu = [self.restaurantMenus objectForKey:[self.menuTypes objectAtIndex:0]];
    self.currentMenuType = [self.menuTypes objectAtIndex:0];
    [self populateMostLikedTable];
    [self.currentMenuTable reloadData];
    [self.mostLikedTable reloadData];
    [self.allMenusTable reloadData];
    
    if (![self.requestedTab isEqual:[NSNull null]] && [self.requestedTab isEqualToString:@"Restaurant"]) {
        [self setTitle:[self.restaurant name]];
        [self changeViewForTabIndex:RestaurantTab];
    } else {
        [self setTitle:self.currentMenuType];
    }
    
        
    
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self changeViewForTabIndex:item.tag];
}

#pragma mark TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.currentMenuTable) {
        static NSString *CellIdentifier = @"MenuItemCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {            
            NSString *sectionKey = [self.currentMenu keyAtIndex:indexPath.section];
            MenuItem *menuItem = [[self.currentMenu objectForKey:sectionKey] objectAtIndex:indexPath.row];
            cell = [self createMenuItemCell:menuItem];
        }
        
        return cell;
    } else if (tableView == self.mostLikedTable) {
        static NSString *CellIdentifier = @"MostLikedCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            MenuItem *menuItem = [self.mostLikedMenuItems objectAtIndex:indexPath.row];
            cell = [self createMenuItemCell:menuItem];
        }
        
        return cell;
    } else if (tableView == self.allMenusTable) {
        static NSString *CellIdentifier = @"AllMenusCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.textLabel setText:[self.menuTypes objectAtIndex:indexPath.row]];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.currentMenuTable) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString *sectionKey = [self.currentMenu keyAtIndex:indexPath.section];
        MenuItem *menuItem = [[self.currentMenu objectForKey:sectionKey] objectAtIndex:indexPath.row];
        
        MenuItemViewController *viewController = [[MenuItemViewController alloc] initWithNibName:@"MenuItemViewController" bundle:nil];
        [viewController setMenuItem:menuItem];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:nil action:nil];
        [backButton setTintColor:[UIColor navBarButtonColor]];
        [self.navigationItem setBackBarButtonItem:backButton];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (tableView == self.allMenusTable) {
        self.currentMenuType = [self.menuTypes objectAtIndex:indexPath.row];
        self.currentMenu = [self.restaurantMenus objectForKey:self.currentMenuType];
        [self populateMostLikedTable];
        [self setTitle:self.currentMenuType];
        [self.currentMenuTable reloadData];
        [self changeViewForTabIndex:CurrentMenuTab];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.currentMenuTable) {
        return [self.currentMenu keyAtIndex:section];
    } else if (tableView == self.mostLikedTable) {
        return @"Most Popular Dishes";
    }
    
    return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.currentMenuTable) {
        return [self.currentMenu count];
    } else if (tableView == self.mostLikedTable) {
        return 1;
    } else if (tableView == self.allMenusTable) {
        return 1;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.currentMenuTable) {
        NSString *sectionKey = [self.currentMenu keyAtIndex:indexPath.section];
        MenuItem *menuItem = [[self.currentMenu objectForKey:sectionKey] objectAtIndex:indexPath.row];
        if ([[menuItem description] length] > 0) {
            return 150.0;
        } else {
            return 110.0;
        }
    } else if (tableView == self.mostLikedTable) {
        MenuItem *menuItem = [self.mostLikedMenuItems objectAtIndex:indexPath.row];
        if ([[menuItem description] length] > 0) {
            return 150.0;
        } else {
            return 110.0;
        }
    }
    
    return 44.0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.currentMenuTable) {
        return [[self.currentMenu objectForKey:[self.currentMenu keyAtIndex:section]] count];
    } else if (tableView == self.mostLikedTable) {
        return [self.mostLikedMenuItems count];
    } else if (tableView == self.allMenusTable) {
        return [self.menuTypes count];
    }
    
    return 0;
}

#pragma mark Helper Functions

- (void) changeViewForTabIndex:(MenuTab)tab
{
    for (UIView *view in self.view.subviews) {
        if (![view isKindOfClass:[UITabBar class]]) {
            [view removeFromSuperview];
        }
    }
    
    //Tab tag index starts at 1
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:(tab - 1)]];
    
    switch (tab) {
        case CurrentMenuTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"CurrentMenuView" owner:self options:nil]; 
            UIView *currentMenuView = [xib objectAtIndex:0];
            [self.view addSubview:currentMenuView];
            [self setTitle:self.currentMenuType];
            break;
        }
        case MostLikedTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"MostLikedView" owner:self options:nil]; 
            UIView *mostLikedView = [xib objectAtIndex:0];
            [self.view addSubview:mostLikedView];
            [self setTitle:self.currentMenuType];
            if ([self.mostLikedMenuItems count] > 0) {
                [self.mostLikedTable setHidden:NO];
                self.allMenusTable.tableFooterView = [UIView new];
            } else {
                [self.mostLikedTable setHidden:YES];
            }
            break;
        }
        case TakePhotoTab: {
            
        }
        case RestaurantTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"RestaurantView" owner:self options:nil]; 
            UIView *restaurantView = [xib objectAtIndex:0];
            [self.view addSubview:restaurantView];
            UIScrollView *scrollView = (UIScrollView *)[restaurantView viewWithTag:1000];
            [scrollView setFrame:CGRectMake(0, 0, 320, 367)];
            [scrollView setContentSize:CGSizeMake(320, 600)];
            
            [ImageUtil initializeProfileImage:self.view withUrl:[self.restaurant profilePictureUrl]];
                        
            UILabel *restaurantName = (UILabel *)[restaurantView viewWithTag:202];
            [restaurantName setText:[self.restaurant name]];

            UILabel *restaurantDescription = (UILabel *)[restaurantView viewWithTag:203];
            [restaurantDescription setText:[self.restaurant description]];
            UIFont *descriptionFont = [UIFont fontWithName:@"GillSans" size:13.0];
            CGSize maximumLabelSize = CGSizeMake(296,9999);
            
            CGSize expectedLabelSize = [[self.restaurant description] sizeWithFont:descriptionFont
                                                                      constrainedToSize:maximumLabelSize
                                                                      lineBreakMode:UILineBreakModeWordWrap]; 
            
            CGRect newFrame = restaurantDescription.frame;
            newFrame.size.height = expectedLabelSize.height;
            restaurantDescription.frame = newFrame;
            break;
        }
        case AllMenusTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"AllMenusView" owner:self options:nil]; 
            UIView *allMenusView = [xib objectAtIndex:0];
            [self.view addSubview:allMenusView];
            [self setTitle:@"All Menus"];
            break;
        }
        default:
            break;
    }
}

- (void) populateMostLikedTable
{
    NSMutableArray *allCurrentMenuItems = [[NSMutableArray alloc] init];
    for (NSString *key in self.currentMenu) {
        for (MenuItem *menuItemInSection in [self.currentMenu objectForKey:key]) {
            if ([[menuItemInSection likeCount] intValue] > 0)
                [allCurrentMenuItems addObject:menuItemInSection];
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"likeCount" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.mostLikedMenuItems = [allCurrentMenuItems sortedArrayUsingDescriptors:sortDescriptors];
}

- (UITableViewCell *) createMenuItemCell:(MenuItem *)menuItem
{
    [[NSBundle mainBundle] loadNibNamed:@"MenuItemCell" owner:self options:nil];
    UITableViewCell *cell = menuItemCell;
    menuItemCell = nil;
    
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    NSString *nameString = [menuItem name];
    if ([nameString length] < 40) {
        [name setText:nameString];
    } else {
        NSString *truncatedNameString = [nameString substringToIndex:37 ];
        [name setText:[NSString stringWithFormat:@"%@...", truncatedNameString]];
    }
    [name setNumberOfLines:0];
    [name setFrame:CGRectMake(115, 5, 150, 45)];
    [name sizeToFit];
    
    UILabel *price = (UILabel *)[cell viewWithTag:2];
    price.text = [NSString stringWithFormat:@"$%@", menuItem.price];
    
    UILabel *description = (UILabel *)[cell viewWithTag:3];
    if ([[menuItem description] length] > 0) {
        NSString *descriptionString = menuItem.description;
        if ([descriptionString length] < 100) {
            [description setText:descriptionString];
        } else {
            NSString *truncatedDescriptionString = [descriptionString substringToIndex:100];
            [description setText:[NSString stringWithFormat:@"%@...", truncatedDescriptionString]];
        }
        
        description.lineBreakMode = UILineBreakModeTailTruncation;
        [description setNumberOfLines:0];
        [description setFrame:CGRectMake(5, 110, 310, 40)];
        [description sizeToFit];
    } else {
        [description setHidden:YES];
    }
    
    UIImageView *thumbnail = (UIImageView *)[cell viewWithTag:4];
    [thumbnail.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [thumbnail.layer setBorderWidth:1.0];
    if (![menuItem.thumbnailUrl isEqual:[NSNull null]]) {
        [thumbnail setImageWithURL:[NSURL URLWithString:menuItem.thumbnailUrl]];
    } else {
        [thumbnail setImage:[UIImage imageNamed:@"add_photo"]];
    }
    
    UIImageView *likeIcon = (UIImageView *)[cell viewWithTag:5];
    UILabel *likeCount = (UILabel *)[cell viewWithTag:6];
    if ([[menuItem likeCount] intValue] > 1) {
        [likeCount setText:[NSString stringWithFormat:@"%@ likes", [[menuItem likeCount] description]]];
    } else if ([[menuItem likeCount] intValue] > 0) {
        [likeCount setText:[NSString stringWithFormat:@"%@ like", [[menuItem likeCount] description]]];
    } else {
        [likeIcon setHidden:YES];
        [likeCount setHidden:YES];
    }
    
    return cell;
}

@end
