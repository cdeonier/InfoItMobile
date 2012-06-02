//
//  MenuPicsAPIClient.h
//  MenuPics
//
//  Created by Christian Deonier on 6/1/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface MenuPicsAPIClient : AFHTTPClient

+ (MenuPicsAPIClient *)sharedClient;

@end
