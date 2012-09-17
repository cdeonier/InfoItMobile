//
//  SignInViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "SignInViewController.h"

#import "CreateAccountViewController.h"
#import "MenuPicsAPIClient.h"
#import "User.h"

@interface SignInViewController ()

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton *signInButton;
@property (nonatomic, strong) IBOutlet UIButton *createButton;
@property (nonatomic, strong) IBOutlet UIButton *facebookLoginButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

- (IBAction)signIn:(id)sender;
- (IBAction)signInWithFacebook:(id)sender;
- (IBAction)createAccount:(id)sender;

@end

@implementation SignInViewController

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
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        //Back Button pressed
        [_delegate signInViewController:self didSignIn:NO];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)signIn:(id)sender
{
    [self disableViewInteraction];
    [self.errorLabel setHidden:YES];
    
    void (^didSignInBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didSignInBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {        
        NSString *accessToken = [JSON valueForKeyPath:@"token"];
        NSString *email = [JSON valueForKeyPath:@"email"];
        NSString *username = [JSON valueForKey:@"user_display_name"];
        NSNumber *userId = [JSON valueForKey:@"user_id"];
        NSString *loginType = [JSON valueForKey:@"login_type"];
        
        [User signInUser:email accessToken:accessToken username:username userId:userId loginType:loginType];
        
        [self.navigationController popViewControllerAnimated:NO];
        [_delegate signInViewController:self didSignIn:YES];
    };
    
    void (^failureSignInBlock)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id);
    failureSignInBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self enableViewInteraction];
        
        if (JSON) {
            [self displayError:[JSON valueForKeyPath:@"message"]];
        } else {
            [self displayError:@"Unable to connect.  Try again later."];
        }
    };
    
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (email.length > 0 && password.length > 0) {
        [MenuPicsAPIClient signIn:email password:password success:didSignInBlock failure:failureSignInBlock];
    } else {
        [self displayError:@"Email and password cannot be blank."];
        [self enableViewInteraction];
    }
}

- (IBAction)signInWithFacebook:(id)sender
{
    [self disableViewInteraction];
    
    void (^didSignInBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
    didSignInBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *accessToken = [JSON valueForKeyPath:@"access_token"];
        NSString *email = [JSON valueForKeyPath:@"email"];
        NSString *username = [JSON valueForKey:@"username"];
        NSNumber *userId = [JSON valueForKey:@"user_id"];
        NSString *loginType = [JSON valueForKey:@"login_type"];
        
        [User signInUser:email accessToken:accessToken username:username userId:userId loginType:loginType];
        
        [self.navigationController popViewControllerAnimated:NO];
        [_delegate signInViewController:self didSignIn:YES];
    };
    
    void (^failureSignInBlock)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id);
    failureSignInBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self enableViewInteraction];
        
        if (JSON) {
            [self displayError:[JSON valueForKeyPath:@"message"]];
        } else {
            [self displayError:@"Unable to connect.  Try again later."];
        }
    };
    
    //Access exisiting Facebook credentials on phone
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *facebookOptions = @{ACFacebookAppIdKey : @"378548658877603",
                                      ACFacebookPermissionsKey : @[@"email"],
                                      ACFacebookAudienceKey : ACFacebookAudienceOnlyMe};
    
    void (^facebookCompletionBlock)(BOOL, NSError *);
    facebookCompletionBlock = ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
            ACAccount *facebookAccount = [accounts lastObject];
            
            [MenuPicsAPIClient createAccountFromFacebook:facebookAccount.credential.oauthToken success:didSignInBlock failure:failureSignInBlock];
        } else {
            NSLog(@"%@", [error description]);
            NSLog(@"Did not grant permission.");
        }
    };
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:facebookOptions completion:facebookCompletionBlock];
}

- (IBAction)createAccount:(id)sender
{
    [self performSegueWithIdentifier:@"CreateAccountSegue" sender:self];
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

    [self.signInButton setEnabled:NO];
    [self.createButton setEnabled:NO];
    [self.facebookLoginButton setEnabled:NO];
}

- (void)enableViewInteraction
{
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];

    [self.signInButton setEnabled:YES];
    [self.createButton setEnabled:YES];
    [self.facebookLoginButton setEnabled:YES];
}

#pragma mark UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark CreateAccountDelegate

- (void)createAccountController:(CreateAccountViewController *)createAccountController didCreate:(BOOL)didCreate
{
    if (didCreate) {
        [self.navigationController popViewControllerAnimated:NO];
        [_delegate signInViewController:self didSignIn:YES];
    }
}

#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CreateAccountSegue"]) {
        CreateAccountViewController *createAccountController = [segue destinationViewController];
        [createAccountController setDelegate:self];
    }
}

@end
