//
//  SignInViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 6/26/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "SignInViewController.h"
#import "CreateAccountViewController.h"
#import "AppDelegate.h"
#import "UIColor+ExtendedColor.h"
#import "AFNetworking.h"
#import "User.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize delegate = _delegate;
@synthesize navBar = _navBar;
@synthesize cancelButton = _cancelButton;

@synthesize facebookContainerView = _facebookContainerView;
@synthesize emailInputText = _emailInputText;
@synthesize passwordInputText = _passwordInputText;
@synthesize signInButton = _signInButton;
@synthesize createAccountButton = _createAccountButton;
@synthesize errorLabel = _errorLabel;
@synthesize activityIndicator = _activityIndicator;


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
    
    [self setTitle:@"Sign In"];
    
    [_navBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    [_cancelButton setTintColor:[UIColor navBarButtonColor]];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setFrame:CGRectMake(150, 250, 20, 20)];
    [self setActivityIndicator:activityIndicator];
    [self.view addSubview:activityIndicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == [self emailInputText]) {
        [textField resignFirstResponder];
        [[self passwordInputText] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark CreateAccountDelegate
- (void)createAccountViewController:(CreateAccountViewController *)createAccountViewController didCreate:(BOOL)didCreate
{
    if (didCreate) {
        [self dismissModalViewControllerAnimated:NO];
        [_delegate signInViewController:self didSignIn:YES];
    } else {
         [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark Button Actions

- (IBAction)createAccount:(id)sender
{
    CreateAccountViewController *viewController = [[CreateAccountViewController alloc] initWithNibName:@"CreateAccountViewController" bundle:nil];
    [viewController setDelegate:self];
    [self presentModalViewController:viewController animated:YES];
}

- (IBAction)signIn:(id)sender
{
    [[self emailInputText] resignFirstResponder];
    [[self passwordInputText] resignFirstResponder];
    
    if (self.emailInputText.text.length > 0 && self.passwordInputText.text.length > 0) {
        [[self emailInputText] setEnabled:NO];
        [[self passwordInputText] setEnabled:NO];
        [[self signInButton] setEnabled:NO];
        [[self createAccountButton] setEnabled:NO];
        
        [self displayActivityIndicator];
        NSString *requestString = [NSString stringWithFormat:@"user=%@&password=%@", self.emailInputText.text, self.passwordInputText.text]; 
        NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
        
        NSURL *url = [NSURL URLWithString:@"https://infoit-app.herokuapp.com/services/tokens"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody:requestData];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
        {
            [self hideActivityIndicator];

            NSString *accessToken = [JSON valueForKeyPath:@"token"];
            NSString *email = [JSON valueForKeyPath:@"email"];
            NSString *username = [JSON valueForKey:@"user_display_name"];
            NSNumber *userId = [JSON valueForKey:@"user_id"];

            [User signInUser:email withAccessToken:accessToken withUsername:username withUserId:userId];
            User *currentUser = [User currentUser];
            NSLog(@"current user access_token: %@", [currentUser accessToken]);

            [[self emailInputText] setEnabled:YES];
            [[self emailInputText] setText:nil];
            [[self passwordInputText] setEnabled:YES];
            [[self passwordInputText] setText:nil];
            [[self signInButton] setEnabled:YES];
            [[self createAccountButton] setEnabled:YES];

            [_delegate signInViewController:self didSignIn:YES];

            NSLog(@"User Login: %@", JSON);
        } 
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            [[self activityIndicator] stopAnimating];
            if (JSON) {
                [self displayError:[JSON valueForKeyPath:@"message"]];
            } else {
                [self displayError:@"Unable to connect.  Try again later."];  
            }

            [[self emailInputText] setEnabled:YES];
            [[self passwordInputText] setEnabled:YES];
            [[self signInButton] setEnabled:YES];
            [[self createAccountButton] setEnabled:YES];
        }];
        [operation start];
    } else {
        [self displayError:@"Email and password cannot be blank."];
    }
}

- (IBAction)signInWithFacebook:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate openFacebookSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didFinishSigningInWithFacebook:) 
                                                 name:MenuPicsFacebookNotification
                                               object:nil];
}

- (void)didFinishSigningInWithFacebook:(NSNotification *)notification
{
    FBSession *session = (FBSession *)[notification object];
    
    if (session.state == FBSessionStateOpen) {
        NSLog(@"Logged In with access token: %@", [session accessToken]);
        [_delegate signInViewController:self didSignIn:YES];
    }
}

- (IBAction)cancel:(id)sender
{
    [_emailInputText resignFirstResponder];
    [_passwordInputText resignFirstResponder];
    [_delegate signInViewController:self didSignIn:NO];
}

#pragma mark Animations

- (void)displayActivityIndicator
{
    [[self errorLabel] setHidden:YES];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.facebookContainerView setFrame:CGRectMake(0.0f, 275.0f, 320.0f, 140.0f)];
                     }
                     completion:^(BOOL finished){
                         [self.activityIndicator startAnimating];
                     }];
}

- (void)hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.facebookContainerView setFrame:CGRectMake(0.0f, 224.0f, 320.0f, 140.0f)];
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)displayError:(NSString *)error
{
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.facebookContainerView setFrame:CGRectMake(0.0f, 275.0f, 320.0f, 140.0f)];
                     }
                     completion:nil];
    [[self errorLabel] setText:error];
    [[self errorLabel] setHidden:NO];
}

@end
