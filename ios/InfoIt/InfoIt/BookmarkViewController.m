//
//  BookmarkViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 3/14/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "BookmarkViewController.h"
#import "MenuDelegate.h"
#import "UIViewController+Menu.h"
#import "UINavigationController+Menu.h"
#import "UINavigationItem+Menu.h"

@interface BookmarkViewController ()

@end

@implementation BookmarkViewController

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(revealLeftMenu:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(revealRightMenu:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Menu

- (void)revealLeftMenu:(id)sender {
    MenuState state = MenuStateLeft;
    if (self.navigationController.menuState == MenuStateLeft) {
        state = MenuStateNone;
    }
    [self.navigationController setMenuState:state];
}

- (void)revealRightMenu:(id)sender {
    MenuState state = MenuStateRight;
    if (self.navigationController.menuState == MenuStateRight) {
        state = MenuStateNone;
    }
    [self.navigationController setMenuState:state];
}

@end
