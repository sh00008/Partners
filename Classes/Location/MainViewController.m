//
//  MainViewController.m
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "MainViewController.h"
#import "SettingAboutViewController.h"
#import "FavorViewController.h"
#import "VoiceDef.h"
#import "StoreVoiceDataListParser.h"
#import "GTMHTTPFetcher.h"
#import "PersonalMainViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()
{
    // buttons in title bar
    UIButton* _store;
    UIButton* _home;
    UIButton* _settingBar;
    UIButton* _editingLib;
    UILabel* _titleLabel;
    PersonalMainViewController* _persnoal;
    BOOL _edit;
}
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
        NSInteger iconSize = 24;
        NSInteger iconBigSize = 36;
       _edit = NO;
        _editingLib = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconBigSize, iconBigSize)];
        [_editingLib addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
        [_editingLib setImage:[UIImage imageNamed:@"Icon_edit.png"] forState:UIControlStateNormal];
        UIBarButtonItem* box = [[UIBarButtonItem alloc] initWithCustomView:_editingLib];
        self.navigationItem.leftBarButtonItem = box;
        [box release];
      
        UIView* customview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iconSize*3 + 9, iconSize)];
        UIButton* store = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
        [store setImage:[UIImage imageNamed:@"Indicator_Store@2x.png"] forState:UIControlStateNormal];
        [store setImage:[UIImage imageNamed:@"Indicator_Store_Hit@2x.png"] forState:UIControlStateSelected];
       [customview addSubview:store];
        _store = store;
        [store release];
        
        
        UIButton* home = [[UIButton alloc] initWithFrame:CGRectMake(store.frame.origin.x + store.frame.size.width + 3, 0, iconSize, iconSize)];
        [home setImage:[UIImage imageNamed:@"Indicator_Home@2x.png"] forState:UIControlStateNormal];
        [home setImage:[UIImage imageNamed:@"Indicator_Home_Hit@2x.png"] forState:UIControlStateSelected];
        [customview addSubview:home];
        _home = home;
        [home release];
       
        
        UIButton* settingbar = [[UIButton alloc] initWithFrame:CGRectMake(home.frame.origin.x + home.frame.size.width + 3, 0, iconSize, iconSize)];
        [settingbar setImage:[UIImage imageNamed:@"Indicator_Setting@2x.png"] forState:UIControlStateNormal];
        [settingbar setImage:[UIImage imageNamed:@"Indicator_Setting_Hit@2x.png"] forState:UIControlStateSelected];
        [customview addSubview:settingbar];
        _settingBar = settingbar;
        [settingbar release];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customview];
        [customview release];
         _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.view addSubview:_scrollview];
        _scrollview.delegate = (id)self;
        
        _persnoal = [[PersonalMainViewController alloc] init];
        [_scrollview addSubview:_persnoal.view];
        _persnoal.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        FavorViewController* favor = [[FavorViewController alloc] init];
        [_scrollview addSubview:favor.view];
        favor.view.frame = CGRectMake(_persnoal.view.frame.origin.x + _persnoal.view.frame.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        SettingAboutViewController* setting = [[SettingAboutViewController alloc] init];
        [_scrollview addSubview:setting.view];
        
        setting.view.frame = CGRectMake(favor.view.frame.origin.x + favor.view.frame.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height - CELL_CONTENT_MARGIN*2);
       
        
        [_scrollview setContentSize:CGSizeMake(self.view.bounds.size.width * 3, self.view.bounds.size.height)];
        [_scrollview setPagingEnabled:YES];
        [_scrollview setContentOffset:CGPointMake(self.view.bounds.size.width, 0)];
        
        [_home setSelected:YES];
    }
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    _titleLabel = titleLabel;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = STRING_MY_RES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Arial" size:22];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
 	[center addObserver:self selector:@selector(openLessonsNotification:) name:NOTIFICATION_ADDNEWNAVI object:nil];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint pt = scrollView.contentOffset;
    if (pt.x < self.view.bounds.size.width) {
        [_store setSelected:YES];
        [_home setSelected:NO];
        [_settingBar setSelected:NO];
        _titleLabel.text = STRING_LIBS;
        _editingLib.hidden = NO;
     } else if (pt.x > self.view.bounds.size.width) {
        [_store setSelected:NO];
        [_home setSelected:NO];
        [_settingBar setSelected:YES];
        _titleLabel.text = STRING_ABOUT_US;
         _editingLib.hidden = YES;
     } else {
        [_store setSelected:NO];
        [_home setSelected:YES];
        [_settingBar setSelected:NO];
        _titleLabel.text = STRING_MY_RES;
         _editingLib.hidden = YES;
    }
    [_titleLabel sizeToFit];
    
}

- (void)edit {
    if ([_persnoal isCanPerfomEdit]) {
        _edit = !_edit;
        [_persnoal setEditing:_edit animated:YES];
    }
}
@end
