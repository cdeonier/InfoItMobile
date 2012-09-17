//
//  ViewProfileViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "ViewProfileViewController.h"

#import "User.h"

@interface ViewProfileViewController ()

@property (nonatomic, strong) UIActionSheet *actionSheet;

- (IBAction)displayActionSheet:(id)sender;

@end

@implementation ViewProfileViewController

@synthesize actionSheet = _actionSheet;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

@end
