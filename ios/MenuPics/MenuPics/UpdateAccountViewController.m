//
//  UpdateAccountViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "UpdateAccountViewController.h"

#import "MenuPicsAPIClient.h"
#import "User.h"

@interface UpdateAccountViewController ()

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *currentPasswordTextField;
@property (nonatomic, strong) IBOutlet UITextField *updatedPasswordTextField;
@property (nonatomic, strong) IBOutlet UISwitch *facebookSwitch;
@property (nonatomic, strong) IBOutlet UIButton *updateAccountButton;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet UILabel *facebookLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UITextField *activeField;

- (IBAction)updateAccount:(id)sender;

@end

@implementation UpdateAccountViewController

@synthesize delegate = _delegate;

@synthesize emailTextField = _emailTextField;
@synthesize usernameTextField = _usernameTextField;
@synthesize currentPasswordTextField = _currentPasswordTextField;
@synthesize updatedPasswordTextField = _updatedPasswordTextField;
@synthesize facebookSwitch = _facebookSwitch;
@synthesize updateAccountButton = _updateAccountButton;
@synthesize errorLabel = _errorLabel;
@synthesize facebookLabel = _facebookLabel;
@synthesize activityIndicator = _activityIndicator;
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
    
    [self.activityIndicator setHidden:YES];
    
    [self defaultUserInfo];
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)updateAccount:(id)sender
{
    [self disableViewInteraction];
    [self.errorLabel setHidden:YES];
    
    void (^didUpdateBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didUpdateBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([[User currentUser] isFacebookOnly]) {
            NSString *accessToken = [[User currentUser] accessToken];
            NSString *email = [JSON valueForKeyPath:@"email"];
            NSString *username = [JSON valueForKeyPath:@"username"];
            NSNumber *userId = [JSON valueForKey:@"user_id"];
            NSString *loginType = [JSON valueForKey:@"login_type"];
            
            [User signInUser:email accessToken:accessToken username:username userId:userId loginType:loginType];
        } else {
            NSString *accessToken = [[User currentUser] accessToken];
            NSString *email = [[JSON valueForKey:@"user"] valueForKeyPath:@"email"];
            NSString *username = [[JSON valueForKey:@"user"] valueForKeyPath:@"username"];
            NSNumber *userId = [[JSON valueForKey:@"user"] valueForKey:@"user_id"];
            NSString *loginType = [[JSON valueForKey:@"user"] valueForKey:@"login_type"];
            
            [User signOutUser];
            [User signInUser:email accessToken:accessToken username:username userId:userId loginType:loginType];
        }
        
        [self.navigationController popViewControllerAnimated:NO];
        [self.delegate updateAccountViewController:self didUpdateAccount:YES];
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
    
    NSString *email = self.emailTextField.text;
    NSString *username = self.usernameTextField.text;
    NSString *currentPassword = self.currentPasswordTextField.text;
    NSString *updatedPassword = self.updatedPasswordTextField.text;
    
    if (email.length == 0 || username.length == 0) {
        [self displayError:@"Email and username cannot be blank."];
        [self enableViewInteraction];
    } else if (![[User currentUser] isFacebookOnly] && currentPassword.length == 0) {
        [self displayError:@"Enter current password to update account."];
        [self enableViewInteraction];
    } else {
        [MenuPicsAPIClient updateAccount:username email:email password:currentPassword updatedPassword:updatedPassword success:didUpdateBlock failure:failureCreateBlock];
    }
    
}

- (void)displayError:(NSString *)error
{
    [self.errorLabel setHidden:NO];
    [self.errorLabel setText:error];
}

//Called to disable buttons and show activity indicator
- (void)disableViewInteraction
{
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    [self.updateAccountButton setEnabled:NO];
}

- (void)enableViewInteraction
{
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
    
    [self.updateAccountButton setEnabled:YES];
}

- (void)defaultUserInfo
{
    User *currentUser = [User currentUser];
    
    if (![currentUser.loginType isEqualToString:@"NATIVE"]) {
        [self.facebookSwitch setOn:YES];
    }
    
    if ([currentUser.loginType isEqualToString:@"FACEBOOK"]) {
        CGRect frame = self.currentPasswordTextField.frame;
        [self.currentPasswordTextField setHidden:YES];
        [self.updatedPasswordTextField setFrame:frame];
        [self.emailTextField setText:[[User currentUser] email]];
        [self.facebookSwitch setHidden:YES];
        [self.facebookLabel setHidden:YES];
        
        frame = self.updateAccountButton.frame;
        frame.origin.y -= 120;
        [self.updateAccountButton setFrame:frame];
        
        frame = self.errorLabel.frame;
        frame.origin.y -= 120;
        [self.errorLabel setFrame:frame];
        
        frame = self.activityIndicator.frame;
        frame.origin.y -= 110;
        [self.activityIndicator setFrame:frame];
    } else {
        [self.emailTextField setText:[[User currentUser] email]];
        [self.usernameTextField setText:[[User currentUser] username]];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self.usernameTextField becomeFirstResponder];
    } else if (textField == self.usernameTextField) {
        [textField resignFirstResponder];
        [self.currentPasswordTextField becomeFirstResponder];
    } else if (textField == self.currentPasswordTextField) {
        [textField resignFirstResponder];
        [self.updatedPasswordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
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
    CGRect aRect = self.scrollView.frame;
    aRect.origin.y = 0;
    aRect.size.height -= kbSize.height;
    CGPoint origin = self.activeField.frame.origin;
    origin.y -= self.scrollView.contentOffset.y;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y-(aRect.size.height) + self.activeField.frame.size.height + 7);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
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
