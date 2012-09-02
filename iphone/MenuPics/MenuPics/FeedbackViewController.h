//
//  FeedbackViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 8/31/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) UIView *activeField;

- (IBAction)sendFeedback:(id)sender;

@end
