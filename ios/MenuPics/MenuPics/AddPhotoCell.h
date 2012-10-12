//
//  AddPhotoCell.h
//  MenuPics
//
//  Created by Christian Deonier on 9/17/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SignInViewController.h"

@interface AddPhotoCell : UICollectionViewCell <SignInDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (nonatomic, strong) UIViewController *viewController;

- (IBAction)addPhoto:(id)sender;

@end
