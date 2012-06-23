//
//  MenuItemViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/22/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "MenuItemViewController.h"
#import "RootMenuViewController.h"
#import "ImageUtil.h"
#import "UIColor+ExtendedColor.h"
#import "MenuItem.h"
#import "AFNetworking.h"
#import "User.h"

@interface MenuItemViewController ()

@end

@implementation MenuItemViewController

@synthesize menuButtonLabel = _menuButtonLabel;
@synthesize likeButtonLabel = _likeButtonLabel;
@synthesize restaurantButtonLabel = _restaurantButtonLabel;
@synthesize likeButton = _likeButton;
@synthesize menuItem = _menuItem;

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
    
    [self setTitle:@"Menu Item"];
    
    UILabel *name = (UILabel *)[self.view viewWithTag:3];
    [name setText:[self.menuItem name]];
    
    [self initializeDescriptionView];
    [self initializeProfileImage];
    
    if ([self.menuItem isLiked]) {
        [self.likeButton setSelected:YES];
    }
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

- (void) initializeDescriptionView
{
    UILabel *description = (UILabel *)[self.view viewWithTag:4];
    [description setText:[self.menuItem description]];
    UIFont *descriptionFont = [UIFont fontWithName:@"GillSans" size:13.0];
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize expectedLabelSize = [[self.menuItem description] sizeWithFont:descriptionFont
                                                       constrainedToSize:maximumLabelSize
                                                           lineBreakMode:UILineBreakModeWordWrap]; 
    CGRect newFrame = description.frame;
    newFrame.size.height = expectedLabelSize.height;
    description.frame = newFrame;
}

- (void)initializeProfileImage
{
    [ImageUtil initializeProfileImage:self.view withUrl:[self.menuItem profilePhotoUrl]];
}

#pragma mark Button Actions

- (IBAction)pressMenuButton:(id)sender
{
    [self.menuButtonLabel setTextColor:[UIColor normalButtonColor]];
    
    RootMenuViewController *viewController = [[RootMenuViewController alloc] initWithNibName:@"RootMenuViewController" bundle:nil];
    viewController.restaurantIdentifier = [self.menuItem restaurantId];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)pressLikeButton:(id)sender
{
    User *currentUser = [User currentUser];
    if (!currentUser) {
        //Try to sign in user through sign in flow
        
        currentUser = [User currentUser];
    } 
    
    if (currentUser) {
        if ([sender isSelected]) {
            [sender setSelected:NO];
            [self.menuItem setIsLiked:NO];
            [self.menuItem setLikeCount:[NSNumber numberWithInt:([self.menuItem.likeCount intValue] - 1)]];
            
            NSString *requestString = [NSString stringWithFormat:@"entity_id=%@&access_token=%@", [[self.menuItem entityId] stringValue], [currentUser accessToken]]; 
            NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
            
            NSURL *url = [NSURL URLWithString:@"https://infoit.heroku.com/services/unlike"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
            [request setHTTPMethod:@"DELETE"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            [request setHTTPBody:requestData];
            
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
                                                 {
                                                     NSLog(@"Successful unlike.");
                                                 } 
                                                                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                                 {
                                                     NSLog(@"Failure unliking");
                                                     NSLog(@"JSON: %@", JSON);
                                                 }];
            [operation start];
        } else {
            [sender setSelected:YES];
            [self.menuItem setIsLiked:YES];
            [self.menuItem setLikeCount:[NSNumber numberWithInt:([self.menuItem.likeCount intValue] + 1)]];
            
            NSString *requestString = [NSString stringWithFormat:@"entity_id=%@&access_token=%@", [[self.menuItem entityId] stringValue], [currentUser accessToken]]; 
            NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
            
            NSURL *url = [NSURL URLWithString:@"https://infoit.heroku.com/services/like"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            [request setHTTPBody:requestData];
            
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
                                                 {
                                                     NSLog(@"Successful liking.");
                                                 } 
                                                                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                                 {
                                                     NSLog(@"Failure liking");
                                                     NSLog(@"JSON: %@", JSON);
                                                 }];
            [operation start];
        }
    }
}

- (IBAction)pressRestaurantButton:(id)sender
{
    [self.restaurantButtonLabel setTextColor:[UIColor normalButtonColor]];
    
    RootMenuViewController *viewController = [[RootMenuViewController alloc] initWithNibName:@"RootMenuViewController" bundle:nil];
    viewController.restaurantIdentifier = [self.menuItem restaurantId];
    viewController.requestedTab = @"Restaurant";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
