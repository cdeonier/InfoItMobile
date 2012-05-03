//
//  InfoChooserViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoChooserViewController.h"
#import "IIViewDeckController.h"

#import "ImageUtil.h"

@interface InfoChooserViewController ()

@end

@implementation InfoChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *menuImage = [UIImage imageNamed:@"nav_menu_icon.png"];
    UIImage *scaledImage = [ImageUtil resizeImage:menuImage newSize:CGSizeMake(20.0f, 20.0f)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:scaledImage style:UIBarButtonItemStylePlain target:self.viewDeckController action:@selector(toggleLeftView)];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
                                
@end
