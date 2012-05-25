//
//  HomeViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController 

@property IBOutlet UILabel *findMenuTitle;
@property IBOutlet UILabel *takePhotoTitle;
@property IBOutlet UILabel *viewProfileTitle;

- (IBAction)findMenu:(id)sender;
- (IBAction)takePhoto:(id)sender;

@end
