//
//  InfoChooserViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "InfoChooserViewController.h"
#import "NearbyLocationsViewController.h"
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
    
    UIImage *menuImage = [[UIImage imageNamed:@"nav_menu_icon.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self.viewDeckController action:@selector(toggleLeftView)];
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

- (IBAction)pressedNearbyLocations:(id)sender
{
    NearbyLocationsViewController *viewController = [[NearbyLocationsViewController alloc] initWithNibName:@"NearbyLocationsViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}
                                
@end
