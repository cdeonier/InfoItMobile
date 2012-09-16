//
//  PopularViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/6/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "PopularViewController.h"

#import "EmptyMenuItemCell.h"
#import "MenuItem.h"
#import "MenuItemCell.h"
#import "OrderedDictionary.h"

@interface PopularViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PopularViewController

@synthesize popularItems = _popularItems;

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
    
    if (_popularItems.count > 0) {
        [_tableView setHidden:NO];
    } else {
        [_tableView setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
    [_tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuItem *menuItem = [_popularItems objectAtIndex:indexPath.row];
    
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_popularItems count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Popular Dishes";

}

- (void)reloadData
{
    if (_popularItems.count > 0) {
        [_tableView setHidden:NO];
        [_tableView reloadData];
    } else {
        [_tableView setHidden:YES];
    }
}

@end
