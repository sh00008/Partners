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

@interface PersonalMainViewController ()
{
    YIPopupTextView* _popAddLibView;
    BuyButton* _buyButton;
    UITableViewCell *_productCell;
    BOOL _isContinueRequest;
    BOOL _isRequestSucceed;
}

@end

@implementation PersonalMainViewController

@synthesize _products;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _isContinueRequest = YES;
        _isRequestSucceed = NO;
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    _isCloseAddLibView = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedTransactionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productDone:) name:IAPHelperProductDoneTransactionNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:IAPHelperProductRequestFailedNotification object:nil];
}



- (void)restoreTapped:(id)sender {
    [[PartnerIAPHelper sharedInstance] restoreCompletedTransactions];
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
    _isContinueRequest = YES;
    [self reloadInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    _isContinueRequest = NO;
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}

- (void)productFailed:(NSNotification *)notification {
    [_buyButton showText:[self getPriceString] forBlue:YES];
}

- (void)productDone:(NSNotification *)notification {
    SKPaymentTransaction* transaction = notification.object;// (SKPaymentTransaction *)transaction
    if (transaction == nil) {
        return;
    }
    if ([[PartnerIAPHelper sharedInstance] productPurchased:transaction.payment.productIdentifier]) {
        if (_productCell != nil) {
            _productCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        [_buyButton removeFromSuperview];
        
    } else {
        [_buyButton showText:[self getPriceString] forBlue:YES];
    }
}

- (void)requestFailed:(NSNotification *)notification {
    _isContinueRequest = NO;
    [_buyButton showText:STRING_RETRY forBlue:YES];
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
    return ([_dataArray count] + 1);
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] autorelease];
        cell.textLabel.text = STRING_ADD_NEW_LIB;
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
        //[_buyButton showText:[self getPriceString] forBlue:YES];
        
        // 判断Store是否已经购买
        if ([[PartnerIAPHelper sharedInstance] productPurchased:STORE_UNLOCK_ID]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.accessoryView = nil;
        } else {
            if (_products == nil) {
                BuyButton *buyButton = [[BuyButton alloc] initWithFrame:CGRectMake(0, 0, 72, 37)];
                [buyButton start];
                buyButton.tag = indexPath.row;
                [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.accessoryView = buyButton;
                _buyButton = buyButton;
                if (_isRequestSucceed) {
                    [_buyButton showText:[self getPriceString] forBlue:YES];
                } else {
                    if (!_isContinueRequest) {
                        [_buyButton showText:STRING_RETRY forBlue:YES];
                    }
                }
            } else {
                if (cell.accessoryView != nil) {
                    [_buyButton showText:[self getPriceString] forBlue:YES];

                } else {
                    cell.accessoryView = _buyButton;
                }
            }
        }
    } 

    return cell;
}

- (NSString*)getPriceString
{
    SKProduct * product = (SKProduct *)_products[0];
    [_priceFormatter setLocale:product.priceLocale];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString* price = [_priceFormatter stringFromNumber:product.price];
    return price;
}

- (void)buyButtonTapped:(id)sender {
    
    BuyButton *buyButton = (BuyButton *)sender;
    if (buyButton.isLoading) {
        return;
    }
    
    if (!_isContinueRequest && !_isRequestSucceed) {
        _isContinueRequest = YES;
        [buyButton start];
        [self loadProducts];
        return;
    }
    if (_isRequestSucceed) {
        [buyButton showText:STRING_ON_BUYING forBlue:YES];
        SKProduct *product = _products[buyButton.tag];
        NSLog(@"Buying %@...", product.productIdentifier);
        [[PartnerIAPHelper sharedInstance] buyProduct:product];
        [buyButton start];
    }
    //[self reloadInfo];
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
    if (!_isContinueRequest) {
        return;
    }
    [[PartnerIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _isRequestSucceed = YES;
            self._products = products;
            SKProduct * product = (SKProduct *)_products[0];
            
//            [_buyButton showText:[self getPriceString] forBlue:YES];
            
            if ([[PartnerIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
                if (_productCell != nil) {
                    _productCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                [_buyButton removeFromSuperview];
                
            } else {
                [_buyButton showText:[self getPriceString] forBlue:YES];
            }
         } else {
            _isRequestSucceed = NO;
            [self loadProducts];
        }
        if ([self respondsToSelector:@selector(refreshControl)]) {
            [self.refreshControl endRefreshing];
        }
    }];
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
