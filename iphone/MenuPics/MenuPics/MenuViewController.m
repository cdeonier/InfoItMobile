//
//  MenuViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuItemViewController.h"
#import "OrderedDictionary.h"
#import "UIColor+ExtendedColor.h"
#import "MenuItem.h"
#import "Restaurant.h"
#import "ImageUtil.h"
#import "User.h"
#import "MenuItemCell.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

/* General */
@synthesize tabBar = _tabBar;
@synthesize restaurantIdentifier = _restaurantIdentifier;
@synthesize restaurantMenus = _restaurantMenus;
@synthesize menuTypes = _menuTypes;
@synthesize currentMenuType = _currentMenuType;
@synthesize currentMenu = _currentMenu;
@synthesize requestedTab = _requestedTab;
@synthesize contentContainer = _contentContainer;

/* Current Menu */
@synthesize currentMenuTable = _currentMenuTable;

/* Most Liked */
@synthesize mostLikedMenuItems = _mostLikedMenuItems;
@synthesize mostLikedTable = _mostLikedTable;

/* Restaurant */
@synthesize restaurant = _restaurant;
@synthesize restaurantScrollView = _restaurantScrollView;
@synthesize restaurantName = _restaurantName;
@synthesize restaurantDescription = _restaurantDescription;
@synthesize addressContainer = _addressContainer;
@synthesize addressOne = _addressOne;
@synthesize addressTwo = _addressTwo;
@synthesize cityStateZip = _cityStateZip;
@synthesize phoneNumber = _phoneNumber;

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
    [_contentContainer addSubview:currentMenuView];
    
    self.currentMenuTable.tableFooterView = [UIView new];
    
    [self getMenu:self.restaurantIdentifier];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self currentMenu]) {
        [self.currentMenuTable reloadData];
        [self populateMostLikedTable];
        [self.mostLikedTable reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Webservice

- (void)getMenu:(NSNumber *)restaurantIdentifier
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *urlString = [NSString stringWithFormat:@"https://infoit-app.herokuapp.com/services/%@", [self.restaurantIdentifier stringValue]];
    
    User *currentUser = [User currentUser];
    if (currentUser) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", [currentUser accessToken]]];
    }
    
    NSLog(@"URL String: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
    {
        NSLog(@"Menu Success");
        //NSLog(@"Menu: %@", JSON);

        id entityJson = [JSON valueForKey:@"entity"];
        //NSLog(@"%@", entityJson);
        id placeDetailsJson = [entityJson valueForKey:@"place_details"];
        id addressJson = [placeDetailsJson valueForKey:@"address"];
        id contactJson = [placeDetailsJson valueForKey:@"contact_information"];
        NSArray *menuItemsJson = [placeDetailsJson objectForKey:@"menu_items"];

        [self.restaurant setEntityId:[entityJson valueForKey:@"id"]];
        [self.restaurant setName:[entityJson valueForKey:@"name"]];
        [self.restaurant setDescription:[entityJson valueForKey:@"description"]];
        [self.restaurant setProfilePhotoUrl:[entityJson valueForKey:@"profile_photo"]];
        [self.restaurant setStreetOne:[addressJson valueForKey:@"street_address_one"]];
        [self.restaurant setStreetTwo:[addressJson valueForKey:@"street_address_two"]];
        [self.restaurant setCity:[addressJson valueForKey:@"city"]];
        [self.restaurant setState:[addressJson valueForKey:@"state"]];
        [self.restaurant setZipCode:[addressJson valueForKey:@"zip_code"]];
        [self.restaurant setPhone:[contactJson valueForKey:@"phone"]];
        
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
            
            MenuItem *menuItemRecord = [[MenuItem alloc] init];
            [menuItemRecord setName:[menuItem valueForKey:@"name"]];
            [menuItemRecord setDescription:[menuItem valueForKey:@"description"]];
            [menuItemRecord setCategory:[menuItem valueForKey:@"menu_category"]];
            [menuItemRecord setPrice:[menuItem valueForKey:@"price"]];
            [menuItemRecord setLikeCount:[menuItem valueForKey:@"like_count"]];
            [menuItemRecord setMenuType:[menuItem valueForKey:@"menu_type"]];
            
            int photoCount = [[menuItem valueForKey:@"photo_count"] intValue] + [[menuItem valueForKey:@"external_photo_count"] intValue];
            [menuItemRecord setPhotoCount:[NSNumber numberWithInt:photoCount]];
            //NSLog(@"Menu Item Name: %@ with # photos: %@", [menuItemRecord name], [[menuItemRecord photoCount] stringValue]);
            
            if ([[menuItem objectForKey:@"profile_photo_type"] isEqualToString:@"ExternalPhoto"]) {
                [menuItemRecord setSmallThumbnailUrl:[menuItem valueForKey:@"profile_photo_thumbnail"]];
                [menuItemRecord setLargeThumbnailUrl:[menuItem valueForKey:@"profile_photo_thumbnail"]];
            } else {
                [menuItemRecord setSmallThumbnailUrl:[menuItem valueForKey:@"profile_photo_thumbnail_100x100"]];
                [menuItemRecord setLargeThumbnailUrl:[menuItem valueForKey:@"profile_photo_thumbnail_200x200"]];
            }
            
            [menuItemRecord setProfilePhotoUrl:[menuItem valueForKey:@"profile_photo"]];
            [menuItemRecord setEntityId:[menuItem valueForKey:@"entity_id"]];
            [menuItemRecord setRestaurantId:self.restaurantIdentifier];
            BOOL isLiked = [[[menuItem valueForKey:@"logged_in_user"] valueForKey:@"liked"] boolValue];
            if (isLiked) {
                [menuItemRecord setIsLiked:YES];
            } else {
                [menuItemRecord setIsLiked:NO];
            }
            
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

        
        [SVProgressHUD dismiss];
    } 
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"Menu Failure");
        [SVProgressHUD showErrorWithStatus:@"Connection Error"];
    }];
    [operation start];
}

#pragma mark SignInDelegate

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn
{
    if (didSignIn) {
        [self dismissModalViewControllerAnimated:NO];
        [self takePhoto];  
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark TakePhotoDelegate

- (void)takePhotoViewController:(TakePhotoViewController *)takePhotoViewController didSavePhotos:(BOOL)didSavePhotos
{
    if (didSavePhotos && [takePhotoViewController menuItemId] != nil) {
        [self.currentMenuTable reloadData];
        [self.mostLikedTable reloadData];
    }
    
    [self changeViewForTabIndex:CurrentMenuTab];
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
        
        NSString *sectionKey = [self.currentMenu keyAtIndex:indexPath.section];
        MenuItem *menuItem = [[self.currentMenu objectForKey:sectionKey] objectAtIndex:indexPath.row];
        
        if (cell == nil) {            
            cell = [self createMenuItemCell:menuItem];
        }
        
        if ([menuItem thumbnail]) {
            [[(MenuItemCell *)cell thumbnail] setImage:[menuItem thumbnail]];
            [[(MenuItemCell *)cell addPhotoButton] setHidden:YES];
            [[(MenuItemCell *)cell thumbnail] setHidden:NO];
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
    } else if (tableView == self.mostLikedTable) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        MenuItem *menuItem = [self.mostLikedMenuItems objectAtIndex:indexPath.row];
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
        return @"Popular Dishes";
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
    if (tab != TakePhotoTab) {
        for (UIView *view in _contentContainer.subviews) {
            if (![view isKindOfClass:[UITabBar class]]) {
                [view removeFromSuperview];
            }
        }
        
        //Tab tag index starts at 1
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:(tab - 1)]];
    }
    
    switch (tab) {
        case CurrentMenuTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"CurrentMenuView" owner:self options:nil]; 
            UIView *currentMenuView = [xib objectAtIndex:0];
            [_contentContainer insertSubview:currentMenuView atIndex:0];
            [self setTitle:self.currentMenuType];
            _currentMenuTable.tableFooterView = [UIView new];
            break;
        }
        case MostLikedTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"MostLikedView" owner:self options:nil]; 
            UIView *mostLikedView = [xib objectAtIndex:0];
            [_contentContainer insertSubview:mostLikedView atIndex:0];
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
            [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:(CurrentMenuTab - 1)]];
            
            if ([User currentUser]) {
                [self takePhoto];
            } else {
                SignInViewController *viewController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
                [viewController setDelegate:self];
                [self presentModalViewController:viewController animated:YES];
            }
            
            break;
        }
        case RestaurantTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"RestaurantView" owner:self options:nil]; 
            UIView *restaurantView = [xib objectAtIndex:0];
            [_contentContainer insertSubview:restaurantView atIndex:0];
            
            [self setRestaurantScrollView];
            
            break;
        }
        case AllMenusTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"AllMenusView" owner:self options:nil]; 
            UIView *allMenusView = [xib objectAtIndex:0];
            [_contentContainer insertSubview:allMenusView atIndex:0];
            [self setTitle:@"All Menus"];
            _allMenusTable.tableFooterView = [UIView new];
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
    
    if ([self.mostLikedMenuItems count] > 0) {
        [self.mostLikedTable setHidden:NO];
        self.allMenusTable.tableFooterView = [UIView new];
    } else {
        [self.mostLikedTable setHidden:YES];
    }
}

- (UITableViewCell *) createMenuItemCell:(MenuItem *)menuItem
{
    MenuItemCell *cell = [[MenuItemCell alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    [cell loadMenuItem:menuItem];
    [cell setParentController:self];
    return cell;
}

- (void)takePhoto
{
    TakePhotoViewController *viewController = [[TakePhotoViewController alloc] initWithNibName:@"TakePhotoViewPortrait" bundle:nil];
    [viewController setDelegate:self];
    [viewController setRestaurantId:[self.restaurant entityId]];
    [viewController setRestaurantName:[self.restaurant name]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)initializeRestaurantDescriptionView
{
    [_restaurantDescription setText:[_restaurant description]];
    UIFont *descriptionFont = [UIFont fontWithName:@"GillSans" size:13.0];
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize expectedLabelSize = [[_restaurant description] sizeWithFont:descriptionFont
                                                          constrainedToSize:maximumLabelSize
                                                          lineBreakMode:UILineBreakModeWordWrap];
    CGRect newFrame = _restaurantDescription.frame;
    newFrame.size.height = expectedLabelSize.height;
    _restaurantDescription.frame = newFrame;
}

- (void)initializeAddressView
{
    [_addressOne setText:[_restaurant streetOne]];
    
    if ([_restaurant streetTwo] && ![[_restaurant streetTwo] isEqualToString:@""]) {
        [_addressTwo setText:[_restaurant streetTwo]];
    } else {
        [_addressTwo removeFromSuperview];
        CGRect frame = _cityStateZip.frame;
        frame.origin.y -= _addressTwo.frame.size.height;
        [_cityStateZip setFrame:frame];
        frame = _phoneNumber.frame;
        frame.origin.y -= _addressTwo.frame.size.height;
        [_phoneNumber setFrame:frame];
        frame = _addressContainer.frame;
        frame.size.height -= _addressTwo.frame.size.height;
        [_addressContainer setFrame:frame];
    }
    
    NSString *cityStateZipString = [[_restaurant city] stringByAppendingString:@", "];
    cityStateZipString = [cityStateZipString stringByAppendingString:[_restaurant state]];
    cityStateZipString = [cityStateZipString stringByAppendingString:@" "];
    cityStateZipString = [cityStateZipString stringByAppendingString:[_restaurant zipCode]];
    [_cityStateZip setText:cityStateZipString];
    [_phoneNumber setText:[_restaurant phone]];
}

- (void)setRestaurantScrollView
{
    NSURL *profileImageURL = [NSURL URLWithString:_restaurant.profilePhotoUrl];
    [ImageUtil loadProfileImage:_restaurantScrollView withUrl:profileImageURL];
    
    [_restaurantName setText:[_restaurant name]];
    
    [self initializeRestaurantDescriptionView];
    [self initializeAddressView];
    
    int restaurantDescriptionEnd = _restaurantDescription.frame.origin.y;
    restaurantDescriptionEnd += _restaurantDescription.frame.size.height;
    
    int addressWidth = _addressContainer.frame.size.width;
    int addressHeight = _addressContainer.frame.size.height;
    
    [_addressContainer setFrame:CGRectMake(0, restaurantDescriptionEnd + 15, addressWidth, addressHeight)];
    
    int contentSize = 0;
    contentSize += _restaurantDescription.frame.origin.y;
    contentSize += _restaurantDescription.frame.size.height;
    NSLog(@"contentSize: %d",contentSize);
    contentSize += 5; //padding
    contentSize += _addressContainer.frame.size.height;
    NSLog(@"contentSize: %d",contentSize);
    contentSize += 15; //padding
    [_restaurantScrollView setFrame:CGRectMake(0, 0, 320, 367)];
    [_restaurantScrollView setContentSize:CGSizeMake(320, contentSize)];
    [_restaurantScrollView setBounces:NO];
}

@end
