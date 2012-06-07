//
//  Photo.m
//  MenuPics
//
//  Created by Christian Deonier on 6/1/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "Photo.h"
#import "MenuPicsAPIClient.h"

@implementation Photo

@synthesize location = _location;
@synthesize isSelected = _isSelected;
@synthesize thumbnail = _thumbnail;
@synthesize fileLocation = _fileLocation;
@synthesize fileName = _fileName;

+ (void)uploadPhotoAtLocation:(CLLocation *)location
                        image:(UIImage *)image
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"photo[lat]"];
    [mutableParameters setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"photo[lng]"];
    
    NSMutableURLRequest *mutableURLRequest = [[MenuPicsAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:@"/services/photos?access_token=72d41492785ebe68fc9e46d5510dda17a21e8c2b46c27bf7535324b3e72d6401" parameters:mutableParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8) name:@"photo[photo_attachment]" fileName:@"image.jpg" mimeType:@"image/jpeg"];
    }];
    //NSLog([mutableURLRequest description]);
    
    AFHTTPRequestOperation *operation = [[MenuPicsAPIClient sharedClient] HTTPRequestOperationWithRequest:mutableURLRequest success:^(AFHTTPRequestOperation *operation, id JSON) {
        //NSLog([JSON description]);
        NSLog(@"Upload Success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Upload Failure");
    }];
    [[MenuPicsAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
}

@end
