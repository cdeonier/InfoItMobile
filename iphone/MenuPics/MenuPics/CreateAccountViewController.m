//
//  CreateAccountViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "ViewProfileViewController.h"
#import "UIColor+ExtendedColor.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

@synthesize delegate = _delegate;
@synthesize navBar = _navBar;
@synthesize cancelButton = _cancelButton;
@synthesize createAccountButton = _createAccountButton;
@synthesize emailInputText = _emailInputText;
@synthesize passwordInputText = _passwordInputText;
@synthesize verifyPasswordInputText = _verifyPasswordInputText;
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

    [_navBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    [_cancelButton setTintColor:[UIColor navBarButtonColor]];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setFrame:CGRectMake(150, 262, 20, 20)];
    [self setActivityIndicator:activityIndicator];
    [self.view addSubview:activityIndicator];
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
    [_delegate createAccountViewController:self didCreate:NO];
}

- (IBAction)createAccount:(id)sender
{
    [[self createAccountButton] setHidden:YES];
    [[self emailInputText] setEnabled:NO];
    [[self passwordInputText] setEnabled:NO];
    [[self verifyPasswordInputText] setEnabled:NO];
    [[self activityIndicator] startAnimating];
}

#pragma mark UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == [self emailInputText]) {
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

@end
