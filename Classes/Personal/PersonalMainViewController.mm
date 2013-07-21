//
//  PersonalMainViewController.m
//  Partners
//
//  Created by JiaLi on 13-6-24.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "PersonalMainViewController.h"
#import "VoiceDef.h"
#import "VoicePkgInfoObject.h"
#import "Database.h"
#import "UIButton+Curled.h"
#import "YIPopupTextView.h"
#import "StoreViewController.h"
#import "ISaybEncrypt2.h"
#import "CurrentInfo.h"
#import "UACellBackgroundView.h"

@interface PersonalMainViewController ()

@end

@implementation PersonalMainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _edit = NO;
    [self performSelector:@selector(setControllerTitle) withObject:nil afterDelay:0.5];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)setControllerTitle
{
    [self loadLibaryInfo];
    [self.tableView reloadData];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = PERSONAL_INFO;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
   

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ([_dataArray count] + (IS_IPAD ? 17 : 7));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LibCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] autorelease];
        UACellBackgroundView* b = [[UACellBackgroundView alloc] initWithFrame:cell.frame];
        cell.backgroundView = b;
        [b release];
   }
    NSInteger nRow = indexPath.row;
    if (nRow < [_dataArray count]) {
        LibaryInfo* object = [_dataArray objectAtIndex:indexPath.row];
        cell.textLabel.text = object.title;
        cell.tag = object.libID;
    } else if (nRow == [_dataArray count]) {
        cell.textLabel.text = STRING_ADD_NEW_LIB;
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    [cell.textLabel setFont:[UIFont fontWithName:@"KaiTi" size:14]];
    cell.imageView.image = [UIImage imageNamed:@"add"];
   [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 58.0;
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
    if (indexPath.row < [_dataArray count]) {
        [self openLib:indexPath.row];
    } else if (indexPath.row == [_dataArray count]) {
        [self addNewLib];
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     ; *detailViewController = [[; alloc] initWithNibName:@";" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)loadLibaryInfo;
{
    Database* db = [Database sharedDatabase];
    _dataArray = [db loadLibaryInfo];
}

- (void)openLib:(NSInteger)index
{
      if (index < [_dataArray count]) {
        LibaryInfo* pkgObject = [_dataArray objectAtIndex:index];
        StoreViewController* store = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
        store.storeURL = pkgObject.url;
        store.view.tag = pkgObject.libID;
        CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
        if (lib != nil) {
            lib.currentLibID = pkgObject.libID;
        }
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:store];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_A_STORE object:nav];
        
         //CATransition *
        [store release];
        [nav release];
       
    }
}

- (void)addNewLib
{
    YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:STRING_ENTER_LIB_ADDRESS maxCount:300];
    popupTextView.delegate = (id)self;
    [popupTextView showInView:self.tableView];
    
}

- (void)reloadInfo
{
    if (_dataArray != nil) {
        [_dataArray release];
        _dataArray = nil;
    }
    Database* db = [Database sharedDatabase];
    _dataArray = [db loadLibaryInfo];
    [self.tableView reloadData];
}

#pragma mark YIPopupTextViewDelegate

- (void)popupTextView:(YIPopupTextView *)textView willDismissWithText:(NSString *)text
{
    if (text.length > 1) {
        Database* db = [Database sharedDatabase];
        LibaryInfo* info = [[LibaryInfo alloc] init];
        info.url = STRING_STORE_URL_ADDRESS;
        [db insertLibaryInfo:info];
        [info release];
        [self reloadInfo];
    }
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text
{
    NSLog(@"didDismissWithText");
}

- (void)edit
{
    _edit = !_edit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

{
    if (indexPath.row < [_dataArray count]) {
        LibaryInfo* object = [_dataArray objectAtIndex:indexPath.row];
        Database* db = [Database sharedDatabase];
        [db deleteLibaryInfo:object.libID];
        [_dataArray release];
        _dataArray = [db loadLibaryInfo];
        [self.tableView reloadData];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row < [_dataArray count]) && indexPath.row != 0) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

@end
