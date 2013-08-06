//
//  FavorViewController.h
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoicePkgInfoObject.h"
#import "DMCustomModalViewController.h"
@interface FavorViewController : UIViewController
{
    VoiceDataPkgObject* _deleteObject;
    NSMutableArray* _pkgArray;
    BOOL _bEdit;
    NSString* _deleteTitle;
    NSInteger _deleteLibID;

}
@property (nonatomic, retain) DMCustomModalViewController *modal;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
- (void)loadPkgArray;
- (void)copyFreeSrc;
@end
