//
//  NavController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/2/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavController : UIViewController

@property IBOutlet UIButton *findMenuButton;
@property IBOutlet UIButton *takePhotoButton;
@property IBOutlet UIButton *viewProfileButton;

- (IBAction)findMenu:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)viewProfile:(id)sender;

@end
