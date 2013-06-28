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
@interface FavorViewController ()

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
    UITableView* v = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    [self.view addSubview:v];
    [v release];
    
    self.tableView = v;
    [v release];


    self.tableView.delegate = (id)self;
    self.tableView.dataSource = (id)self;
    [self loadPkgArray];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(addNewPKGNotification:) name:NOTIFICATION_ADD_VOICE_PKG object:nil];
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
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
        return nHeight + nSpace;

    } else {
        return 44.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger nCount = [_pkgArray count];
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        UIImageView* newCourse = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 154/2, 153/2)];
        UIImage* im = [UIImage imageNamed:@"NEW.png"];
        UIImage* newIm = [UIImage imageWithCGImage:im.CGImage scale:1.0 orientation:UIImageOrientationLeft];
        newCourse.image = newIm;
        [cell addSubview:newCourse];
        [newCourse release];

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
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
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

- (void)openSences:(id)sender
{
    
    FavorCourseButton* button = (FavorCourseButton*)sender;
    LessonsViewController* lessons = [[LessonsViewController alloc] initWithNibName:@"LessonsViewController" bundle:nil];
    lessons.dataPath = button.pkgPath;
    lessons.scenesName = button.pkgTitle;
    NSRange r = [button.pkgPath rangeOfString:STRING_VOICE_PKG_DIR];
    if (r.location != NSNotFound) {
        NSString* path = [button.pkgPath substringFromIndex:(r.location + r.length + 1)];
        CurrentLibrary* lib = [CurrentLibrary sharedCurrentLibrary];
        lib.dataPath = path;
        lib.dataTitle = button.pkgTitle;
       
    }
    NSLog(@"%@", button.pkgPath);
    NSLog(@"%@", button.pkgTitle);
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
    DMCustomModalViewController* modal = [[DMCustomModalViewController alloc]initWithRootViewController:navController
                                                       parentViewController:self];
    self.modal = modal;
    [self.modal setRootViewControllerHeight:self.view.bounds.size.height * 0.8];
    [self.modal setParentViewYPath:self.view.bounds.size.height * 0.2];
  
    [self.modal setDelegate:self];
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
        VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByTitle:_deleteTitle];
        if (info != nil) {
            NSFileManager* fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:info.dataPath error:nil];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *docsDir = [paths objectAtIndex:0];
            NSString *waveDir = [NSString stringWithFormat:@"%@/%@/%@", docsDir, STRING_VOICE_PKG_DIR, info.dataPath];
            if ([fm fileExistsAtPath:waveDir]) {
                [fm removeItemAtPath:waveDir error:nil];
            }
            
        }
        
        [db deleteVoicePkgInfoByTitle:_deleteTitle];
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



@end
