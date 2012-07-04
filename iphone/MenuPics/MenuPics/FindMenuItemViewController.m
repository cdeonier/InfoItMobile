//
//  FindMenuItemViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 7/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "FindMenuItemViewController.h"

@interface FindMenuItemViewController ()

@end

@implementation FindMenuItemViewController

@synthesize tabBar = _tabBar;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self changeViewForTabIndex:item.tag];
}

#pragma mark Helper Functions

- (void) changeViewForTabIndex:(FindMenuItemTab)tab
{
    switch (tab) {
        case CurrentMenuTab:
            break;
        case AllMenusTab:
            break;
        default:
            break;
    }
}

@end
