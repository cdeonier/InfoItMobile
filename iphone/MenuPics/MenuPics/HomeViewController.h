//
//  HomeViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignInViewController.h"

@interface HomeViewController : UIViewController <SignInDelegate>

//User View Properties
@property IBOutlet UIView *userView;
@property IBOutlet UILabel *findMenuTitle;
@property IBOutlet UILabel *takePhotoTitle;
@property IBOutlet UILabel *viewProfileTitle;
@property IBOutlet UIButton *notificationButton;

//Non-User View Properties
@property IBOutlet UIView *nonUserView;
@property IBOutlet UILabel *findMenuTitleNonUser;
@property IBOutlet UILabel *signInTitle;

- (IBAction)findMenu:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)viewProfile:(id)sender;
- (IBAction)notificationButtonSelected:(id)sender;

@end
