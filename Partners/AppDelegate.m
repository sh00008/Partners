//
//  AppDelegate.m
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "AppDelegate.h"
#import "PartnerIAPHelper.h"
#import "ViewController.h"
#import "MainViewController.h"
#import "Globle.h"

#define IS_IPAD	([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [_mainViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;*/
    
    _mainViewController = [[MainViewController alloc] init];
    _mainViewController.view.frame = CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height);
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:_mainViewController];
    // set navigation bar backgroundImage
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UIImage* bk = IS_IPAD ? [UIImage imageNamed:@"4-light-menu-barPad_P.png"] :[UIImage imageNamed:@"4-light-menu-bar.png"];
        if([nav.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
            [nav.navigationBar setBackgroundImage:bk forBarMetrics:UIBarMetricsDefault];
        }
    }
    nav.navigationBar.tintColor = [UIColor grayColor];
    
    self.window.rootViewController = nav;
    nav.view.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // 创建IAP辅助类
    [PartnerIAPHelper sharedInstance];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
