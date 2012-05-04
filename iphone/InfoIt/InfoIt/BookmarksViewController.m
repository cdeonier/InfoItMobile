//
//  BookmarksViewController.m
//  InfoIt
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "BookmarksViewController.h"
#import "IIViewDeckController.h"

#import "ImageUtil.h"

@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

@synthesize tableView = _tableView;

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end
