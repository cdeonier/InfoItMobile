//
//  NavigationMenuViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 4/3/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "NavigationMenuViewController.h"

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
        [NavigationMenuViewController imageWithImage:bookmarkImage scaledToSize:CGSizeMake(25, 25)];
    [bookmarkButton setImage:bookmarkIcon forState:UIControlStateNormal];
    
    [bookmarkButton setTitle:@"My Bookmarks" forState:UIControlStateNormal];
    [bookmarkButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}

- (void) initializeRecentHistoryButton
{
    UIImage *recentHistoryImage = [UIImage imageNamed:@"history_icon.png"];
    UIImage *recentHistoryIcon = 
        [NavigationMenuViewController imageWithImage:recentHistoryImage scaledToSize:CGSizeMake(25, 25)];
    [recentHistoryButton setImage:recentHistoryIcon forState:UIControlStateNormal];
    
    [recentHistoryButton setTitle:@"Recent History" forState:UIControlStateNormal];
    [recentHistoryButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

@end
