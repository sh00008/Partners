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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSInteger section = indexPath.section;
    if (section == 0) {
        // library
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultLib"];
        }
    } else {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personalcell"];
        }
       
    }
    
    while ([cell.contentView.subviews count] > 0) {
        UIView* subView = [[cell.contentView subviews] objectAtIndex:0];
        if (subView != nil) {
            [subView removeFromSuperview];
            subView = nil;
        }
    }
    
    if (section != 0) {
        return cell;
    }
    
    cell.contentView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    CGRect f = cell.contentView.frame;
    NSInteger alignX = 40;
    //if (IS_IPAD) {
    cell.contentView.frame = CGRectMake(alignX + f.origin.x, f.origin.y, f.size.width, f.size.height);
    /*} else {
     cell.pkgTitle.frame = CGRectMake(20 + f.origin.x, f.origin.y, f.size.width, f.size.height);
     
     }*/
    NSInteger fromX = IS_IPAD ? alignX : 0;
    NSInteger dx = fromX;
    NSInteger yspace = 20;
    NSInteger dy = yspace;
    NSInteger w =  (IS_IPAD ? MAIN_COURSE_GRID_W_IPAD : MAIN_COURSE_GRID_W);
    NSInteger h =  (IS_IPAD ? MAIN_COURSE_GRID_H_IPAD : MAIN_COURSE_GRID_H);
    NSInteger seperator = IS_IPAD ? 10 : 1;
    NSInteger count = IS_IPAD ? 5 : 3;
    NSInteger r = 1;
    NSInteger c = 1;
    for (NSInteger libIndex = 0; libIndex < [_dataArray count]; libIndex++) {
        UIButton* bt = [[UIButton alloc] initWithFrame:CGRectMake(dx, dy, w, h)];
        [bt setContentMode:UIViewContentModeScaleToFill];
        [bt setImage:[UIImage imageNamed:@"library.png"] borderWidth:5.0 shadowDepth:10.0 controlPointXOffset:30.0 controlPointYOffset:70.0 forState:UIControlStateNormal];
        [bt setImage:[UIImage imageNamed:@"library.png"] borderWidth:5.0 shadowDepth:10.0 controlPointXOffset:30.0 controlPointYOffset:70.0 forState:UIControlStateHighlighted];
        
        bt.tag = libIndex;
        [bt addTarget:self action:@selector(openLib:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:bt];
        [bt release];
        // change 
        if (c % count == 0) {
            // next row
            r++;
            dy = h * (r - 1) + r * yspace;
            dx = fromX;
            c = 1;
        } else {
            c++;
            dx += w + seperator + yspace;
        }
    }
    UIButton* bt = [[UIButton alloc] initWithFrame:CGRectMake(dx, dy, w, h)];
    [bt setImage:nil borderWidth:5.0 shadowDepth:10.0 controlPointXOffset:30.0 controlPointYOffset:70.0 forState:UIControlStateNormal];
    [bt setImage:nil borderWidth:5.0 shadowDepth:10.0 controlPointXOffset:30.0 controlPointYOffset:70.0 forState:UIControlStateHighlighted];
    [bt setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(addNewLib) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:bt];
    [bt release];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    /*} else {
     UIImageView* newCourse = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width - 154/2, 0, 154/2, 153/2)];
     newCourse.image = [UIImage imageNamed:@"Icon_New_L@2x.png"];
     [cell addSubview:newCourse];
     [newCourse release];
     
     }*/
    // Configure the cell...
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        NSInteger nHeight = 44.0f;
        NSInteger nSpace = IS_IPAD ? 20 : 10;
        NSInteger count = IS_IPAD ? 5 : 3;
        NSInteger nTotalCount = [_dataArray count] + 1;
        NSInteger nMod = nTotalCount % count;
        NSInteger nQ = nTotalCount / count;
        NSInteger r = (nMod == 0) ? nQ : (nQ + 1);
        NSInteger h = (IS_IPAD ? MAIN_COURSE_GRID_H_IPAD : MAIN_COURSE_GRID_H);
        nHeight = h * r + r * 20;
        return nHeight + nSpace;
    } else {
        return 44;
    }
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

- (void)loadLibaryInfo;
{
    Database* db = [Database sharedDatabase];
    _dataArray = [db loadLibaryInfo];
}

- (void)openLib:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSInteger index = button.tag;
    if (index < [_dataArray count]) {
        LibaryInfo* pkgObject = [_dataArray objectAtIndex:index];
        StoreViewController* store = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
        store.storeURL = pkgObject.url;
        store.view.tag = pkgObject.libID;
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:store];
        
        UIViewAnimationTransition transition = UIViewAnimationTransitionFlipFromRight;
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:transition forView:[self.view window] cache: NO];
        [self presentModalViewController:nav animated:NO];
        [UIView commitAnimations];
        
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

@end
