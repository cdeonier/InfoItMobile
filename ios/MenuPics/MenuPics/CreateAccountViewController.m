//
//  CreateAccountViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "CreateAccountViewController.h"

#import "MenuPicsAPIClient.h"
#import "User.h"

@interface CreateAccountViewController ()

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UITextField *verifyPasswordTextField;
@property (nonatomic, strong) IBOutlet UIButton *createButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) UITextField *activeField;

- (IBAction)createAccount:(id)sender;

@end

@implementation CreateAccountViewController

@synthesize delegate = _delegate;

@synthesize emailTextField = _emailTextField;
@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize verifyPasswordTextField = _verifyPasswordTextField;
@synthesize createButton = _createButton;
@synthesize activityIndicator = _activityIndicator;
@synthesize errorLabel = _errorLabel;
@synthesize scrollView = _scrollView;

@synthesize activeField = _activeField;

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
	
    [_activityIndicator setHidden:YES];
    
    [self registerForKeyboardNotifications];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        //Back Button pressed
        [_delegate createAccountController:self didCreate:NO];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)createAccount:(id)sender
{
    [self disableViewInteraction];
    [_errorLabel setHidden:YES];
    
    void (^didCreateBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didCreateBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *accessToken = [[JSON valueForKey:@"user"] valueForKeyPath:@"access_token"];
        NSString *email = [[JSON valueForKey:@"user"] valueForKeyPath:@"email"];
        NSString *username = [[JSON valueForKey:@"user"] valueForKeyPath:@"username"];
        NSNumber *userId = [[JSON valueForKey:@"user"] valueForKey:@"user_id"];
        NSString *loginType = @"NATIVE";
        
        [User signOutUser];
        [User signInUser:email accessToken:accessToken username:username userId:userId loginType:loginType];
        
        [self.navigationController popViewControllerAnimated:NO];
        [_delegate createAccountController:self didCreate:YES];
    };
    
    void (^failureCreateBlock)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id);
    failureCreateBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self enableViewInteraction];
        
        if (JSON) {
            [self displayError:[[JSON valueForKey:@"user"] valueForKey:@"message"]];
        } else {
            [self displayError:@"Unable to connect.  Try again later."];
        }
    };
    
    NSString *email = _emailTextField.text;
    NSString *password = _passwordTextField.text;
    NSString *verifyPassword = _verifyPasswordTextField.text;
    NSString *username = _usernameTextField.text;
    
    if (email.length == 0 || username.length == 0 || password.length == 0 || verifyPassword == 0) {
        [self displayError:@"Email, username, and password cannot be blank."];
        [self enableViewInteraction];
    } else if (![password isEqualToString:verifyPassword]) {
        [self displayError:@"Passwords do not match."];
        [self enableViewInteraction];
    } else {
        [MenuPicsAPIClient createAccount:username email:email password:password success:didCreateBlock failure:failureCreateBlock];
    }
}

- (void)displayError:(NSString *)error
{
    [_errorLabel setHidden:NO];
    [_errorLabel setText:error];
}

//Called to disable buttons and show activity indicator
- (void)disableViewInteraction
{
    [_activityIndicator setHidden:NO];
    [_activityIndicator startAnimating];
    
    [_createButton setEnabled:NO];
}

- (void)enableViewInteraction
{
    [_activityIndicator setHidden:YES];
    [_activityIndicator stopAnimating];
    
    [_createButton setEnabled:YES];
}

#pragma mark UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _emailTextField) {
        [textField resignFirstResponder];
        [_usernameTextField becomeFirstResponder];
    } else if (textField == _usernameTextField) {
        [textField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [textField resignFirstResponder];
        [_verifyPasswordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

#pragma mark TextField display w/keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = _scrollView.frame;
    aRect.origin.y = 0;
    aRect.size.height -= kbSize.height;
    CGPoint origin = _activeField.frame.origin;
    origin.y -= _scrollView.contentOffset.y;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _activeField.frame.origin.y-(aRect.size.height) + _activeField.frame.size.height + 7);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
}


@end
