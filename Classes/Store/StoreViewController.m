//
//  StoreViewController.m
//  Sanger
//
//  Created by JiaLi on 12-7-14.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import "StoreViewController.h"
#import "GTMHTTPFetcher.h"
#import "StoreVoiceDataListParser.h"
#import "StoreRootViewController.h"
#import "StoreNetworkConnectionView.h"
#import "VoiceDef.h"
#import "CurrentInfo.h"
#import "Database.h"
#import "Globle.h"

@interface StoreViewController ()
{
    BOOL bInit;
}
@end

@implementation StoreViewController
@synthesize storeURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        bInit = NO;
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!bInit) {
        [self initMembers];
        bInit = YES;
    }
}

- (void) initMembers
{
    /*if([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar
         setBackgroundImage:[UIImage imageNamed:@"4-light-menu-bar.png"]
         forBarMetrics:UIBarMetricsDefault];
    }*/

    // backgroundColor
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* stringResource = @"bg_webview.png";
    NSString* imagePath = [NSString stringWithFormat:@"%@/%@", resourcePath, stringResource];
    UIImage* bgImage = [UIImage imageWithContentsOfFile:imagePath];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    [StoreNetworkConnectionView startAnimation:self.view];
    
    self.title = STRING_DATA_CENTER;
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem* box = [[UIBarButtonItem alloc] initWithTitle:STRING_LIBS style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = box;
    [box release];
    
    NSString* urlstr = STRING_STORE_URL_ADDRESS;
    if (self.storeURL != nil) {
        urlstr = self.storeURL;
    }
    NSURL* url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"voice" forHTTPHeaderField:@"User-Agent"];
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = @"voicexml";
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(fetcher:finishedWithData:error:)];


    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UIImage* bk = IS_IPAD ? [UIImage imageNamed:@"4-light-menu-barPad_P.png"] :[UIImage imageNamed:@"4-light-menu-bar.png"];
        if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
            [self.navigationController.navigationBar setBackgroundImage:bk forBarMetrics:UIBarMetricsDefault];
        }
    }
    self.navigationController.navigationBar .tintColor = [UIColor grayColor];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = STRING_DATA_CENTER;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Arial" size:22];
    self.navigationController.navigationBar .topItem.titleView = titleLabel;
    [titleLabel release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)back
{
    [self dismissModalViewControllerAnimated:YES];
   /*
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition: trans forView:self.view cache: NO];
    [self dismissModalViewControllerAnimated:NO];
    [UIView commitAnimations];*/
}

- (void)finishVoiceXMLData:(NSData*)data
{
    [StoreNetworkConnectionView removeConnectionView:self.view];
    NSString* xmlPath =  [NSString stringWithFormat:@"%@voice.xml", NSTemporaryDirectory()];
    [data writeToFile:xmlPath atomically:YES];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentDirectory = [Globle getPkgPath];
    
    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%d", lib.currentLibID];
    if (![fm fileExistsAtPath:documentDirectory isDirectory:nil])
        [fm createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString* devicePath = [documentDirectory stringByAppendingFormat:@"/%@", @"ServerRequest.dat"];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%@", @"voice.xml"];
    [fm copyItemAtPath:xmlPath toPath:documentDirectory error:nil];
    
    StoreVoiceDataListParser * dataParser = [[StoreVoiceDataListParser alloc] init];
    dataParser.libID = lib.currentLibID;
    [dataParser loadWithData:data];
    if ([dataParser.pkgsArray count] > 0) {
        StoreRootViewController* rootViewController = [[StoreRootViewController alloc] init];
        rootViewController.pkgArray = dataParser.pkgsArray;
        rootViewController.delegate = (id)self;
        CGRect rc = self.view.frame;
        rootViewController.view.frame = CGRectMake(0, 0, rc.size.width, rc.size.height);
        rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:rootViewController.view];
    }
    
    DownloadLicense* download = [[[DownloadLicense alloc] init] autorelease];
    download.libID = lib.currentLibID;

    if (![fm fileExistsAtPath:devicePath isDirectory:nil]) {
        if ([dataParser.serverlistArray count] > 0) {
            [download checkLisence:[dataParser.serverlistArray objectAtIndex:0]];
        }
    }
    [dataParser release];
    
    UIView* shadowView = [self.view viewWithTag:101];
    [self.view bringSubviewToFront:shadowView];

}


- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
 	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    V_NSLog(@"fecther : %@", [fecther description]);
    V_NSLog(@"error : %@", [error description]);
    if (error != nil) {
        [StoreNetworkConnectionView stopAnimation:STRING_LOADINGDATA_ERROR withSuperView:self.view];
        
    } else {
        if ([fecther.userData isEqualToString:@"voicexml"]) {
            [self finishVoiceXMLData:data];
        }
    }
}

- (void)dealloc
{
    [StoreNetworkConnectionView removeConnectionView:self.view];
    [super dealloc];
}

- (void)pushViewController:(UIViewController*)detail;
{
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)backToShelf:(DownloadDataPkgInfo*)info;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_PKG object:info.title];
    
   [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    /*
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition: trans forView:self.view cache: NO];
    [self dismissModalViewControllerAnimated:NO];
    [UIView commitAnimations];*/
}

@end
