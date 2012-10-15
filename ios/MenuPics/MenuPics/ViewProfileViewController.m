//
//  ViewProfileViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "ViewProfileViewController.h"

#import "MenuPicsAPIClient.h"
#import "MenuPicsDBClient.h"
#import "Photo.h"
#import "PhotosViewController.h"
#import "ProfileViewController.h"
#import "SavedPhoto.h"
#import "User.h"

@interface ViewProfileViewController ()

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) PhotosViewController *photoViewController;
@property (nonatomic, strong) ProfileViewController *profileViewController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *accountButton;

- (IBAction)displayActionSheet:(id)sender;

@end

@implementation ViewProfileViewController

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
    
    [self setTitle:@"Profile"];
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:@"Sign Out"
                                      otherButtonTitles:@"Update Account", nil];
    
    self.profileViewController = [[self viewControllers] objectAtIndex:0];
    self.photoViewController = [[self viewControllers] objectAtIndex:1];
    
    self.navigationItem.rightBarButtonItem = self.accountButton;
    
    self.delegate = self;
    
    [self fetchProfile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Web Service

- (void)fetchProfile
{
    User *currentUser = [User currentUser];
    
    SuccessBlock didFetchUserProfileBlock;
    didFetchUserProfileBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSMutableArray *userPhotos = [Photo userPhotosFromJson:JSON];
        //[SavedPhoto syncPhotos:userPhotos viewController:self];
    };
    
    [MenuPicsAPIClient fetchProfile:currentUser.userId success:didFetchUserProfileBlock];
}

#pragma mark UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [User signOutUser];
        [self.navigationController popViewControllerAnimated:YES];
    } else if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"UpdateAccountSegue" sender:self];
    }
}

- (IBAction)displayActionSheet:(id)sender
{
    [self.actionSheet showFromTabBar:self.tabBar];
}

#pragma mark UITabBarDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController == self.profileViewController) {
        self.navigationItem.rightBarButtonItem = self.accountButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark Helper Functions

- (void)addNewPhoto:(SavedPhoto *)photo
{
    
}

@end
