//
//  FacebookGraphProtocols.h
//  MenuPics
//
//  Created by Christian Deonier on 8/12/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBiOSSDK/FacebookSDK.h>

@protocol FBDishObject<FBGraphObject>

@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;

@end

@protocol FBPhotographAction<FBOpenGraphAction>

@property (retain, nonatomic) id<FBDishObject> dish;

@end