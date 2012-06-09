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

- (IBAction)pressFindMenu:(id)sender;
- (IBAction)pressTakePhoto:(id)sender;
- (IBAction)pressViewProfile:(id)sender;
- (IBAction)releaseFindMenu:(id)sender;
- (IBAction)releaseTakePhoto:(id)sender;
- (IBAction)releaseViewProfile:(id)sender;
- (IBAction)findMenu:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)viewProfile:(id)sender;

@end
