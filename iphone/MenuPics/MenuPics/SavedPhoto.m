//
//  SavedPhoto.m
//  MenuPics
//
//  Created by Christian Deonier on 6/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "SavedPhoto.h"

@implementation SavedPhoto

@dynamic fileName;
@dynamic fileLocation;
@dynamic fileUrl;
@dynamic thumbnail;
@dynamic thumbnailUrl;
@dynamic latitude;
@dynamic longitude;
@dynamic creationDate;
@dynamic didUpload;
@dynamic didDelete;
@dynamic didTag;
@dynamic photoId;
@dynamic restaurantId;
@dynamic menuItemId;
@dynamic username;

@synthesize isSelected;
@synthesize syncDelegate;

@end

@implementation ImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return uiImage;
}

@end
