//
//  FeedbackViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 8/31/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FeedbackViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "User.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

@synthesize scrollView = _scrollView;
@synthesize emailTextField = _emailTextField;
@synthesize textView = _textView;
@synthesize sendButton = _sendButton;

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

    [self setTitle:@"Send Feedback"];
    
    if ([User currentUser]) {
        [_emailTextField setText:[[User currentUser] email]];
    }
    
    [_sendButton setEnabled:NO];
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _emailTextField) {
        [textField resignFirstResponder];
        [_textView becomeFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    //keyboard notification sent before textViewDidBeginEditing, so set active field to textView now
    _activeField = _textView;
}

#pragma mark TextView Delegate

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //Enable send button as long as textView is not blank
    if ([_textView.text length] > 0) {
        [_sendButton setEnabled:YES];
    } else {
        [_sendButton setEnabled:NO];
    }
    
    //Check if we hit the "Done" button
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    //Limit message to length of 1000 characters
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= 1000)
    {
        return YES;
    } else {
        NSUInteger emptySpace = 1000 - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    _activeField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView;
{
    _activeField = nil;
}


#pragma mark Text Editing

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
    
    //To handle the size of TextView, look at bottom point instead of origin
    origin.y += _activeField.frame.size.height;
    
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

#pragma mark Webservice

- (IBAction)sendFeedback:(id)sender
{
    [SVProgressHUD showWithStatus:@"Sending..."];
    
    User *currentUser = [User currentUser];
    NSString *requestString;
    if (currentUser) {
        requestString = [NSString stringWithFormat:@"access_token=%@&message=%@", [currentUser accessToken], _textView.text];
    } else {
        NSLog(@"%@", _emailTextField.text);
        NSLog(@"%@", _textView.text);
        requestString = [NSString stringWithFormat:@"message=%@&email=%@", _textView.text, _emailTextField.text];
    }
    
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    
    NSURL *url = [NSURL URLWithString:@"http://infoit-app.herokuapp.com/services/feedbacks"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    
    AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             [TestFlight passCheckpoint:@"Sent Feedback"];
                                             
                                             [SVProgressHUD showWithStatus:@"Sent"];
                                             [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progressFinish) userInfo:nil repeats:NO];
                                             
                                         }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             NSLog(@"%@", [error description]);
                                             [SVProgressHUD showErrorWithStatus:@"Connection Error"];
                                         }];
    [operation start];
}

- (void)progressFinish
{
    [SVProgressHUD dismiss];
}

@end
