//
//  FeedbackViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 10/15/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import "FeedbackViewController.h"

#import "MenuPicsAPIClient.h"
#import "SVProgressHUD.h"
#import "User.h"

@interface FeedbackViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) UIView *activeField;

- (IBAction)sendFeedback:(id)sender;

@end

@implementation FeedbackViewController

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
	
    if ([User currentUser]) {
        [_emailTextField setText:[[User currentUser] email]];
    }
    
    [_sendButton setEnabled:NO];
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (IBAction)sendFeedback:(id)sender
{
    [SVProgressHUD showWithStatus:@"Sending..."];
    
    SuccessBlock success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [SVProgressHUD showWithStatus:@"Sent"];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(progressFinish) userInfo:nil repeats:NO];
    };
    
    [MenuPicsAPIClient sendFeedback:_emailTextField.text message:_textView.text success:success];
}

- (void)progressFinish
{
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
