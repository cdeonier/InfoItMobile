//
//  CurrentMenuViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/5/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CurrentMenuViewController.h"

#import "EmptyMenuItemCell.h"
#import "MenuItem.h"
#import "MenuItemCell.h"
#import "OrderedDictionary.h"
#import "UIImageView+WebCache.h"

@interface CurrentMenuViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation CurrentMenuViewController

@synthesize menu = _menu;

@synthesize tableView = _tableView;

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
    
    [_tableView setTableFooterView:[UIView new]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Table Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionKey = [_menu keyAtIndex:indexPath.section];
    MenuItem *menuItem = [[_menu objectForKey:sectionKey] objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
    
    if ([menuItem smallThumbnailUrl]) {
        MenuItemCell *menuItemCell = (MenuItemCell *)[tableView dequeueReusableCellWithIdentifier:@"MenuItemCell"];
        
        [menuItemCell styleCell:menuItem];
        
        cell = menuItemCell;
    } else {
        EmptyMenuItemCell *menuItemCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyMenuItemCell"];
        [menuItemCell styleCell:menuItem];
        
        [menuItemCell.name setText:[menuItem name]];
        
        cell = menuItemCell;
    }
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [_menu count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_menu objectForKey:[_menu keyAtIndex:section]] count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_menu keyAtIndex:section];
}

#pragma mark Helper Functions

- (void)reloadData
{
    [_tableView reloadData];
}

@end
