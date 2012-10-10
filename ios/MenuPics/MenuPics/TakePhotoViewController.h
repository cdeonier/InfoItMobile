//
//  TakePhotoViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/7/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuItem;
@class Photo;
@class TakePhotoViewController;

@protocol TakePhotoDelegate <NSObject>

- (void)didTakePhoto:(TakePhotoViewController *)viewController;

@end

@interface TakePhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) id<TakePhotoDelegate> delegate;
@property (nonatomic, strong) MenuItem *menuItem;

@property (nonatomic, strong) Photo *photo;


@end
