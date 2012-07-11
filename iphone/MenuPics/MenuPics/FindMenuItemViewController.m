//
//  FindMenuItemViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 7/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "FindMenuItemViewController.h"
#import "AppDelegate.h"
#import "MenuItem.h"
#import "MenuItemCell.h"
#import "SavedPhoto.h"
#import "SavedPhoto+Syncing.h"
#import "OrderedDictionary.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface FindMenuItemViewController ()

@end

@implementation FindMenuItemViewController

@synthesize photoId = _photoId;
@synthesize tabBar = _tabBar;
@synthesize restaurantIdentifier = _restaurantIdentifier;
@synthesize menuTypes = _menuTypes;
@synthesize restaurantMenus= _restaurantMenus;
@synthesize currentMenuType = _currentMenuType;
@synthesize currentMenu = _currentMenu;
@synthesize actionSheet = _actionSheet;

@synthesize currentMenuTable = _currentMenuTable;
@synthesize allMenusTable = _allMenusTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getMenu:self.restaurantIdentifier];
    
    self.restaurantMenus = [[OrderedDictionary alloc] init];
    self.menuTypes = [[NSMutableArray alloc] init];
    
    self.allMenusTable.tableFooterView = [UIView new];
    
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Tag Item" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tag Photo", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Webservice

- (void)getMenu:(NSInteger *)restaurantIdentifier
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *urlString = [NSString stringWithFormat:@"https://infoit-app.herokuapp.com/menus/%d", self.restaurantIdentifier];
    
    NSLog(@"URL String: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
    {
        NSLog(@"Menu Success");
        
        OrderedDictionary *menu;
        NSMutableArray *categoryItems;
        
        NSString *currentMenuType = nil;
        NSString *currentCategory = nil;
        
        for (id menuItemJson in [[JSON valueForKey:@"entity"] valueForKey:@"menu_items"]) {
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
            
            if ([[menuItem objectForKey:@"profile_photo_type"] isEqualToString:@"ExternalPhoto"]) {
                [menuItemRecord setSmallThumbnailUrl:[menuItem valueForKey:@"profile_photo_thumbnail"]];
                [menuItemRecord setLargeThumbnailUrl:[menuItem valueForKey:@"profile_photo_thumbnail"]];
            } else {
                [menuItemRecord setSmallThumbnailUrl:[menuItem valueForKey:@"profile_photo_thumbnail_100x100"]];
                [menuItemRecord setLargeThumbnailUrl:[menuItem valueForKey:@"profile_photo_thumbnail_200x200"]];
            }
            
            [menuItemRecord setProfilePhotoUrl:[menuItem valueForKey:@"profile_photo"]];
            [menuItemRecord setEntityId:[menuItem valueForKey:@"entity_id"]];
            [menuItemRecord setRestaurantId:[NSNumber numberWithInt:(int)self.restaurantIdentifier]];
            BOOL isLiked = [[[menuItem valueForKey:@"logged_in_user"] valueForKey:@"liked"] boolValue];
            if (isLiked) {
                [menuItemRecord setIsLiked:YES];
            } else {
                [menuItemRecord setIsLiked:NO];
            }
            
            [categoryItems addObject:menuItemRecord];
            
            self.currentMenu = [self.restaurantMenus objectForKey:[self.menuTypes objectAtIndex:0]];
            self.currentMenuType = [self.menuTypes objectAtIndex:0];
            [self setTitle:self.currentMenuType];
            
            [self.currentMenuTable reloadData];
            [self.allMenusTable reloadData];
        }
        
        [self changeViewForTabIndex:FindCurrentMenuTab];
        [SVProgressHUD dismiss];
    } 
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"Menu Failure");
        [SVProgressHUD showErrorWithStatus:@"Connection Error"];
    }];
    [operation start];
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
        
        if ([menuItem smallThumbnailUrl]) {
            if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                ([UIScreen mainScreen].scale == 2.0)) {
                [[(MenuItemCell *)cell thumbnail] setImageWithURL:[NSURL URLWithString:menuItem.largeThumbnailUrl]];
            } else {
                [[(MenuItemCell *)cell thumbnail] setImageWithURL:[NSURL URLWithString:menuItem.smallThumbnailUrl]];
            }
            [[(MenuItemCell *)cell addPhotoButton] setHidden:YES];
            [[(MenuItemCell *)cell thumbnail] setHidden:NO];
        } else {
            [[(MenuItemCell *)cell thumbnail] setImage:[UIImage imageNamed:@"no_photo"]];
            [[(MenuItemCell *)cell addPhotoButton] setHidden:YES];
            [[(MenuItemCell *)cell thumbnail] setHidden:NO];
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
        NSString *sectionKey = [self.currentMenu keyAtIndex:indexPath.section];
        MenuItem *menuItem = [[self.currentMenu objectForKey:sectionKey] objectAtIndex:indexPath.row];
        [_actionSheet setTitle:[NSString stringWithFormat:@"Tag Photo as \"%@\"", menuItem.name]];
        [_actionSheet showFromTabBar:_tabBar];
    } else if (tableView == self.allMenusTable) {
        self.currentMenuType = [self.menuTypes objectAtIndex:indexPath.row];
        self.currentMenu = [self.restaurantMenus objectForKey:self.currentMenuType];
        [self setTitle:self.currentMenuType];
        [self.currentMenuTable reloadData];
        [self changeViewForTabIndex:FindCurrentMenuTab];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.currentMenuTable) {
        return [self.currentMenu keyAtIndex:section];
    } 
    
    return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.currentMenuTable) {
        return [self.currentMenu count];
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
    }
    
    return 44.0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.currentMenuTable) {
        return [[self.currentMenu objectForKey:[self.currentMenu keyAtIndex:section]] count];
    } else if (tableView == self.allMenusTable) {
        return [self.menuTypes count];
    }
    
    return 0;
}

- (UITableViewCell *) createMenuItemCell:(MenuItem *)menuItem
{
    MenuItemCell *cell = [[MenuItemCell alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    [cell loadMenuItem:menuItem];
    return cell;
}

#pragma mark UIActionSheet Delegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [_currentMenuTable indexPathForSelectedRow];
    
    if (buttonIndex == 0) {
        NSString *sectionKey = [self.currentMenu keyAtIndex:indexPath.section];
        MenuItem *menuItem = [[self.currentMenu objectForKey:sectionKey] objectAtIndex:indexPath.row];
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
        [request setEntity:entity];
        
        NSString *predicateString = [NSString stringWithFormat:@"photoId == %d", [self photoId]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
        SavedPhoto *savedPhoto = [mutableFetchResults objectAtIndex:0];
        
        [savedPhoto setMenuItemId:[menuItem entityId]];
        [savedPhoto setRestaurantId:[menuItem restaurantId]];
        
        if (![context save:&error]) {
            NSLog(@"Error saving to Core Data");
        }
        
        [SavedPhoto tagPhoto:savedPhoto];
    }
    
    [_currentMenuTable deselectRowAtIndexPath:indexPath animated:YES];
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    NSIndexPath *indexPath = [_currentMenuTable indexPathForSelectedRow];
    [_currentMenuTable deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Helper Functions

- (void) changeViewForTabIndex:(FindMenuItemTab)tab
{
    for (UIView *view in self.view.subviews) {
        if (![view isKindOfClass:[UITabBar class]]) {
            [view removeFromSuperview];
        }
    }
    
    //Tab tag index starts at 1
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:(tab - 1)]];
    
    switch (tab) {
        case FindCurrentMenuTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"TagCurrentMenuView" owner:self options:nil]; 
            UIView *currentMenuView = [xib objectAtIndex:0];
            [self.view insertSubview:currentMenuView atIndex:0];
            [self setTitle:self.currentMenuType];
            
            _currentMenuTable = (UITableView *)currentMenuView;
            
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            
            UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            [instructions setText:@"Choose photo's menu item"];
            [instructions setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:12.0]];
            [instructions setTextColor:[UIColor whiteColor]];
            [instructions setBackgroundColor:[UIColor lightGrayColor]];
            [instructions setTextAlignment:UITextAlignmentCenter];
            [headerView addSubview:instructions];
            
            _currentMenuTable.tableHeaderView = headerView;
            
            _currentMenuTable.tableFooterView = [UIView new];
            
            break;
        }
        case FindAllMenusTab: {
            NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"TagAllMenusView" owner:self options:nil]; 
            UIView *allMenusView = [xib objectAtIndex:0];
            [self.view insertSubview:allMenusView atIndex:0];
            [self setTitle:@"All Menus"];
            
            _allMenusTable = (UITableView *)allMenusView;
            
            _allMenusTable.tableFooterView = [UIView new];
            
            break;
        }
        default:
            break;
    }
}

@end
