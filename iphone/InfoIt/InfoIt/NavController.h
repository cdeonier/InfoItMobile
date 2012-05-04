//
//  NavController.h
//  InfoIt
//
//  Created by Christian Deonier on 5/2/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavController : UIViewController

@property IBOutlet UIButton *infoButton;
@property IBOutlet UIButton *bookmarksButton;
@property IBOutlet UIButton *historyButton;
@property IBOutlet UIButton *accountButton;

- (IBAction)pressedInfo:(id)sender;
- (IBAction)pressedBookmarks:(id)sender;
- (IBAction)pressedHistory:(id)sender;
- (IBAction)pressedAccount:(id)sender;

@end
