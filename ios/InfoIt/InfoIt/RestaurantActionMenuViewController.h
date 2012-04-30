//
//  RestaurantActionMenuViewController.h
//  InfoIt
//
//  Created by Christian Deonier on 4/7/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantActionMenuViewController : UIViewController {
    IBOutlet UIButton *bookmarkButton;
    IBOutlet UIButton *viewMenuButton;
}

-(void) initializeBookmarkButton;
-(void) initializeViewMenuButton;

@end
