//
//  MainViewController.m
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "FavorViewController.h"
#import "VoiceDef.h"
#import "StoreVoiceDataListParser.h"
#import "GTMHTTPFetcher.h"
#import "PersonalMainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    if (_scrollview == nil) {
        UIView* customview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
        UIButton* store = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [store setImage:[UIImage imageNamed:@"Indicator_Store@2x.png"] forState:UIControlStateNormal];
        [customview addSubview:store];
        [store release];
        
        
        UIButton* home = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [store setImage:[UIImage imageNamed:@"Indicator_Home@2x.png"] forState:UIControlStateNormal];
        [customview addSubview:store];
        [store release];
       
        NSArray* imArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Indicator_Store@2x.png"], [UIImage imageNamed:@"Indicator_Home@2x.png"], [UIImage imageNamed:@"Indicator_Setting@2x.png"], nil];
        UISegmentedControl* seg = [[UISegmentedControl alloc] initWithItems:imArray];
        seg.frame = CGRectMake(0 , 0, 90, 30);
        seg.segmentedControlStyle = UISegmentedControlStyleBezeled;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:seg];
        [seg release];
         _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.view addSubview:_scrollview];
        /*PersonalViewController* persnoal = [[PersonalViewController alloc] initWithNibName:@"PersonalViewController" bundle:nil];
        [_scrollview addSubview:persnoal.view];
        persnoal.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        */
        PersonalMainViewController* persnoal = [[PersonalMainViewController alloc] initWithStyle:UITableViewStylePlain];
        [_scrollview addSubview:persnoal.view];
        persnoal.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        FavorViewController* favor = [[FavorViewController alloc] init];
        [_scrollview addSubview:favor.view];
        favor.view.frame = CGRectMake(persnoal.view.frame.origin.x + persnoal.view.frame.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        SettingViewController* setting = [[SettingViewController alloc] init];
        [_scrollview addSubview:setting.view];
        
        setting.view.frame = CGRectMake(favor.view.frame.origin.x + favor.view.frame.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
       
        
        [_scrollview setContentSize:CGSizeMake(self.view.bounds.size.width * 3, self.view.bounds.size.height)];
        [_scrollview setPagingEnabled:YES];
        [_scrollview setContentOffset:CGPointMake(self.view.bounds.size.width, 0)];
    }
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = STRING_MY_RES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
 	[center addObserver:self selector:@selector(openLessonsNotification:) name:NOTIFICATION_OPEN_LESSONS object:nil];
  	[center addObserver:self selector:@selector(openPkg:) name:NOTIFICATION_OPEN_PKG object:nil];
    [center addObserver:self selector:@selector(openStore:) name:NOTIFICATION_OPEN_A_STORE object:nil];
 
    
	// Do any additional setup after loading the view.
}

- (void)openPkg:(NSNotification*)aNotification;
{
    [self performSelector:@selector(setFavorViewPosition) withObject:nil afterDelay:1.0];
}

- (void)openStore:(NSNotification*)aNotification;
{
    UIViewController* ob = aNotification.object;
    UIViewAnimationTransition transition = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:transition forView:[self.view window] cache: NO];
    [self presentModalViewController:ob animated:NO];
    [UIView commitAnimations];
}

- (void)setFavorViewPosition
{
    [_scrollview setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:YES];
 
}

- (void)openLessonsNotification:(NSNotification*)aNotification;
{
    UIViewController* ob = aNotification.object;
    if (ob != nil) {
        [self.navigationController pushViewController:ob animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NOTIFICATION_OPEN_PKG object:nil];
    [super dealloc];
}

@end
