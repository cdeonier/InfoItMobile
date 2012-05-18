//
//  NavController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/2/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "NavController.h"
#import "FindMenuViewController.h"
#import "TakePhotoViewController.h"


#import "UIColor+ExtendedColor.h"
#import "IIViewDeckController.h"

@interface NavController ()

@end

@implementation NavController

@synthesize findMenuButton = _findMenuButton;
@synthesize takePhotoButton = _takePhotoButton;
@synthesize viewProfileButton = _viewProfileButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pressFindMenu:(id)sender
{
    [self.findMenuButton setBackgroundColor:[UIColor navButtonPressedColor]];   
}

- (IBAction)pressTakePhoto:(id)sender
{
    
}

- (IBAction)pressViewProfile:(id)sender
{
    
}

- (IBAction)findMenu:(id)sender 
{
    [self.findMenuButton setBackgroundColor:[UIColor clearColor]];
    FindMenuViewController *viewController = [[FindMenuViewController alloc] initWithNibName:@"FindMenuViewController" bundle:nil];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    [self.viewDeckController toggleLeftView];
}

- (IBAction)takePhoto:(id)sender 
{

}

- (IBAction)viewProfile:(id)sender
{

}


@end
