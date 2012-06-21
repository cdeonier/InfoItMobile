//
//  SavedPhoto.h
//  MenuPics
//
//  Created by Christian Deonier on 6/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ImageToDataTransformer : NSValueTransformer {
}
@end

@interface SavedPhoto : NSManagedObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileLocation;
@property (nonatomic, strong) UIImage *smallThumbnail;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSDate *creationDate; 
@property (nonatomic, strong) NSNumber *didUpload;
@property (nonatomic, strong) NSNumber *didDelete;
@property (nonatomic, strong) NSNumber *photoId;

@end
