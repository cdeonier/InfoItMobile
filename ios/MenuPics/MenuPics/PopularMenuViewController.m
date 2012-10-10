//
//  PopularViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/6/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "PopularMenuViewController.h"

#import "EmptyMenuItemCell.h"
#import "MenuItem.h"
#import "MenuItemCell.h"
#import "MenuItemViewController.h"
#import "MenuViewController.h"
#import "OrderedDictionary.h"
#import "Photo.h"
#import "TakePhotoViewController.h"

@interface PopularMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PopularMenuViewController

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

#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MenuItemViewController class]]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        MenuItem *menuItem = [self.popularItems objectAtIndex:selectedIndexPath.row];
        
        MenuItemViewController *menuItemViewController = [segue destinationViewController];
        [menuItemViewController setMenuItem:menuItem];
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
