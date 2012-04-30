//
//  NavigationMenuViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 4/3/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "NavigationMenuViewController.h"
#import "ImageUtil.h"

@interface NavigationMenuViewController ()

@end

@implementation NavigationMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"NavigationMenuViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeBookmarkButton];
    [self initializeRecentHistoryButton];
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
    
    [bookmarkButton setTitle:@"My Bookmarks" forState:UIControlStateNormal];
    [bookmarkButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}

- (void) initializeRecentHistoryButton
{
    UIImage *recentHistoryImage = [UIImage imageNamed:@"history_icon.png"];
    UIImage *recentHistoryIcon = 
        [ImageUtil imageWithImage:recentHistoryImage scaledToSize:CGSizeMake(25, 25)];
    [recentHistoryButton setImage:recentHistoryIcon forState:UIControlStateNormal];
    
    [recentHistoryButton setTitle:@"Recent History" forState:UIControlStateNormal];
    [recentHistoryButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}



@end
