//
//  MenuPicsAPIClient.m
//  MenuPics
//
//  Created by Christian Deonier on 6/1/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "MenuPicsAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFMenuPicsAPIBaseURLString = @"https://infoit.heroku.com/";
//static NSString * const kAFMenuPicsAPIBaseURLString = @"http://192.168.0.103/";

@implementation MenuPicsAPIClient

+ (MenuPicsAPIClient *)sharedClient {
    static MenuPicsAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MenuPicsAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFMenuPicsAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
