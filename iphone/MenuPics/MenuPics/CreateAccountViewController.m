//
//  CreateAccountViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "SignInViewController.h"
#import "UIColor+ExtendedColor.h"
#import "AFNetworking.h"
#import "User.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

@synthesize delegate = _delegate;

@synthesize navBar = _navBar;
@synthesize cancelButton = _cancelButton;
@synthesize scrollView = _scrollView;
@synthesize createAccountButton = _createAccountButton;
@synthesize emailInputText = _emailInputText;
@synthesize usernameInputText = _usernameInputText;
@synthesize passwordInputText = _passwordInputText;
@synthesize verifyPasswordInputText = _verifyPasswordInputText;
@synthesize errorLabel = _errorLabel;

@synthesize activityIndicator = _activityIndicator;
@synthesize activeField = _activeField;

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

    [_navBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    [_cancelButton setTintColor:[UIColor navBarButtonColor]];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setFrame:CGRectMake(150, 365, 20, 20)];
    [self setActivityIndicator:activityIndicator];
    [self.view addSubview:activityIndicator];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancel:(id)sender
{
    [_emailInputText resignFirstResponder];
    [_usernameInputText resignFirstResponder];
    [_passwordInputText resignFirstResponder];
    [_verifyPasswordInputText resignFirstResponder];
    [_delegate createAccountViewController:self didCreate:NO];
}

- (IBAction)createAccount:(id)sender
{
    if (self.emailInputText.text.length == 0 || self.passwordInputText.text.length == 0 || self.verifyPasswordInputText.text.length == 0) {
        [self displayError:@"Email and password cannot be blank."];
    } else if (![self.passwordInputText.text isEqualToString:self.verifyPasswordInputText.text]) {
        [self displayError:@"Passwords do not match."];
        [[self passwordInputText] setText:nil];
        [[self verifyPasswordInputText] setText:nil];
    } else {
        [[self createAccountButton] setEnabled:NO];
        [[self emailInputText] setEnabled:NO];
        [[self passwordInputText] setEnabled:NO];
        [[self verifyPasswordInputText] setEnabled:NO];
        [[self errorLabel] setHidden:YES];
        [[self activityIndicator] startAnimating];
        
        NSString *requestString = [NSString stringWithFormat:@"user[email]=%@&user[username]=%@&user[password]=%@&user[password_confirmation]=%@", 
                                                                                                                self.emailInputText.text, 
                                                                                                                self.usernameInputText.text,
                                                                                                                self.passwordInputText.text,
                                                                                                                self.verifyPasswordInputText.text]; 
        NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
        
        NSURL *url = [NSURL URLWithString:@"https://infoit.heroku.com/users.json"];
        //NSURL *url = [NSURL URLWithString:@"http://192.168.0.103/users.json"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody:requestData];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
                                             {
                                                 NSLog(@"Operation success.");
                                                 if (!JSON) {
                                                     NSLog(@"Success, but no JSON.");
                                                 }
                                                 
                                                 NSLog(@"User Login: %@", JSON);
                                                 [[self activityIndicator] startAnimating];
                                                 
                                                 NSString *accessToken = [[JSON valueForKey:@"user"] valueForKeyPath:@"access_token"];
                                                 NSString *email = [[JSON valueForKey:@"user"] valueForKeyPath:@"email"];
                                                 NSString *username = [[JSON valueForKey:@"user"] valueForKeyPath:@"username"];
                                                 NSNumber *userId = [[JSON valueForKey:@"user"] valueForKey:@"user_id"];
                                                 
                                                 [User signOutUser];
                                                 [User signInUser:email withAccessToken:accessToken withUsername:username withUserId:userId];
                                                 [_delegate createAccountViewController:self didCreate:YES];
                                             } 
                                                                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                             {
                                                 NSLog(@"Operation failure.");
                                                 [[self activityIndicator] stopAnimating];
                                                 if (JSON) {
                                                     NSLog(@"JSON: %@", JSON);
                                                     //[self displayError:[JSON valueForKeyPath:@"error"]];
                                                 } else {
                                                     [self displayError:@"Unable to connect.  Try again later."];  
                                                 }
                                                 
                                                 [[self emailInputText] setEnabled:YES];
                                                 [[self passwordInputText] setEnabled:YES];
                                                 [[self verifyPasswordInputText] setEnabled:YES];
                                                 [[self createAccountButton] setEnabled:YES];
                                             }];
        [operation start];
    }
    
    
    
}

- (void)displayError:(NSString *)error
{
    [[self activityIndicator] setHidden:YES];
    [[self errorLabel] setText:error];
    [[self errorLabel] setHidden:NO];
}

#pragma mark UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == [self emailInputText]) {
        [textField resignFirstResponder];
        [[self usernameInputText] becomeFirstResponder];
    } else if (textField == [self usernameInputText]) {
        [textField resignFirstResponder];
        [[self passwordInputText] becomeFirstResponder];
    } else if (textField == [self passwordInputText]) {
        [textField resignFirstResponder];
        [[self verifyPasswordInputText] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

@end
