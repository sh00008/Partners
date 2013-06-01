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

@interface FavorViewController ()

@end

@implementation FavorViewController
@synthesize tableView;

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
    NSInteger index = indexPath.row;
    NSInteger nHeight = 44.0f;

    if (index < [_pkgArray count]) {
        VoiceDataPkgObject* pkgObject = [_pkgArray objectAtIndex:index];
        NSInteger nMod = [pkgObject.dataPkgCourseTitleArray count] % 3;
        if (nMod == 0) {
            NSInteger nCount = [pkgObject.dataPkgCourseTitleArray count] / 3;
            nHeight = 44.0 + nCount * MAIN_COURSE_GRID_H + (nCount - 1) * 1;
        } else {
            NSInteger nCount = ([pkgObject.dataPkgCourseTitleArray count] / 3 + 1);
            nHeight = 44.0 + nCount * MAIN_COURSE_GRID_H + (nCount - 1) * 1;
           
        }
    }
    return nHeight;
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
    NSInteger dx = 0;
    NSInteger dy = 0;
    NSInteger w = MAIN_COURSE_GRID_W;
    NSInteger h = MAIN_COURSE_GRID_H;
    NSInteger r = 1;
	for (NSInteger i = 0; i < [pkgObject.dataPkgCourseTitleArray count]; i++) {
        UIButton* bt = [[UIButton alloc] initWithFrame:CGRectMake(dx, dy, w, h)];
        [bt setFont:[UIFont systemFontOfSize:12]];
        [bt setBackgroundColor:[UIColor colorWithRed:66.0/255.0 green:168.0/255.0 blue:250.0/255.0 alpha:1.0]];// forState:UIControlStateNormal];
        NSString* courseTitle = [pkgObject.dataPkgCourseTitleArray objectAtIndex:i];
        [bt setTitle:courseTitle forState:UIControlStateNormal];
        //[bt setBackgroundColor:[UIColor redColor]];
        [cell.pkgCourseBGView addSubview:bt];
        if ((i >= 2) && (r * (i + 1)) % 3 == 0 ) {
            // next row
            r++;
            dy = h + 1;
            dx = 0;
        } else {
            dx += w + 1;
            dy = 0;
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    // Configure the cell...
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

- (void)checkPkgfromFolder;
{
    NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	if (![fm fileExistsAtPath:documentDirectory isDirectory:nil])
		[fm createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%@", STRING_VOICE_PKG_DIR];
    
    // create pkg
    if (![fm fileExistsAtPath:documentDirectory isDirectory:nil])
        [fm createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:documentDirectory];
    [dirEnum skipDescendants];
    NSString* file = [dirEnum nextObject];
    while (file) {
        V_NSLog(@"%@", file);
        NSRange range = [file rangeOfString:@"/" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            file = [dirEnum nextObject];
            continue;
        }
        
        if ([[file pathExtension] length] == 0) {
            if (_pkgArray == nil) {
                _pkgArray = [[NSMutableArray alloc] init];
            }
            VoiceDataPkgObject* pkg = [[VoiceDataPkgObject alloc] init];
            pkg.dataPath = [NSString stringWithFormat:@"%@/%@",documentDirectory, file];
            pkg.dataTitle = file;
            [_pkgArray addObject:pkg];
            [pkg release];
        }
        file = [dirEnum nextObject];
    }
    
    [array release];
    
}

- (void)openSences:(id)sender
{
    
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

- (void)deletePkg:(id)cell;
{
    /*NSInteger index = cell.index;
    _deleteObject = [_pkgArray objectAtIndex:index];
    NSString *message = [NSString stringWithFormat:STRING_DELETEBOOK_ALERT_MESSAGE, _deleteObject.dataTitle];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_DELETEBOOK_ALERT_TITLE
													message:message
												   delegate:self
										  cancelButtonTitle:STRING_DELETEBOOK_BUTTON_CONFIRM otherButtonTitles:STRING_DELETEBOOK_BUTTON_CANCEL, nil];
	[alert show];
	[alert release];*/
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        // confirm
        Database* db = [Database sharedDatabase];
        VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByTitle:_deleteObject.dataTitle];
        if (info != nil) {
            NSFileManager* fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:info.dataPath error:nil];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *docsDir = [paths objectAtIndex:0];
            NSString *waveDir = [NSString stringWithFormat:@"%@/%@/%@", docsDir, STRING_VOICE_PKG_DIR,_deleteObject.dataTitle];
            if ([fm fileExistsAtPath:waveDir]) {
                [fm removeItemAtPath:waveDir error:nil];
            }
            
        }
        
        [db deleteVoicePkgInfoByTitle:_deleteObject.dataTitle];
        [self reloadPkgTable];
    } else {
        // cancel
        _bEdit = NO;
 		[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_EDIT_VOICE_PKG object: [NSNumber numberWithBool:NO]];
    }
    _deleteObject = nil;
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
