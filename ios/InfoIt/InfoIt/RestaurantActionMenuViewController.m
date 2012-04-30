//
//  RestaurantActionMenuViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 4/7/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "RestaurantActionMenuViewController.h"
#import "ImageUtil.h"

@interface RestaurantActionMenuViewController ()

@end

@implementation RestaurantActionMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"RestaurantActionMenuViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeBookmarkButton];
    [self initializeViewMenuButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) initializeBookmarkButton
{
    UIImage *bookmarkImage = [UIImage imageNamed:@"bookmark_icon.png"];
    UIImage *bookmarkIcon = 
        [ImageUtil imageWithImage:bookmarkImage scaledToSize:CGSizeMake(25, 25)];
    [bookmarkButton setImage:bookmarkIcon forState:UIControlStateNormal];
    
    [bookmarkButton setTitle:@"Bookmark" forState:UIControlStateNormal];
    [bookmarkButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}

- (void) initializeViewMenuButton
{
    UIImage *viewMenuImage = [UIImage imageNamed:@"menu_icon.png"];
    UIImage *viewMenuIcon = 
        [ImageUtil imageWithImage:viewMenuImage scaledToSize:CGSizeMake(25, 25)];
    [viewMenuButton setImage:viewMenuIcon forState:UIControlStateNormal];
    
    [viewMenuButton setTitle:@"View Menu" forState:UIControlStateNormal];
    [viewMenuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}

@end
