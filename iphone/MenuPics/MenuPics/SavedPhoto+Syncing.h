//
//  SavedPhoto+Syncing.h
//  MenuPics
//
//  Created by Christian Deonier on 6/23/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "SavedPhoto.h"

@interface SavedPhoto (Syncing)

+ (void)downloadPhotoImages:(SavedPhoto *)photo;
+ (BOOL)hasDownloadedImages:(SavedPhoto *)photo;
+ (void)finalizeDownloadedPhoto:(SavedPhoto *)photo;
+ (void)uploadPhoto:(SavedPhoto *)photo;

@end
