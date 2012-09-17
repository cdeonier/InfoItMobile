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
    
    if (self.popularItems.count > 0) {
        [self.tableView setHidden:NO];
    } else {
        [self.tableView setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuItem *menuItem = [self.popularItems objectAtIndex:indexPath.row];
    
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
    return [self.popularItems count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Popular Dishes";

}

- (void)reloadData
{
    if (self.popularItems.count > 0) {
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    } else {
        [self.tableView setHidden:YES];
    }
}

@end
