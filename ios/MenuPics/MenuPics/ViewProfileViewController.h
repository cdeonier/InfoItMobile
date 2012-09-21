//
//  ViewProfileViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SavedPhoto;

@interface ViewProfileViewController : UITabBarController  <UITabBarControllerDelegate, UIActionSheetDelegate>

- (void)addNewPhoto:(SavedPhoto *)photo;

@end
