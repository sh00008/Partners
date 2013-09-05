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
#import "PartnerIAPHelper.h"
#import "GTMHTTPFetcher.h"
#import "StoreVoiceDataListParser.h"
#import "BuyButton.h"
#import "Globle.h"
#import "PartnerIAPProcess.h"

@interface PersonalMainViewController ()
{
    YIPopupTextView* _popAddLibView;
    BuyButton* _buyButton;
    UITableViewCell *_productCell;
}

@end

@implementation PersonalMainViewController

@synthesize _products;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self loadProducts];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _edit = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSString* resourcePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Image"]];
    UIImage* bkimage = [[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/background_gray.png", resourcePath]] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bkimage];
    [resourcePath release];
    [self performSelector:@selector(setControllerTitle) withObject:nil afterDelay:0.5];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _isCloseAddLibView = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iapStatusChanged:) name:NOTIFICATION_IAPSTATUS_CHANGED object:nil];
}

- (void)iapStatusChanged:(NSNotification *)notification {
    NSNumber* status = notification.object;// (SKPaymentTransaction *)transaction
    if (status == nil) {
        return;
    }
    [self setCurrentBuyButonStatus:[status intValue]];
}

- (void)setCurrentBuyButonStatus:(IAP_STATUS)s
{
    PartnerIAPProcess* iapProcess = [PartnerIAPProcess sharedInstance];
    switch (s) {
        case IAP_STATUS_NONE:
            [_buyButton start];           
            break;
        case IAP_STATUS_CHECKING_NETWORK:
            [_buyButton start];
            break;
        case IAP_STATUS_NETWORK_FAILED:
            [_buyButton showText:STRING_RETRY forBlue:YES];
            break;
        case IAP_STATUS_REQUESTING_IAP:
            [_buyButton start];
            break;
        case IAP_STATUS_REQUEST_IAP_FAILED:
            [_buyButton showText:STRING_RETRY forBlue:YES];
            break;
        case IAP_STATUS_NO_PRODUCT:
            break;
        case IAP_STATUS_READY_TO_BUY:
            [_buyButton showText:[iapProcess getPriceString] forBlue:YES];
            break;
        case IAP_STATUS_BUYING_PRODUCT:
            [_buyButton showText:STRING_ON_BUYING forBlue:YES];
            break;
        case IAP_STATUS_ALREADY_BUYED:
            _productCell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        case IAP_STATUS_BUYED_FAILED:
            [_buyButton showText:[iapProcess getPriceString] forBlue:YES];
            
        default:
            break;
    }
}

- (void)restoreTapped:(id)sender {
    PartnerIAPProcess* iapProcess = [PartnerIAPProcess sharedInstance];
    [iapProcess doRestore];
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
    titleLabel.font = [UIFont fontWithName:@"Arial" size:22];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    return ([_dataArray count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LibCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSInteger nRow = indexPath.row;

    LibaryInfo* object = nil;
    if (nRow < [_dataArray count]) {
        object = [_dataArray objectAtIndex:indexPath.row];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier] autorelease];
        cell.textLabel.text = object.title == nil ? STRING_PROMPT_NOTITLE : object.title;
        cell.tag = object.libID;
    } else if (nRow == [_dataArray count]) {
        
        /*cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] autorelease];
        cell.textLabel.text = STRING_ADD_NEW_LIB;
        BuyButton *restore = [[BuyButton alloc] initWithFrame:CGRectMake(0, 0, 72, 37)];
        [restore showText:@"Restore" forBlue:NO];
        [restore addTarget:self action:@selector(restoreTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = restore;*/
    }
    UACellBackgroundView* b = [[UACellBackgroundView alloc] initWithFrame:cell.frame];
      cell.backgroundView = b;
    
    [b release];

    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
     [cell.textLabel setFont:[UIFont fontWithName:@"KaiTi" size:22]];
    cell.imageView.image = [UIImage imageNamed:@"add"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (object && [object.url isEqualToString:STRING_STORE_URL_ADDRESS]) {
        _productCell = cell;
        [_productCell retain];
         BuyButton *buyButton = [[BuyButton alloc] initWithFrame:CGRectMake(0, 0, 72, 37)];
        [buyButton start];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
        _buyButton = buyButton;
        [_buyButton retain];
         PartnerIAPProcess* iapProcess = [PartnerIAPProcess sharedInstance];
        [self setCurrentBuyButonStatus:iapProcess.status];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 100.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    
    CGSize buttonSize = CGSizeMake(76, 37);
    CGFloat disBetweenButton = 20;
    CGFloat yOffset = 25;
    
    BuyButton *addNewLib = [[BuyButton alloc] initWithFrame:CGRectMake(self.view.center.x - buttonSize.width - disBetweenButton, yOffset, buttonSize.width, buttonSize.height)];
    [addNewLib showText:STRING_ADD_NEW_LIB forBlue:YES];
    [addNewLib addTarget:self action:@selector(addNewLib) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:addNewLib];
    [addNewLib release];
    BuyButton *restore = [[BuyButton alloc] initWithFrame:CGRectMake(self.view.center.x + disBetweenButton, addNewLib.frame.origin.y, buttonSize.width, buttonSize.height)];
    [restore showText:STRING_RESTORE forBlue:NO];
    [restore addTarget:self action:@selector(restoreTapped:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:restore];
    [restore release];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (void)buyButtonTapped:(id)sender {
    
    BuyButton *buyButton = (BuyButton *)sender;
    if (buyButton.isLoading) {
        return;
    }
    PartnerIAPProcess* iapProcess = [PartnerIAPProcess sharedInstance];
    switch (iapProcess.status) {
        case IAP_STATUS_NONE:
        case IAP_STATUS_CHECKING_NETWORK:
            break;
        case IAP_STATUS_NETWORK_FAILED:
            [iapProcess start];
            break;
        case IAP_STATUS_REQUESTING_IAP:
            break;
        case IAP_STATUS_REQUEST_IAP_FAILED:
            [iapProcess start];
            break;
        case IAP_STATUS_NO_PRODUCT:
        case IAP_STATUS_READY_TO_BUY:
            [iapProcess doBuyProduct];
            break;
        case IAP_STATUS_BUYING_PRODUCT:
            break;
        case IAP_STATUS_ALREADY_BUYED:
            break;
        case IAP_STATUS_BUYED_FAILED:
            [iapProcess doBuyProduct];
            break;
        default:
            break;
    }
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
    _popAddLibView = popupTextView;
    _isCloseAddLibView = NO;
    
}

- (void)reloadInfo
{
    if (_dataArray != nil) {
        [_dataArray release];
        _dataArray = nil;
    }
    Database* db = [Database sharedDatabase];
    _dataArray = [db loadLibaryInfo];
    if ([_dataArray count] == 1) {
        [self setEditing:NO];
    }
    
    [self.tableView reloadData];
}

- (BOOL)isCanPerfomEdit
{
    return ([_dataArray count] != 1);
}

- (void)loadProducts {
    PartnerIAPProcess* iapProcess = [PartnerIAPProcess sharedInstance];
    if (iapProcess != nil) {
        [iapProcess start];
    }
}

#pragma mark YIPopupTextViewDelegate

- (void)popupTextView:(YIPopupTextView *)textView willDismissWithText:(NSString *)text
{
    if (textView.bCanceled) {
        return;
    }
    
    if (text.length > 1) {
        
         /*Database* db = [Database sharedDatabase];
        LibaryInfo* info = [[LibaryInfo alloc] init];
        info.url = STRING_STORE_URL_ADDRESS;
        [db insertLibaryInfo:info];
        [info release];
        [self reloadInfo];*/
    }
}

- (void)confirmText:(YIPopupTextView*)textView didDismissWithText:(NSString*)text;
{
    Database* db = [Database sharedDatabase];
    LibaryInfo* libInfo = [db getLibaryInfoByURL:text];
    if (libInfo != nil) {
        [self addWaitingView:132 withText:STRING_ADDLIB_ADDRESS_AREADYADDED withAnimation:YES];
        [self performSelector:@selector(removeWatingView:) withObject:[NSNumber numberWithInt:132] afterDelay:2];
    } else {
        // correct url: add index_ios.xml
        NSString* newURL = text;
        NSRange r = [text rangeOfString:@".xml" options:NSBackwardsSearch];
        if (r.location == NSNotFound) {
            newURL = [NSString stringWithFormat:@"%@/index_ios.xml", text];
        }
        
        // add new lib address.
        
        Database* db = [Database sharedDatabase];
        LibaryInfo* info = [[LibaryInfo alloc] init];
        info.url = newURL;
        info.title = [NSString stringWithFormat:@"%@:%@)", STRING_LIB_NEW_NAME, newURL] ;
        [db insertLibaryInfo:info];
 
        [self addWaitingView:140 withText:STRING_ADDLIB_ADDRESS_ADDED withAnimation:YES];
        [self performSelector:@selector(removeWatingView:) withObject:[NSNumber numberWithInt:140] afterDelay:2];
        [_popAddLibView performSelector:@selector(dismiss) withObject:nil afterDelay:2.1];
        [self reloadInfo];
       
        /*NSURL* url = [NSURL URLWithString:newURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:@"checkLib" forHTTPHeaderField:@"User-Agent"];
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        [fetcher setUserData:text];
        [fetcher beginFetchWithDelegate:self
                      didFinishSelector:@selector(fetcher:finishedWithData:error:)]; */      
    }
 }

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text
{
    NSLog(@"didDismissWithText");
    _popAddLibView = nil;
}

- (BOOL)canDismiss;
{
    return _isCloseAddLibView;
}

- (void)edit
{
    _edit = !_edit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row < [_dataArray count]) {
            LibaryInfo* object = [_dataArray objectAtIndex:indexPath.row];
            Database* db = [Database sharedDatabase];
            [db deleteLibaryInfo:object.libID];
            [_dataArray release];
            _dataArray = [db loadLibaryInfo];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if ([_dataArray count] == 1) {
                [self setEditing:NO];
            }
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row < [_dataArray count]) && indexPath.row != 0) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if ((indexPath.row < [_dataArray count]) && indexPath.row != 0) {
        return YES;
    }
    return NO;
}

- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
    if (error != nil) {
        [self addWaitingView:120 withText:STRING_ADDLIB_ADDRESS_ERROR withAnimation:YES];
        [self performSelector:@selector(removeWatingView:) withObject:[NSNumber numberWithInt:120] afterDelay:2];
    } else {
        // insert libaryinfo
        Database* db = [Database sharedDatabase];
        LibaryInfo* info = [[LibaryInfo alloc] init];
        info.url = (NSString*)[fecther userData];
        [db insertLibaryInfo:info];
        
        // update currentlibid
        CurrentInfo* current = [CurrentInfo sharedCurrentInfo];
        current.currentLibID = info.libID;
        DownloadLicense* download = [[[DownloadLicense alloc] init] autorelease];
        download.libID = info.libID;
        download.delegate = (id)self;
        // parser xml data, and download lisecce
        [self finishVoiceXMLData:data withDownload:(DownloadLicense*)download];
        [info release];
    }
}

- (void)removeWatingView:(NSNumber*)tagNum {
    NSInteger tag = [tagNum integerValue];
    UIView* subView = [self.view viewWithTag:tag];
    if (subView != nil) {
        [subView removeFromSuperview];
    }
}

- (void)didDownload:(NSError*)error withDownloadLicense:(DownloadLicense*)download
{
    if (error == nil) {
        [self addWaitingView:130 withText:STRING_ADDLIB_ADDRESS_SUCCEED withAnimation:YES];
        [self performSelector:@selector(removeWatingView:) withObject:[NSNumber numberWithInt:130] afterDelay:2];
        [_popAddLibView performSelector:@selector(dismiss) withObject:nil afterDelay:2];
        [self reloadInfo];
    } else {
        Database* db = [Database sharedDatabase];
        [db deleteLibaryInfo:download.libID];
        [self addWaitingView:120 withText:STRING_ADDLIB_ADDRESS_ERROR withAnimation:YES];
        [self performSelector:@selector(removeWatingView:) withObject:[NSNumber numberWithInt:120] afterDelay:2];
     }
}

- (void)addWaitingView:(NSInteger)tag withText:(NSString*)text withAnimation:(BOOL)animated;
{
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 80)];
    loadingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    loadingView.layer.cornerRadius = 8;
    loadingView.tag = tag;
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    UIActivityIndicatorView* activeView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activeView.center = CGPointMake(loadingView.center.x, loadingView.center.y - 10) ;
    [loadingView addSubview:activeView];
    if (animated) {
        [activeView startAnimating];
    } else {
        [activeView stopAnimating];
    }
    [activeView release];
    
    CGRect rcLoadingText;
    if (animated) {
        rcLoadingText = CGRectMake(0, loadingView.frame.size.height - 30, loadingView.frame.size.width, 20);
    } else {
        rcLoadingText = CGRectMake(0, (loadingView.frame.size.height - 20) / 2, loadingView.frame.size.width, 20);
    }
    UILabel* loadingText = [[UILabel alloc] initWithFrame:rcLoadingText];
    loadingText.textColor = [UIColor whiteColor];
    loadingText.text = text;
    loadingText.font = [UIFont systemFontOfSize:14];
    loadingText.backgroundColor = [UIColor clearColor];
    loadingText.textAlignment  = NSTextAlignmentCenter;
    [loadingView addSubview:loadingText];
    [loadingText release];
    loadingView.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    [self.view addSubview:loadingView];
    [loadingView release];
    
}

- (void)finishVoiceXMLData:(NSData*)data withDownload:(DownloadLicense*)down
{
     NSString* xmlPath =  [NSString stringWithFormat:@"%@voice.xml", NSTemporaryDirectory()];
    [data writeToFile:xmlPath atomically:YES];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentDirectory = [Globle getPkgPath];
    
     documentDirectory = [documentDirectory stringByAppendingFormat:@"/%d", down.libID];
    if (![fm fileExistsAtPath:documentDirectory isDirectory:nil])
        [fm createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString* devicePath = [documentDirectory stringByAppendingFormat:@"/%@", @"ServerRequest.dat"];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%@", @"voice.xml"];
    [fm copyItemAtPath:xmlPath toPath:documentDirectory error:nil];
    if (![fm fileExistsAtPath:devicePath]) {
        StoreVoiceDataListParser * dataParser = [[StoreVoiceDataListParser alloc] init];
        dataParser.libID = down.libID;
        [dataParser loadWithData:data];
        
        if (![fm fileExistsAtPath:devicePath isDirectory:nil]) {
            if ([dataParser.serverlistArray count] > 0) {
                [down checkLisence:[dataParser.serverlistArray objectAtIndex:0]];
            }
        }
        [dataParser release];
    }
}

@end
