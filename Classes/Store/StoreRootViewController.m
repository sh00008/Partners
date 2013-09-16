//
//  StoreRootViewController.m
//  Sanger
//
//  Created by JiaLi on 12-9-19.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import "StoreRootViewController.h"
#import "StoreVoiceDataListParser.h"
#import "StorePkgTableViewCell.h"
#import "StorePkgDetailViewController.h"
#import "StoreDownloadPkg.h"
//#import "MobiSageSDK.h"
#import "ConfigData.h"
#import "StoreCourceTableViewCell.h"
#import "Globle.h"
@interface StoreRootViewController ()

@end

@implementation StoreRootViewController
@synthesize pkgArray;
@synthesize delegate;

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

    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* stringResource = @"bg_webview.png";
    NSString* imagePath = [NSString stringWithFormat:@"%@/%@", resourcePath, stringResource];
    UIImage* bgImage = [UIImage imageWithContentsOfFile:imagePath];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [pkgArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    /*if (indexPath.row == 0) {
        return 114.0f;
    }*/
    return 98.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0;
    /*ConfigData* configData = [ConfigData sharedConfigData];

    if (configData.bADStore) {
        return IS_IPAD ? 60 : 40;
    } else {
        return 0;
    }*/
 }

// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    return nil;
    /*
    ConfigData* configData = [ConfigData sharedConfigData];
   if (!configData.bADStore) {
       return nil;
    }
    
    StoreCourceTableViewCellBackground* header = [[StoreCourceTableViewCellBackground alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    header.bDark = YES;
    header.bSeperator = NO;
    MobiSageAdBanner * adBanner = [[MobiSageAdBanner alloc] initWithAdSize:IS_IPAD? Ad_748X60: Ad_320X40];
    adBanner.frame = CGRectMake((self.view.bounds.size.width - adBanner.frame.size.width)/2, 0, adBanner.frame.size.width, adBanner.frame.size.height);
    adBanner.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    //设置广告轮显方式
    [header addSubview:adBanner];
    [adBanner release];
    return [header autorelease];*/
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
   /* static NSString *adCellIdentifier = @"AdCell";
   if (indexPath.row == 0) {
       UITableViewCell *cell = (StorePkgTableViewCell*)[tableView dequeueReusableCellWithIdentifier:adCellIdentifier];

       if (!cell) {
           NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"StoreAdTableViewCell" owner:self options:NULL];
           if ([array count] > 0) {
               cell = [array objectAtIndex:0];
           }
        }
       return cell;
    }
    
    */
    UITableViewCell *cell = (StorePkgTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSInteger i = indexPath.row;// - 1;
    if (!cell) {
        if (i < [pkgArray count]) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"StorePkgTableViewCell" owner:self options:NULL];
            if ([array count] > 0) {
                cell = (StorePkgTableViewCell*)[array objectAtIndex:0];
                CustomBackgroundView* backView = [[CustomBackgroundView alloc] init];
                cell.backgroundView = backView;
                [backView release];
            }
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lastCell"] autorelease];
        }
    }
    if (i < [pkgArray count]) {
        DownloadDataPkgInfo* info = [pkgArray objectAtIndex:i];
        if ([cell isKindOfClass:[StorePkgTableViewCell class]]) {
            StorePkgTableViewCell* pkgCell = (StorePkgTableViewCell*)cell;
            [pkgCell setVoiceData:info];

        }
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    
    StorePkgDetailViewController *detailViewController = [[StorePkgDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    detailViewController.delegate = (id)self;
     // ...
    NSInteger i = indexPath.row;// - 1;
    if (i < [pkgArray count]) {
        DownloadDataPkgInfo* info = [pkgArray objectAtIndex:i];
        detailViewController.info = info;
    }
     // Pass the selected object to the new view controller.
    [self.delegate pushViewController:detailViewController];
    // [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     
}

- (void)doDownload:(DownloadDataPkgInfo*)info
{
    StoreDownloadPkg* downloadPkg = [[StoreDownloadPkg alloc] init];
    downloadPkg.info = info;
    [downloadPkg doDownload];
}

- (void)startLearning:(DownloadDataPkgInfo*)info;
{
    [self.delegate backToShelf:info];
}
@end
