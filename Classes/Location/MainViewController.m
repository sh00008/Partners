//
//  MainViewController.m
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "PersonalViewController.h"
#import "FavorViewController.h"

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
        self.navigationController.navigationBar.hidden = YES;
 
        self.navigationController.navigationBarHidden = YES;
        _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.view addSubview:_scrollview];
        PersonalViewController* persnoal = [[PersonalViewController alloc] initWithNibName:@"PersonalViewController" bundle:nil];
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
