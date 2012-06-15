//
//  ViewProfileViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"

@class CreateAccountViewController;

enum {
    ProfileTab = 1,
    PhotosTab = 2
};
typedef NSInteger ViewProfileTab;

@protocol CreateAccountDelegate <NSObject, UITextFieldDelegate>

- (void)createAccountViewController:(CreateAccountViewController *)createAccountViewController didCreate:(BOOL)didCreate;

@end

@interface ViewProfileViewController : UIViewController <CreateAccountDelegate, UITabBarDelegate, GMGridViewDataSource, GMGridViewActionDelegate>

@property (nonatomic, strong) IBOutlet UITabBar *tabBar;

//Profile
@property (nonatomic, strong) IBOutlet UIView *signInView;
@property (nonatomic, strong) IBOutlet UIView *facebookContainerView;
@property (nonatomic, strong) IBOutlet UITextField *emailInputText;
@property (nonatomic, strong) IBOutlet UITextField *passwordInputText;
@property (nonatomic, strong) IBOutlet UIButton *signInButton;
@property (nonatomic, strong) IBOutlet UIButton *createAccountButton;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

//Photos
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) GMGridView *photosGridView;

- (IBAction)createAccount:(id)sender;
- (IBAction)signIn:(id)sender;

@end
