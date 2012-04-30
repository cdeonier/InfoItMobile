//
//  NavigationMenuViewController.h
//  InfoIt
//
//  Created by Christian Deonier on 4/3/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationMenuViewController : UIViewController {
    IBOutlet UIButton *bookmarkButton;
    IBOutlet UIButton *recentHistoryButton;
}

-(void) initializeBookmarkButton;
-(void) initializeRecentHistoryButton;

@end
