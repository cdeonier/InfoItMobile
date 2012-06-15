//
//  User.h
//  MenuPics
//
//  Created by Christian Deonier on 6/14/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *accessToken;

@end
