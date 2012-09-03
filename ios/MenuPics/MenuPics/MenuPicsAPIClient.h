//
//  MenuPicsAPIClient.h
//  MenuPics
//
//  Created by Christian Deonier on 9/3/12.
//  Copyright (c) 2012 Christian Deonier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^SuccessBlock)(NSURLRequest *, NSHTTPURLResponse *, id);
typedef void (^FailureBlock)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id);

@interface MenuPicsAPIClient : NSObject

+ (void)getNearbyLocationsAtLocation:(CLLocation *)location success:(SuccessBlock)success;

@end
