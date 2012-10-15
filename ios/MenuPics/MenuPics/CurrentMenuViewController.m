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
#import "MenuItemViewController.h"
#import "MenuViewController.h"
#import "OrderedDictionary.h"
#import "Photo.h"
#import "UIImageView+WebCache.h"

@interface CurrentMenuViewController ()

@end

@implementation CurrentMenuViewController

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
    
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Table Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionKey = [self.menu keyAtIndex:indexPath.section];
    MenuItem *menuItem = [[self.menu objectForKey:sectionKey] objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
    
    if ([menuItem thumbnailUrl] || [menuItem thumbnail]) {
        MenuItemCell *menuItemCell = (MenuItemCell *)[tableView dequeueReusableCellWithIdentifier:@"MenuItemCell"];
        
        [menuItemCell setMenuItem:menuItem];
        [menuItemCell setViewController:self];
        [menuItemCell styleCell:menuItem];
        
        cell = menuItemCell;
    } else {
        EmptyMenuItemCell *menuItemCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyMenuItemCell"];
        
        [menuItemCell setMenuItem:menuItem];
        [menuItemCell setViewController:self];
        [menuItemCell styleCell:menuItem];
        
        //[menuItemCell.name setText:[menuItem name]];
        
        cell = menuItemCell;
    }
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.menu count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.menu objectForKey:[self.menu keyAtIndex:section]] count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.menu keyAtIndex:section];
}

#pragma mark TakePhotoDelegate

- (void)didTakePhoto:(TakePhotoViewController *)viewController
{
    MenuItem *menuItem = viewController.menuItem;
    
    if (!menuItem.thumbnailUrl) {
        [menuItem setThumbnail:viewController.photo.thumbnail];
        [(MenuViewController *)self.parentViewController reloadData];
    }
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Helper Functions

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MenuItemViewController class]]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        NSString *sectionKey = [self.menu keyAtIndex:selectedIndexPath.section];
        MenuItem *menuItem = [[self.menu objectForKey:sectionKey] objectAtIndex:selectedIndexPath.row];
        
        MenuItemViewController *menuItemViewController = [segue destinationViewController];
        [menuItemViewController setMenuItem:menuItem];
        [menuItemViewController setMenuViewController:(MenuViewController *)self.parentViewController];
    } else if ([segue.destinationViewController isKindOfClass:[TakePhotoViewController class]]) {
        MenuItem *menuItem;
        
        if ([sender isKindOfClass:[MenuItemCell class]]) {
            menuItem = [(MenuItemCell *)sender menuItem];
        } else {
            menuItem = [(EmptyMenuItemCell *)sender menuItem];
        }
        
        TakePhotoViewController *takePhotoViewController = [segue destinationViewController];
        [takePhotoViewController setDelegate:self];
        [takePhotoViewController setMenuItem:menuItem];
    } else if ([segue.destinationViewController isKindOfClass:[SignInViewController class]]) {
        [(SignInViewController *)segue.destinationViewController setDelegate:sender];
    }
}

@end
