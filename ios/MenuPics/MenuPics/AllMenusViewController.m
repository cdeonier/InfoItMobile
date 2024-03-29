//
//  AllMenusViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/6/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "AllMenusViewController.h"

#import "AllMenusCell.h"
#import "MenuViewController.h"

@interface AllMenusViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AllMenusViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

# pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AllMenusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AllMenusCell"];
    [cell.menuTypeName setText:[self.menuTypes objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuTypes count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *selectedMenuType = [self.menuTypes objectAtIndex:indexPath.row];
    [(MenuViewController *)self.parentViewController selectMenu:selectedMenuType];
}

- (void)reloadData
{
    [self.tableView reloadData];
}


@end
