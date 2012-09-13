//
//  SignInViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "CreateAccountViewController.h"

@class SignInViewController;

@protocol SignInDelegate <NSObject>

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn;

@end

@interface SignInViewController : UIViewController <CreateAccountDelegate, UITextFieldDelegate>

@property (nonatomic, strong) id<SignInDelegate> delegate;

@end
