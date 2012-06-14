//
//  CreateAccountViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateAccountDelegate;

@interface CreateAccountViewController : UIViewController

@property (nonatomic, strong) id<CreateAccountDelegate> delegate;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)cancel:(id)sender;

@end
