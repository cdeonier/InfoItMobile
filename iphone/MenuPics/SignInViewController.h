//
//  SignInViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 6/26/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateAccountViewController.h"

@class SignInViewController;

@protocol SignInDelegate <NSObject>

- (void)signInViewController:(SignInViewController *)signInViewController didSignIn:(BOOL)didSignIn;

@end

@interface SignInViewController : UIViewController <CreateAccountDelegate, UITextFieldDelegate>

@property (nonatomic, strong) id<SignInDelegate> delegate;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;

@property (nonatomic, strong) IBOutlet UIView *facebookContainerView;
@property (nonatomic, strong) IBOutlet UITextField *emailInputText;
@property (nonatomic, strong) IBOutlet UITextField *passwordInputText;
@property (nonatomic, strong) IBOutlet UIButton *signInButton;
@property (nonatomic, strong) IBOutlet UIButton *createAccountButton;
@property (nonatomic, strong) IBOutlet UIButton *facebookLoginButton;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (IBAction)createAccount:(id)sender;
- (IBAction)signIn:(id)sender;
- (IBAction)signInWithFacebook:(id)sender;

@end
