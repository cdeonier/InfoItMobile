//
//  CreateAccountViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateAccountDelegate;

@interface CreateAccountViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) id<CreateAccountDelegate> delegate;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *createAccountButton;
@property (nonatomic, strong) IBOutlet UITextField *emailInputText;
@property (nonatomic, strong) IBOutlet UITextField *passwordInputText;
@property (nonatomic, strong) IBOutlet UITextField *verifyPasswordInputText;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (IBAction)cancel:(id)sender;
- (IBAction)createAccount:(id)sender;

@end
