//
//  PhotosViewController.h
//  MenuPics
//
//  Created by Christian Deonier on 9/8/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MWPhotoBrowser.h"

@class SavedPhoto;

@interface PhotosViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, MWPhotoBrowserDelegate>

- (void)addNewPhoto:(SavedPhoto *)photo;
- (void)reloadData;

@end
