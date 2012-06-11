//
//  HomeViewController.m
//  MenuPics
//
//  Created by Christian Deonier on 5/7/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "FindMenuViewController.h"
#import "TakePhotoViewController.h"
#import "IIViewDeckController.h"
#import "UIColor+ExtendedColor.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize findMenuTitle = _findMenuTitle;
@synthesize takePhotoTitle = _takePhotoTitle;
@synthesize viewProfileTitle = _viewProfileTitle;

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
    
    UIFont *segoePrint = [UIFont fontWithName:@"Segoe Print" size:_findMenuTitle.font.pointSize];
    
    [_findMenuTitle setFont:segoePrint];
    [_takePhotoTitle setFont:segoePrint];
    [_viewProfileTitle setFont:segoePrint];
    
    UIImage *menuImage = [[UIImage imageNamed:@"nav_menu_icon.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self.viewDeckController action:@selector(toggleLeftView)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor navBarButtonColor];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if ([navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    }
    [navigationBar.topItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]]];
    
    //Title not actually displayed on Home screen, used for back button title acquisition in NavController
    [self setTitle:@"Home"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.viewDeckController.view.frame = [[UIScreen mainScreen] applicationFrame];
    [self.viewDeckController.view setNeedsDisplay];
    
    [self outputState];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)findMenu:(id)sender
{
    FindMenuViewController *viewController = [[FindMenuViewController alloc] initWithNibName:@"FindMenuViewController" bundle:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    backButton.tintColor = [UIColor navBarButtonColor];
    self.navigationItem.backBarButtonItem = backButton;
    [viewController setTitle:@"Restaurants"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)takePhoto:(id)sender
{
    TakePhotoViewController *viewController = [[TakePhotoViewController alloc] initWithNibName:@"TakePhotoViewPortrait" bundle:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    backButton.tintColor = [UIColor navBarButtonColor];
    self.navigationItem.backBarButtonItem = backButton;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)outputState
{
    NSFileManager *filemgr;
    NSArray *dirPaths;
    NSString *docsDir;
    
    filemgr =[NSFileManager defaultManager];
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString *takePhotosDirectory = [docsDir stringByAppendingPathComponent:@"takePhotos"];
    NSString *photosDirectory = [docsDir stringByAppendingPathComponent:@"photos"];
    
    NSLog(@"*************************************");
    
    NSArray *fileList = [filemgr contentsOfDirectoryAtPath:docsDir error:NULL];
    NSLog(@"Contents of Documents Directory:");
    for (NSString *file in fileList) {
        NSLog(file);
    }
    
    fileList = [filemgr contentsOfDirectoryAtPath:takePhotosDirectory error:NULL];
    NSLog(@"Contents of Take Photos Directory:");
    for (NSString *file in fileList) {
        NSLog(file);
    }
    
    fileList = [filemgr contentsOfDirectoryAtPath:photosDirectory error:NULL];
    NSLog(@"Contents of Photos Directory:");
    for (NSString *file in fileList) {
        NSLog(file);
    }
    
    NSLog(@"-------------------------------------");
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedPhoto" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"Error fetching from Core Data");
    }
    
    NSLog(@"Core Data row count: %i", [mutableFetchResults count]);
    
    NSLog(@"*************************************");
}


@end
