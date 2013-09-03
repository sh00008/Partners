//
//  FavorViewController.m
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "FavorViewController.h"
#import "Database.h"
#import "FavorViewCell.h"
#import "VoiceDef.h"
#import "FavorCourseButton.h"
#import "CourseViewController.h"
#import "LessonsViewController.h"
#import "CurrentInfo.h"
#import "UIViewController+MJPopupViewController.h"
#import "DownloadWholeViewController.h"
#import "SettingData.h"
#import "Globle.h"

@interface FavorViewController ()
{
    DownloadWholeViewController* _downloadViewController;
}
@end

@implementation FavorViewController
@synthesize tableView;
@synthesize modal;
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
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0];
    UITableView* v = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44) style:UITableViewStylePlain];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:v];
    [v release];
    
    self.tableView = v;
    [v release];


    self.tableView.delegate = (id)self;
    self.tableView.dataSource = (id)self;
    SettingData* setting = [[SettingData alloc] init];
    [setting loadSettingData];
    if (setting.isNeedCopyFreeSrc) {
        [self copyFreeSrc];
    }
    [setting release];
    [self loadPkgArray];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(addNewPKGNotification:) name:NOTIFICATION_ADD_VOICE_PKG object:nil];
 	[center addObserver:self selector:@selector(closeLessonsNotification:) name:NOTIFICATION_CLOSE_LESSONS object:nil];
 }

- (void)closeLessonsNotification:(NSNotification*)aNotification;
{
    [self openFavor];
    //[self performSelector:@selector(openFavor) withObject:nil afterDelay:0.5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger nCount = [_pkgArray count];
    if (nCount == 0) {
        return 88.0f;
    }
    NSInteger nRow = indexPath.row;
    if (nRow < [_pkgArray count]) {
        VoiceDataPkgObject* pkgObject = [_pkgArray objectAtIndex:nRow];
        NSInteger nHeight = 44.0f;
        NSInteger nSpace = IS_IPAD ? 20 : 10;
        NSInteger count = IS_IPAD ? 5 : 3;
        NSInteger nTotalCount = [pkgObject.dataPkgCourseTitleArray count];
        NSInteger nMod = nTotalCount % count;
        NSInteger nQ = nTotalCount / count;
        NSInteger r = (nMod == 0) ? nQ : (nQ + 1);
        NSInteger h = (IS_IPAD ? MAIN_COURSE_GRID_H_IPAD : MAIN_COURSE_GRID_H);
        nHeight = h * r + r * 20 + 20;
        NSInteger offset = r == 1 ? 20 : 0;
        return nHeight + nSpace + offset ;

    } else {
        return 44.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger nCount = [_pkgArray count];
    if (nCount == 0 || nCount == 1) {
        return nCount + 1;
    }
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_pkgArray count]== 0) {
         
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.text = STRING_PROMPT_HOW_TO_ADD_RES;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont fontWithName:@"KaiTi" size:20];
        return [cell autorelease];
    }
    
    if (indexPath.row < [_pkgArray count]) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"FavorViewCell" owner:self options:nil];
        FavorViewCell *cell = [array objectAtIndex:0];
        
        // Configure the cell...
        
        while ([cell.pkgCourseBGView.subviews count] > 0) {
            UIView* subView = [[cell.pkgCourseBGView subviews] objectAtIndex:0];
            if (subView != nil) {
                [subView removeFromSuperview];
                subView = nil;
            }
        }
        NSInteger nRow = indexPath.row;
        
        VoiceDataPkgObject* pkgObject = [_pkgArray objectAtIndex:nRow];
        cell.pkgTitle.text = pkgObject.dataTitle;
        CGRect f = cell.pkgTitle.frame;
        NSInteger alignX = 40;
        //if (IS_IPAD) {
        cell.pkgTitle.frame = CGRectMake(alignX + f.origin.x, f.origin.y, f.size.width, f.size.height);
        /*} else {
         cell.pkgTitle.frame = CGRectMake(20 + f.origin.x, f.origin.y, f.size.width, f.size.height);
         
         }*/
        NSInteger fromX = IS_IPAD ? alignX : 0;
        NSInteger dx = fromX;
        NSInteger dy = 0;
        NSInteger w =  (IS_IPAD ? MAIN_COURSE_GRID_W_IPAD : MAIN_COURSE_GRID_W);
        NSInteger h =  (IS_IPAD ? MAIN_COURSE_GRID_H_IPAD : MAIN_COURSE_GRID_H);
        NSInteger seperator = IS_IPAD ? 10 : 1;
        NSInteger count = IS_IPAD ? 5 : 3;
        NSInteger r = 1;
        NSInteger c = 1;
        NSInteger libID = 0;
        NSRange range = [pkgObject.dataPath rangeOfString:STRING_VOICE_PKG_DIR];
        if (range.location != NSNotFound) {
            NSString* path = [pkgObject.dataPath substringFromIndex:(range.location + range.length + 1)];
            range = [path rangeOfString:@"/"];
            if (range.location != NSNotFound) {
                libID = [[path substringToIndex:(range.location + range.length)] intValue] ;;
                cell.tag = libID;
            }
            
        }
        for (NSInteger i = 0; i < [pkgObject.dataPkgCourseTitleArray count]; i++) {
            FavorCourseButton* bt = [[FavorCourseButton alloc] initWithFrame:CGRectMake(dx, dy, w, h)];
            NSString* courseTitle = [pkgObject.dataPkgCourseTitleArray objectAtIndex:i];
            bt.pkgPath = pkgObject.dataPath;
            bt.pkgTitle = courseTitle;
            [bt setCourseTitle:courseTitle];
            [cell.pkgCourseBGView addSubview:bt];
            [bt addTarget:self action:@selector(openSences:) forControlEvents:UIControlEventTouchUpInside];
            [bt release];
            if (c % count == 0) {
                // next row
                r++;
                dy = h * (r - 1) + r * seperator;
                dx = fromX;
                c = 1;
            } else {
                c++;
                dx += w + seperator ;
            }
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //if (IS_IPAD) {
        BOOL bListened = [[Database sharedDatabase] getPkgIsListened:pkgObject.dataTitle withLibID:libID];
        if (!bListened) {
            UIImageView* newCourse = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 154/2, 153/2)];
            UIImage* im = [UIImage imageNamed:@"NEW.png"];
            UIImage* newIm = [UIImage imageWithCGImage:im.CGImage scale:1.0 orientation:UIImageOrientationLeft];
            newCourse.image = newIm;
            [cell addSubview:newCourse];
            [newCourse release];
        } else {
            cell.pkgTitle.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, f.size.height);

        }
        
        /*} else {
         UIImageView* newCourse = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width - 154/2, 0, 154/2, 153/2)];
         newCourse.image = [UIImage imageNamed:@"Icon_New_L@2x.png"];
         [cell addSubview:newCourse];
         [newCourse release];
         
         }*/
        // Configure the cell...
        [cell.deletePkg addTarget:self action:@selector(deletePkg:) forControlEvents:UIControlEventTouchUpInside];
        return cell;

    }
   
    if ([_pkgArray count]== 1 && indexPath.row == 1) {
        
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.text = STRING_PROMPT_HOW_TO_ADD_RES;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont fontWithName:@"KaiTi" size:20];
        return [cell autorelease];
    }
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return [cell autorelease];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <DetailViewController> *detailViewController = [[<DetailViewController> alloc] initWithNibName:@"<Nib name>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


- (void)loadPkgArray
{
    Database* db = [Database sharedDatabase];
    _pkgArray = [db loadVoicePkgInfo];
}

- (void)copyFreeSrc {
    Database* db = [Database sharedDatabase];
    NSInteger libID = [db getLibaryIDByURL:STRING_HIDDEN_LIB_NAME];
    if (libID == -1) {
        return;
    }
    
   NSString* resourcePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Data"]];
    NSFileManager *fM = [NSFileManager defaultManager];
    NSArray *fileList = [[fM contentsOfDirectoryAtPath:resourcePath error:nil] retain];
    for(NSString *file in fileList) {
        NSString *path = [resourcePath stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        [fM fileExistsAtPath:path isDirectory:(&isDir)];
        if(isDir) {
            NSString* lisencePath = [path stringByAppendingPathComponent:@"ServerRequest.dat"];
            NSString *documentDirectory = [Globle getPkgPath];
            
            NSString* absolutePath = [NSString stringWithFormat:@"%@/%d", documentDirectory, libID];
            if (![fM fileExistsAtPath:absolutePath]) {
                [fM createDirectoryAtPath:absolutePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            // copy liscense;
            NSString* newLiscensePath = [absolutePath stringByAppendingPathComponent:@"ServerRequest.dat"];
            [fM copyItemAtPath:lisencePath toPath:newLiscensePath error:nil];
            DownloadLicense* download = [[DownloadLicense alloc] init];
            download.libID = libID;
            [download getDeviceID];
            [download release];
            
            // copy data
            NSString* newPath = [absolutePath stringByAppendingPathComponent:file] ;
            [fM copyItemAtPath:path toPath:newPath error:nil];

            NSString* wrongLisencePath = [newPath stringByAppendingPathComponent:@"ServerRequest.dat"];
            [fM removeItemAtPath:wrongLisencePath error:nil];
            
            DownloadDataPkgInfo* pkgInfo = [[DownloadDataPkgInfo alloc] init];
            NSMutableArray* dataPkgCourseInfoArray = [[NSMutableArray alloc] init];
            pkgInfo.dataPkgCourseInfoArray = dataPkgCourseInfoArray;
            [dataPkgCourseInfoArray release];
            pkgInfo.title = file;
            pkgInfo.libID = libID;
            NSArray* courseList = [fM contentsOfDirectoryAtPath:path error:nil];
            for (NSString* courseTitle in courseList) {
                BOOL isDirCourse = NO;
                NSString *coursepath = [path stringByAppendingPathComponent:courseTitle];
                [fM fileExistsAtPath:coursepath isDirectory:(&isDirCourse)];
               if (isDirCourse) {
                   DownloadDataPkgCourseInfo* courseInfo = [[DownloadDataPkgCourseInfo alloc] init];
                   courseInfo.title = courseTitle;
                   [pkgInfo.dataPkgCourseInfoArray addObject:courseInfo];
                   [courseInfo release];
                }
            }
            [db insertVoicePkgInfo:pkgInfo];
            [db updateDownloadedInfo:pkgInfo.title withPath:[NSString stringWithFormat:@"%d/%@", libID, pkgInfo.title]];
        }
    }
    
 
}
- (void)openSences:(id)sender
{
    FavorCourseButton* button = (FavorCourseButton*)sender;
    LessonsViewController* lessons = [[LessonsViewController alloc] initWithNibName:@"LessonsViewController" bundle:nil];
    lessons.dataPath = button.pkgPath;
    lessons.scenesName = button.pkgTitle;
    NSRange r = [button.pkgPath rangeOfString:STRING_VOICE_PKG_DIR];
    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    if (r.location != NSNotFound) {
        NSString* path = [button.pkgPath substringFromIndex:(r.location + r.length + 1)];
        lib.currentPkgDataPath = path;
        lib.currentPkgDataTitle = button.pkgTitle;
        r = [path rangeOfString:@"/"];
        if (r.location != NSNotFound) {
            lib.currentLibID = [[path substringToIndex:r.location] intValue];
        }
    }
     lessons.scenesName = button.pkgTitle;
    NSRange range = [button.pkgPath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        
  		NSInteger nSubFromIndex = range.location + range.length;
		if (nSubFromIndex < button.pkgPath.length) {
			lessons.pkgName = [button.pkgPath substringFromIndex:nSubFromIndex];
		}
    }
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:lessons];
     navController.navigationBar.hidden = YES;
    self.modal = [[DMCustomModalViewController alloc]initWithRootViewController:navController
                                                       parentViewController:self];
   
    // do sth;
    // expired
   CourseParser* courseParser = [[CourseParser alloc] init];
    
    NSString* resourcePath;
    if (lessons.scenesName != nil) {
        resourcePath = [NSString stringWithFormat:@"/%@/%@",  button.pkgPath, lessons.scenesName];
    }
    NSString* indexString = STRING_LESSONS_INDEX_XML;
    courseParser.resourcePath = resourcePath;
    BOOL isExpired = [courseParser isExpired:indexString];
    if (isExpired) {
        DownloadWholeViewController* renewViewController = [[DownloadWholeViewController alloc] initWithNibName:@"DownloadWholeViewController" bundle:nil];
        renewViewController.eViewType = POPVIEW_TYPE_BORROW;
        renewViewController.dataPath = button.pkgPath;
        renewViewController.scenesName = button.pkgTitle;
        renewViewController.delegate = (id)self;
        [self presentPopupViewController:renewViewController animationType:MJPopupViewAnimationSlideBottomTop];
        
    } else {
        // all
        Database* db = [Database sharedDatabase];
        if ([db isPkgDownloaded:lib.currentPkgDataTitle withPath:lib.currentPkgDataPath]) {
            [self openFavor];
        } else {
            _downloadViewController = [[DownloadWholeViewController alloc] initWithNibName:@"DownloadWholeViewController" bundle:nil];
            _downloadViewController.dataPath = button.pkgPath;
            _downloadViewController.scenesName = button.pkgTitle;
            _downloadViewController.delegate = (id)self;
            [self presentPopupViewController:_downloadViewController animationType:MJPopupViewAnimationFade];
        }       
    }
 }

- (void)openFavor
{
    self.modal.animationSpeed = 0.2;
    [self.modal setRootViewControllerHeight:self.view.bounds.size.height * 0.8];
    [self.modal setParentViewYPath:self.view.bounds.size.height * 0.2];
    
    [self.modal setDelegate:(id<DMCustomViewControllerDelegate>)self];
    [self.modal presentRootViewControllerWithPresentationStyle:DMCustomModalViewControllerPresentPartScreen
                                          controllercompletion:^{
                                              
                                          }];

}
- (void)reloadPkgTable;
{
     if (_pkgArray != nil) {
        [_pkgArray release];
        _pkgArray = nil;
        Database* db = [Database sharedDatabase];
        _pkgArray = [db loadVoicePkgInfo];
    }
    [self.tableView reloadData];
}

- (void)singleTapped:(UITapGestureRecognizer*)recognizer
{
   /* if (!_bEdit) {
        VoicePkgShelfCell* cell = (VoicePkgShelfCell*)recognizer.view;
        [self openSences:cell];
    } else {
        VoicePkgShelfCell* cell = (VoicePkgShelfCell*)recognizer.view;
        [self deletePkg:cell];
    }*/
}

- (void)singleTappedBackground:(UITapGestureRecognizer*)recognizer
{
    if (_bEdit) {
        _bEdit = NO;
 		[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_EDIT_VOICE_PKG object: [NSNumber numberWithBool:NO]];
    }
}

- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    // VoicePkgShelfCell* cell = (VoicePkgShelfCell*)recognizer.view;
    if (!_bEdit) {
        _bEdit = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_EDIT_VOICE_PKG object: [NSNumber numberWithBool:YES]];
    }
}

- (void)deletePkg:(id)sender;
{
    UIButton* b = (UIButton*)sender;
    FavorViewCell *cell = (FavorViewCell*)[[b superview] superview];
    _deleteTitle = cell.pkgTitle.text;
    _deleteLibID = cell.tag;
    [_deleteTitle retain];
    NSString *message = [NSString stringWithFormat:STRING_DELETEBOOK_ALERT_MESSAGE, _deleteTitle];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_DELETEBOOK_ALERT_TITLE
													message:message
												   delegate:self
										  cancelButtonTitle:STRING_DELETEBOOK_BUTTON_CONFIRM otherButtonTitles:STRING_DELETEBOOK_BUTTON_CANCEL, nil];
	[alert show];
	[alert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        // confirm
        Database* db = [Database sharedDatabase];
        VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByTitle:_deleteTitle withLibID:_deleteLibID];
        if (info != nil) {
            NSFileManager* fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:info.dataPath error:nil];
            

            NSString *docsDir = [Globle getMirrorPath];
            NSRange r = [info.dataPath rangeOfString:STRING_VOICE_PKG_DIR];
            if (r.location != NSNotFound) {
                NSString* dataPathTemp = [info.dataPath substringFromIndex:(r.location + r.length)];
                
                NSString *waveDir = [NSString stringWithFormat:@"%@%@", docsDir, dataPathTemp];
                if ([fm fileExistsAtPath:waveDir]) {
                    [fm removeItemAtPath:waveDir error:nil];
                }
            }
          
        }
        
        [db deleteVoicePkgInfoByTitle:_deleteTitle withLibID:_deleteLibID];
        [self reloadPkgTable];
    } else {
        // cancel
        _bEdit = NO;
 		[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_EDIT_VOICE_PKG object: [NSNumber numberWithBool:NO]];
    }
    _deleteTitle = nil;
}

- (void)addNewPKGNotification:(NSNotification*)aNotification;
{
    if (_pkgArray != nil) {
        [_pkgArray release];
        _pkgArray = nil;
        Database* db = [Database sharedDatabase];
        _pkgArray = [db loadVoicePkgInfo];
    }
    [self.tableView reloadData];
}


- (void)openCourseNotification:(NSNotification*)aNotification;
{
	NSString *title = [aNotification object];
    if (title == nil) {
        return;
    }
//    _willOpenCourseTitle = title;
//    [_willOpenCourseTitle retain];
}


- (void)delayOpenCourse;
{
    /*if (_willOpenCourseTitle != nil) {
        Database* db = [Database sharedDatabase];
        VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByTitle:_willOpenCourseTitle];
        if (info != nil) {
            ScenesCoverViewController * scenes = [[ScenesCoverViewController alloc] init];
            scenes.dataPath = info.dataPath;
            scenes.dataTitle = info.dataTitle;
            [self.delegate openVoiceData:scenes];
            [_willOpenCourseTitle release];
            _willOpenCourseTitle = nil;
        }
    }*/
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}

- (void)cancelButtonClicked:(DownloadWholeViewController*)secondDetailViewController;
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    _downloadViewController = nil;
    [self openFavor];
}

- (void)doneButtonClicked:(DownloadWholeViewController*)secondDetailViewController;
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    _downloadViewController = nil;
    [self openFavor];
}

- (void)dimissPopView:(DownloadWholeViewController*)secondDetailViewController;
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

@end
