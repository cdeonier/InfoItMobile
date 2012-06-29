//
//  SavedPhoto+Syncing.h
//  MenuPics
//
//  Created by Christian Deonier on 6/23/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "SavedPhoto.h"
#import <CoreLocation/CoreLocation.h>

@interface SavedPhoto (Syncing)

+ (void)downloadThumbnail:(SavedPhoto *)photo;
+ (void)uploadPhoto:(SavedPhoto *)photo;
+ (void)tagPhoto:(SavedPhoto *)photo;

@end
