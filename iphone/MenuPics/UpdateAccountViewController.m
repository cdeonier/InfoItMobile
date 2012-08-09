//
//  UpdateAccountViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 7/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "UpdateAccountViewController.h"
#import "UIColor+ExtendedColor.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "User.h"

@interface UpdateAccountViewController ()

@end

@implementation UpdateAccountViewController

@synthesize delegate = _delegate;

@synthesize navBar = _navBar;
@synthesize cancelButton = _cancelButton;
@synthesize scrollView = _scrollView;
@synthesize updateAccountButton = _updateAccountButton;
@synthesize emailInputText = _emailInputText;
@synthesize usernameInputText = _usernameInputText;
@synthesize currentPasswordInputText = _currentPasswordInputText;
@synthesize passwordInputText = _passwordInputText;
@synthesize errorLabel = _errorLabel;
@synthesize facebookLabel = _facebookLabel;
@synthesize facebookSwitch = _facebookSwitch;

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
    [activityIndicator setFrame:CGRectMake(150, 415, 20, 20)];
    [self setActivityIndicator:activityIndicator];
    [self.view addSubview:activityIndicator];
    
    [self registerForKeyboardNotifications];
    
    if (![[[User currentUser] loginType] isEqualToString:@"NATIVE"]) {
        [_facebookSwitch setOn:YES];
    }
    
    if ([[[User currentUser] loginType] isEqualToString:@"FACEBOOK"]) {
        CGRect frame = _currentPasswordInputText.frame;
        [_currentPasswordInputText setHidden:YES];
        [_passwordInputText setFrame:frame];
        [_emailInputText setText:[[User currentUser] email]];
        [_facebookSwitch setHidden:YES];
        [_facebookLabel setHidden:YES];
        
        frame = _updateAccountButton.frame;
        frame.origin.y -= 120;
        [_updateAccountButton setFrame:frame];
        
        frame = _errorLabel.frame;
        frame.origin.y -= 120;
        [_errorLabel setFrame:frame];
        
        frame = _activityIndicator.frame;
        frame.origin.y -= 110;
        [_activityIndicator setFrame:frame];
    } else {
        [_emailInputText setText:[[User currentUser] email]];
        [_usernameInputText setText:[[User currentUser] username]];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    [_delegate updateAccountViewController:self didUpdateAccount:NO];
}

- (IBAction)updateAccount:(id)sender
{
    if (![[User currentUser] isFacebookOnly] && _currentPasswordInputText.text.length == 0) {
        [self displayError:@"Enter current password to update account."];
    } else if (_usernameInputText.text.length == 0) {
        [self displayError:@"Enter a new username."];
    } else {
        [_updateAccountButton setEnabled:NO];
        [_emailInputText setEnabled:NO];
        [_currentPasswordInputText setEnabled:NO];
        [_passwordInputText setEnabled:NO];
        [_errorLabel setHidden:YES];
        [_activityIndicator startAnimating];
        
        NSString *requestString = [[NSString alloc] init];
        if ([[User currentUser] isFacebookOnly]) {
            requestString = [NSString stringWithFormat:@"access_token=%@", [[User currentUser] accessToken]];
        } else {
            requestString = [NSString stringWithFormat:@"access_token=%@&current_password=%@", [[User currentUser] accessToken], _currentPasswordInputText.text];
        }
        
        if (_emailInputText.text.length > 0) {
            requestString = [requestString stringByAppendingString:[NSString stringWithFormat:@"&user[email]=%@", _emailInputText.text]];
        }
        
        if (_usernameInputText.text.length > 0) {
            requestString = [requestString stringByAppendingString:[NSString stringWithFormat:@"&user[username]=%@", _usernameInputText.text]];
        }
        
        if (_passwordInputText.text.length > 0) {
            requestString = 
                [requestString stringByAppendingString:[NSString stringWithFormat:@"&user[password]=%@&user[password_confirmation]=%@", _passwordInputText.text, _passwordInputText.text]];
        }
        
        NSLog(@"Request String: %@",requestString);
        NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
        
        NSURL *url = [[NSURL alloc] init];
        if ([[User currentUser] isFacebookOnly]) {
            url = [NSURL URLWithString:@"https://infoit-app.herokuapp.com/services/facebook/update_user"];
        } else {
            url = [NSURL URLWithString:@"https://infoit-app.herokuapp.com/services/update_user"];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
        [request setHTTPMethod:@"PUT"];
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
            
            if ([[User currentUser] isFacebookOnly]) {
                NSString *accessToken = [[User currentUser] accessToken];
                NSString *email = [JSON valueForKeyPath:@"email"];
                NSString *username = [JSON valueForKeyPath:@"username"];
                NSNumber *userId = [JSON valueForKey:@"user_id"];
                NSString *loginType = [JSON valueForKey:@"login_type"];
                
                [User signOutUser];
                [User signInUser:email withAccessToken:accessToken withUsername:username withUserId:userId withLoginType:loginType];
            } else {
                NSString *accessToken = [[User currentUser] accessToken];
                NSString *email = [[JSON valueForKey:@"user"] valueForKeyPath:@"email"];
                NSString *username = [[JSON valueForKey:@"user"] valueForKeyPath:@"username"];
                NSNumber *userId = [[JSON valueForKey:@"user"] valueForKey:@"user_id"];
                NSString *loginType = [[JSON valueForKey:@"user"] valueForKey:@"login_type"];
                
                [User signOutUser];
                [User signInUser:email withAccessToken:accessToken withUsername:username withUserId:userId withLoginType:loginType];
            }
            
            [_delegate updateAccountViewController:self didUpdateAccount:YES];
        } 
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            NSLog(@"Operation failure.");
            [[self activityIndicator] stopAnimating];
            if (JSON) {
                NSLog(@"JSON: %@", JSON);
                [self displayError:[[JSON valueForKey:@"user"] valueForKey:@"message"]];
            } else {
                [self displayError:@"Unable to connect.  Try again later."];  
            }

            [_emailInputText setEnabled:YES];
            [_usernameInputText setEnabled:YES];
            [_currentPasswordInputText setEnabled:YES];
            [_passwordInputText setEnabled:YES];
            [_updateAccountButton setEnabled:YES];
        }];
        [operation start];
    }
}

- (IBAction)facebookSwitch:(UISwitch *)facebookSwitch
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (facebookSwitch.on) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(linkFacebook)
                                                     name:MenuPicsFacebookNotification
                                                   object:nil];
        
        [delegate openFacebookSession];
    } else {
        [delegate closeFacebookSession];
        
        [self unlinkFacebook];
    }
}

- (void)displayError:(NSString *)error
{
    NSLog(@"Error: %@", error);
    [[self activityIndicator] setHidden:YES];
    [[self errorLabel] setTextColor:[UIColor redColor]];
    [[self errorLabel] setText:error];
    [[self errorLabel] setHidden:NO];
}

- (void)displayStatus:(NSString *)status
{
    NSLog(@"Status: %@", status);
    [[self activityIndicator] setHidden:YES];
    [[self errorLabel] setTextColor:[UIColor navBarButtonColor]];
    [[self errorLabel] setText:status];
    [[self errorLabel] setHidden:NO];
}

- (void)linkFacebook
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MenuPicsFacebookNotification object:nil];
    
    NSString *requestString = [NSString stringWithFormat:@"access_token=%@&fb_access_token=%@", [[User currentUser] accessToken], [[FBSession activeSession] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    NSURL *url = [NSURL URLWithString:@"https://infoit-app.herokuapp.com/services/facebook/link"];
    
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
                                             
                                             NSString *accessToken = [JSON valueForKeyPath:@"access_token"];
                                             NSString *email = [JSON valueForKeyPath:@"email"];
                                             NSString *username = [JSON valueForKeyPath:@"username"];
                                             NSNumber *userId = [JSON valueForKey:@"user_id"];
                                             NSString *loginType = [JSON valueForKey:@"login_type"];
                                             
                                             [User signOutUser];
                                             [User signInUser:email withAccessToken:accessToken withUsername:username withUserId:userId withLoginType:loginType];
                                             [self displayStatus:[JSON valueForKey:@"message"]];
                                             [_cancelButton setTitle:@"Done"];
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             NSLog(@"Operation failure.");
                                             [[self activityIndicator] stopAnimating];
                                             if (JSON) {
                                                 NSLog(@"JSON: %@", JSON);
                                                 [self displayError:[JSON valueForKey:@"message"]];
                                             } else {
                                                 [self displayError:@"Unable to connect.  Try again later."];
                                             }
                                         }];
    [operation start];
}

- (void)unlinkFacebook
{
    NSString *requestString = [NSString stringWithFormat:@"access_token=%@", [[User currentUser] accessToken]];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    NSURL *url = [NSURL URLWithString:@"https://infoit-app.herokuapp.com/services/facebook/disconnect"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"DELETE"];
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
                                             
                                             NSString *accessToken = [JSON valueForKeyPath:@"access_token"];
                                             NSString *email = [JSON valueForKeyPath:@"email"];
                                             NSString *username = [JSON valueForKeyPath:@"username"];
                                             NSNumber *userId = [JSON valueForKey:@"user_id"];
                                             NSString *loginType = [JSON valueForKey:@"login_type"];
                                             
                                             [User signOutUser];
                                             [User signInUser:email withAccessToken:accessToken withUsername:username withUserId:userId withLoginType:loginType];
                                             [self displayStatus:[JSON valueForKey:@"message"]];
                                             [_cancelButton setTitle:@"Done"];
                                         } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             NSLog(@"Operation failure.");
                                             [[self activityIndicator] stopAnimating];
                                             if (JSON) {
                                                 NSLog(@"JSON: %@", JSON);
                                                 [self displayError:[JSON valueForKey:@"message"]];
                                             } else {
                                                 [self displayError:@"Unable to connect.  Try again later."];  
                                             }
                                             
                                         }];
    [operation start];
}

#pragma mark UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == _emailInputText) {
        [_usernameInputText becomeFirstResponder];
    } else if (textField == _usernameInputText) {
        if (![_currentPasswordInputText isHidden])
            [_currentPasswordInputText becomeFirstResponder];
        else
            [_passwordInputText becomeFirstResponder];
    } else if (textField == _currentPasswordInputText) {
        [_passwordInputText becomeFirstResponder];
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
