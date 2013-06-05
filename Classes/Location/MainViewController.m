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
#import "VoiceDef.h"
#import "StoreVoiceDataListParser.h"
#import "GTMHTTPFetcher.h"

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
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
 	[center addObserver:self selector:@selector(openLessonsNotification:) name:NOTIFICATION_OPEN_LESSONS object:nil];
    
    // download voice.xml
    NSURL* url = [NSURL URLWithString:STRING_STORE_URL_ADDRESS];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"MyApp" forHTTPHeaderField:@"User-Agent"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(fetcher:finishedWithData:error:)];
	// Do any additional setup after loading the view.
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
- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
 	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    V_NSLog(@"fecther : %@", [fecther description]);
    V_NSLog(@"error : %@", [error description]);
    if (error != nil) {
        
    } else {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        if (![fm fileExistsAtPath:documentDirectory isDirectory:nil])
            [fm createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        documentDirectory = [documentDirectory stringByAppendingFormat:@"/%@", STRING_VOICE_PKG_DIR];
        
        // create pkg
        if (![fm fileExistsAtPath:documentDirectory isDirectory:nil])
            [fm createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        
        NSString* xmlPath =  [NSString stringWithFormat:@"%@/voice.xml", documentDirectory];
        [data writeToFile:xmlPath atomically:YES];
        StoreVoiceDataListParser * dataParser = [[StoreVoiceDataListParser alloc] init];
        [dataParser loadWithData:data];
        DownloadServerInfo* info = [DownloadServerInfo sharedDownloadServerInfo];
        if (info != nil) {
            info.serverList = dataParser.serverlistArray;
        }
        [dataParser release];
    }
}

@end
