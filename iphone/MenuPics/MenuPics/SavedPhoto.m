//
//  SavedPhoto.m
//  MenuPics
//
//  Created by Christian Deonier on 6/10/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "SavedPhoto.h"
#import "AppDelegate.h"

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
@dynamic points;

@synthesize isSelected;
@synthesize syncDelegate;

+ (SavedPhoto *)photoWithFilename:(NSString *)fileName
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *coreDataRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [coreDataRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"fileName == '%@'", fileName]];
    [coreDataRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:coreDataRequest error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    SavedPhoto *photo = nil;
    if ([mutableFetchResults count] > 0) {
        photo = [mutableFetchResults objectAtIndex:0];
    } else  {
        NSLog(@"Could not find photo with fileName: %@", fileName);
    }
    
    return photo;
}

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
