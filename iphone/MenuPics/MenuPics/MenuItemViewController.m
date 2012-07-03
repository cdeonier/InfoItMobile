//
//  MenuItemViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/22/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "AppDelegate.h"
#import "MenuItemViewController.h"
#import "RootMenuViewController.h"
#import "ImageUtil.h"
#import "UIColor+ExtendedColor.h"
#import "MenuItem.h"
#import "AFNetworking.h"
#import "User.h"
#import "Photo.h"
#import "SavedPhoto.h"
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"

@interface MenuItemViewController ()

@end

@implementation MenuItemViewController

@synthesize contentContainer = _contentContainer;
@synthesize separator = _separator;
@synthesize likeButton = _likeButton;
@synthesize menuItemName = _menuItemName;
@synthesize description = _description;
@synthesize profileImage = _profileImage;
@synthesize menuItem = _menuItem;
@synthesize buttonAction = _buttonAction;
@synthesize menuItemPhotos = _menuItemPhotos;
@synthesize gridView = _gridView;

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
    
    _menuItemPhotos = [[NSMutableArray alloc] initWithCapacity:[_menuItem.photoCount intValue]];
    [self getPhotos];

    GMGridView *gridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 240, 320, 95)];
    gridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    gridView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    gridView.centerGrid = NO;
    gridView.dataSource = self;
    gridView.actionDelegate = self;
    self.gridView = gridView;
    [_gridView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_gridView];
    
    [self setScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Webservice

- (void)getPhotos
{
    NSString *urlString = [NSString stringWithFormat:@"https://infoit.heroku.com/services/%@", [[self.menuItem entityId] stringValue]];
    
    User *currentUser = [User currentUser];
    if (currentUser) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", [currentUser accessToken]]];
    }
    
    NSLog(@"URL String: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)                                
    {
        if (JSON) {
            NSLog(@"JSON: %@", JSON);
            for (id photoEntry in [[JSON valueForKey:@"entity"] valueForKey:@"photos"]) {  
                NSLog(@"Photo Entry: %@", photoEntry);
                Photo *menuItemPhoto = [[Photo alloc] init];
                [menuItemPhoto setPhotoId:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_id"]];
                [menuItemPhoto setPhotoUrl:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_original"]];
                [menuItemPhoto setSmallThumbnailUrl:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_thumbnail_100x100"]];
                [menuItemPhoto setThumbnailUrl:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_thumbnail_200x200"]];
                [menuItemPhoto setAuthorId:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_author_id"]];
                [menuItemPhoto setAuthor:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_author"]];
                [menuItemPhoto setPoints:[[photoEntry valueForKey:@"photo"] valueForKey:@"photo_points"]];
                
                if ([User currentUser]) {
                    [menuItemPhoto setVotedForPhoto:[[[[photoEntry valueForKey:@"photo"] valueForKey:@"logged_in_user"] valueForKey:@"photo_voted"] boolValue]];
                }
                
                [self.menuItemPhotos addObject:menuItemPhoto];
            }
        }
        [_gridView reloadData];
    } 
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"Menu Failure");
    }];
    [operation start];

}

- (void)initializeDescriptionView
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

- (void)setScrollView
{
    int contentSize = 0;
    contentSize += _contentContainer.frame.origin.y;
    contentSize += _description.frame.origin.y;
    contentSize += _description.frame.size.height;
    contentSize += 5; //padding
    [(UIScrollView *)self.view setContentSize:CGSizeMake(320, contentSize)];
    [(UIScrollView *)self.view setBounces:NO];
}

- (void)initializeProfileImage
{
    if (![[_menuItem profilePhotoUrl] isEqual:[NSNull null]] && [[_menuItem profilePhotoUrl] length] > 0) {
        UIImageView *placeholderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_loading"]];
        [placeholderImage setFrame:CGRectMake(0, 0, 320, 240)];
        [self.view addSubview:placeholderImage];
        
        UIImageView *loadingAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [loadingAnimation setAnimationImages:[ImageUtil getSweepImageArray]];
        [loadingAnimation setAnimationDuration:4.0f];
        [loadingAnimation setAnimationRepeatCount:INFINITY];
        [loadingAnimation startAnimating];
        [loadingAnimation setCenter:CGPointMake(160, 120)];
        [self.view addSubview:loadingAnimation];
                    
        [_profileImage setImageWithURL:[NSURL URLWithString:[_menuItem profilePhotoUrl]] success:^(UIImage *image) {
            [placeholderImage removeFromSuperview];
            [loadingAnimation removeFromSuperview];
        } failure:^(NSError *error) {
            [placeholderImage removeFromSuperview];
            [loadingAnimation removeFromSuperview];
        }]; 
    }
}

#pragma mark SignInDelegate

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn
{
    if (didSignIn) {
        if (_buttonAction == LikeButtonAction) {
            [self likeMenuItem];
        } else if (_buttonAction == PhotoButtonAction) {
            [self takePhoto];
        }
    }
    
    if (_buttonAction == PhotoButtonAction) {
        [self dismissModalViewControllerAnimated:NO];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
    
    [self setButtonAction:NoAction];
    
}

#pragma mark TakePhotoDelegate

- (void)takePhotoViewController:(TakePhotoViewController *)takePhotoViewController didSavePhotos:(BOOL)didSavePhotos
{
    for (SavedPhoto *savedPhoto in takePhotoViewController.savedPhotos) {
        Photo *photo = [[Photo alloc] init];
        [photo setFileName:[savedPhoto fileName]];
        [photo setThumbnail:[savedPhoto thumbnail]];
        [photo setFileLocation:[savedPhoto fileLocation]];
        
        [self.menuItemPhotos addObject:photo];
    }
    
    [_gridView reloadData];
}

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_menuItemPhotos count] + 1;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(75, 75);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[GMGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        UIView *placeHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [placeHolderView setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [imageView.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [imageView.layer setBorderWidth:1.0];
        [imageView setTag:1];
        [placeHolderView addSubview:imageView];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator setFrame:CGRectMake(28, 28, 19, 19)];
        [activityIndicator setTag:2];
        [placeHolderView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        [cell setContentView:placeHolderView];
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:2];
    
    if (index == 0) {
        [imageView setImage:[UIImage imageNamed:@"add_photo"]];
        [activityIndicator stopAnimating];
    } else {
        Photo *menuItemPhoto = [_menuItemPhotos objectAtIndex:(index - 1)];
        
            if ([menuItemPhoto thumbnail]) {
                [imageView setImage:[menuItemPhoto thumbnail]];
                [activityIndicator stopAnimating];
            } else if ([menuItemPhoto thumbnailUrl]) {
                [imageView setImageWithURL:[NSURL URLWithString:[menuItemPhoto thumbnailUrl]] placeholderImage:nil
                                   success:^(UIImage *image) { 
                                       [activityIndicator stopAnimating];
                                   }
                                   failure:^(NSError *error) {
                                       NSLog(@"%@", [error description]);
                                   }];
            }
        
    }
    
    return cell;
}

#pragma mark GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if (position == 0) {
        [self takePhoto];
    } else {
        [_separator setHidden:YES];
        Photo *photo = [self.menuItemPhotos objectAtIndex:(position - 1)];
        
        if ([photo fileLocation]) {
            NSFileManager *filemgr =[NSFileManager defaultManager];
            if (![filemgr fileExistsAtPath:[photo fileLocation]]) {
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                NSManagedObjectContext *context = [delegate managedObjectContext];
                
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
                [request setEntity:entity];
                
                NSString *predicateString = [NSString stringWithFormat:@"fileName == '%@'", [photo fileName]];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
                [request setPredicate:predicate];
                
                NSError *error = nil;
                NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
                SavedPhoto *savedPhoto = [mutableFetchResults objectAtIndex:0];
                
                [photo setPhotoUrl:[savedPhoto fileUrl]];
                [photo setThumbnailUrl:[savedPhoto thumbnailUrl]];
                [photo setFileLocation:nil];
                [photo setPhotoId:[savedPhoto photoId]];
            } else {
                NSData *imageData = [NSData dataWithContentsOfFile:[photo fileLocation]];
                UIImage *image = [UIImage imageWithData:imageData];
                [_profileImage setImage:image];
            }
        } else {
            UIView *separatorReference = _separator;
            [_profileImage setImageWithURL:[NSURL URLWithString:[photo photoUrl]] 
            success:^(UIImage *image) {
                [separatorReference setHidden:NO];
            } 
            failure:^(NSError *error) {
                NSLog(@"%@", [error description]);
            }  ];
        }
    }
}


#pragma mark Button Actions

- (IBAction)pressMenuButton:(id)sender
{
    RootMenuViewController *viewController = [[RootMenuViewController alloc] initWithNibName:@"RootMenuViewController" bundle:nil];
    viewController.restaurantIdentifier = [self.menuItem restaurantId];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)pressLikeButton:(id)sender
{
    if ([User currentUser]) {
        if ([_likeButton isSelected]) {
            [self unlikeMenuItem];
        } else {
            [self likeMenuItem];
        }
    } else {
        [self setButtonAction:LikeButtonAction];
        SignInViewController *viewController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
        [viewController setDelegate:self];
        [self presentModalViewController:viewController animated:YES];
    }
}

- (IBAction)pressRestaurantButton:(id)sender
{
    RootMenuViewController *viewController = [[RootMenuViewController alloc] initWithNibName:@"RootMenuViewController" bundle:nil];
    viewController.restaurantIdentifier = [self.menuItem restaurantId];
    viewController.requestedTab = @"Restaurant";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)takePhoto
{
    if ([User currentUser]) {
    TakePhotoViewController *viewController = [[TakePhotoViewController alloc] initWithNibName:@"TakePhotoViewPortrait" bundle:nil];
    [viewController setDelegate:self];
    [viewController setMenuItemId:[_menuItem entityId]];
    [viewController setRestaurantId:[_menuItem restaurantId]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu Item" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor navBarButtonColor]];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:viewController animated:YES];
    } else   {
        [self setButtonAction:PhotoButtonAction];
        SignInViewController *viewController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
        [viewController setDelegate:self];
        [self presentModalViewController:viewController animated:YES];
    }
}

#pragma mark Server Actions

- (void)likeMenuItem
{
    [_likeButton setSelected:YES];
    [self.menuItem setIsLiked:YES];
    
    NSString *requestString = [NSString stringWithFormat:@"entity_id=%@&access_token=%@", [[self.menuItem entityId] stringValue], [[User currentUser] accessToken]]; 
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
        [self.menuItem setLikeCount:[NSNumber numberWithInt:([self.menuItem.likeCount intValue] + 1)]];
    } 
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"Failure liking");
        NSLog(@"JSON: %@", JSON);
    }];
    [operation start];
}
             
- (void)unlikeMenuItem
{
    [_likeButton setSelected:NO];
    [self.menuItem setIsLiked:NO];
    
    NSString *requestString = [NSString stringWithFormat:@"entity_id=%@&access_token=%@", [[self.menuItem entityId] stringValue], [[User currentUser] accessToken]]; 
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
        [self.menuItem setLikeCount:[NSNumber numberWithInt:([self.menuItem.likeCount intValue] - 1)]];
    } 
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"Failure unliking");
        NSLog(@"JSON: %@", JSON);
    }];
    [operation start];

}



@end
