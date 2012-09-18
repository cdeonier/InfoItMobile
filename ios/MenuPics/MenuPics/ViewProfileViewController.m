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
#import "SavedPhoto.h"
#import "User.h"

@interface ViewProfileViewController ()

@property (nonatomic, strong) UIActionSheet *actionSheet;

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
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:@"Sign Out"
                                      otherButtonTitles:@"Update Account", nil];
    
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
        NSMutableArray *userPhotos = [Photo userPhotosFromJson:JSON];
        [SavedPhoto syncPhotos:userPhotos viewController:self];
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

#pragma mark Helper Functions

- (void)addNewPhoto:(SavedPhoto *)photo
{
    
}

@end
