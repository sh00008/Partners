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

@interface StoreViewController ()

@end

@implementation StoreViewController

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
    

    // backgroundColor
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* stringResource = @"bg_webview.png";
    NSString* imagePath = [NSString stringWithFormat:@"%@/%@", resourcePath, stringResource];
    UIImage* bgImage = [UIImage imageWithContentsOfFile:imagePath];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    [StoreNetworkConnectionView startAnimation:self.view];

    self.title = STRING_DATA_CENTER;
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem* box = [[UIBarButtonItem alloc] initWithTitle:STRING_MY_DATA_CENTER style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = box;
    [box release];

    // shadowView
    UIView* shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 53 )];
    shadowView.tag = 101;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    NSString* shadowImageName = @"bookshelf_titlebar_shadow.png";
    NSString* shadowPath = [NSString stringWithFormat:@"%@/%@", resourcePath, shadowImageName];
    UIImage* shadowimage = [UIImage imageWithContentsOfFile:shadowPath];
    shadowView.backgroundColor = [UIColor colorWithPatternImage:shadowimage];
    shadowView.userInteractionEnabled = YES;
    //[self.view addSubview:shadowView];
    [shadowView release];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:VALUE_TITLEBAR_COLOR_R green:VALUE_TITLEBAR_COLOR_G blue:VALUE_TITLEBAR_COLOR_B alpha:1.0];

    
    NSURL* url = [NSURL URLWithString:STRING_STORE_URL_ADDRESS];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"MyApp" forHTTPHeaderField:@"User-Agent"];
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(fetcher:finishedWithData:error:)];

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
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition: trans forView:[self.view window] cache: NO];
    [self dismissModalViewControllerAnimated:NO];
    [UIView commitAnimations];
}


- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
 	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   V_NSLog(@"fecther : %@", [fecther description]);
    V_NSLog(@"error : %@", [error description]);
    if (error != nil) {
        [StoreNetworkConnectionView stopAnimation:STRING_LOADINGDATA_ERROR withSuperView:self.view];

    } else {
        
        [StoreNetworkConnectionView removeConnectionView:self.view];
        NSString* xmlPath =  [NSString stringWithFormat:@"%@voice.xml", NSTemporaryDirectory()];
        [data writeToFile:xmlPath atomically:YES];
        StoreVoiceDataListParser * dataParser = [[StoreVoiceDataListParser alloc] init];
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
        [dataParser release];
        
        UIView* shadowView = [self.view viewWithTag:101];
        [self.view bringSubviewToFront:shadowView];
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
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition: trans forView:[self.view window] cache: NO];
    [self dismissModalViewControllerAnimated:NO];
    [UIView commitAnimations];
}

@end
