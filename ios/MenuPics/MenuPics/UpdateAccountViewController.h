//
//  UpdateAccountViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UpdateAccountViewController;

@protocol UpdateAccountDelegate <NSObject>

- (void)updateAccountViewController:(UpdateAccountViewController *)updateAccountViewController didUpdateAccount:(BOOL)didUpdateAccount;

@end

@interface UpdateAccountViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) id<UpdateAccountDelegate> delegate;

@end
