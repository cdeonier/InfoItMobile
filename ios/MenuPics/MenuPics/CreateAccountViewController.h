//
//  CreateAccountViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreateAccountViewController;

@protocol CreateAccountDelegate <NSObject>

- (void)createAccountController:(CreateAccountViewController *)createAccountController didCreate:(BOOL)didCreate;

@end

@interface CreateAccountViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) id<CreateAccountDelegate> delegate;


@end
