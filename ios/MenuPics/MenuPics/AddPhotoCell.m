//
//  AddPhotoCell.m
//  MenuPics
//
//  Created by Christian Deonier on 9/17/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "AddPhotoCell.h"

#import "User.h"

@implementation AddPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (IBAction)addPhoto:(id)sender
{
    if ([User currentUser]) {
        [self.viewController performSegueWithIdentifier:@"MenuItemTakePhotoSegue" sender:self];
    } else {
        [self.viewController performSegueWithIdentifier:@"MenuItemSignInSegue" sender:self];
    }
}

#pragma mark SignInDelegate

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn
{
    if (didSignIn) {
        [signInViewController.navigationController popViewControllerAnimated:YES];
        [self.viewController performSegueWithIdentifier:@"MenuItemTakePhotoSegue" sender:self];
    }
}

@end
