//
//  StorePkgDetailTableViewCell.m
//  Sanger
//
//  Created by JiaLi on 12-9-20.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import "StorePkgDetailTableViewCell.h"
#import "GTMHTTPFetcher.h"
#import "StoreDownloadPkg.h"
#import "CurrentInfo.h"
#import "Database.h"
#import "VoiceDef.h"
#import "PartnerIAPProcess.h"

@implementation DetailCustomBackgroundView
@synthesize bUpToDown;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
        bUpToDown = YES;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef graphicContext = UIGraphicsGetCurrentContext();
	CGColorSpaceRef colors_pace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0};
	
	
	colors_pace =  CGColorSpaceCreateDeviceRGB();;
	CGGradientRef gradientRef;
    if (bUpToDown) {
        CGFloat componentsupToDown[8] = {0.9, 0.9, 0.9, 1.0,
            VALUE_DETAIL_STORE_BACKGROUND_COLOR1_R, VALUE_DETAIL_STORE_BACKGROUND_COLOR1_G, VALUE_DETAIL_STORE_BACKGROUND_COLOR1_B, 1.0 };
       gradientRef = CGGradientCreateWithColorComponents (colors_pace, componentsupToDown,
                                               locations, num_locations);
    } else {
        CGFloat componentsDownToUp[8] = {
            VALUE_DETAIL_STORE_BACKGROUND_COLOR1_R, VALUE_DETAIL_STORE_BACKGROUND_COLOR1_G, VALUE_DETAIL_STORE_BACKGROUND_COLOR1_B, 1.0,  0.9, 0.9, 0.9, 1.0 };
        gradientRef = CGGradientCreateWithColorComponents (colors_pace, componentsDownToUp,
                                                           locations, num_locations);
        
    }
	
	CGPoint ptStart, ptEnd;
	ptStart.x = 0.0;
	ptStart.y = 0.0;
	ptEnd.x = 0.0;
	ptEnd.y = rect.size.height;
	CGContextDrawLinearGradient (graphicContext, gradientRef, ptStart, ptEnd, 0);
    CGColorSpaceRelease(colors_pace);
    
    CGFloat lineColor[] = {0.7, 0.7, 0.7, 1.0};
    CGContextSetStrokeColor(graphicContext, lineColor);
    CGContextSetLineWidth(graphicContext, 1);
    if (bUpToDown) {
        CGContextMoveToPoint(graphicContext, 0, 0);
        CGContextAddLineToPoint(graphicContext, rect.size.width, 0);
    } else {
        CGContextMoveToPoint(graphicContext, 0, rect.size.height);
        CGContextAddLineToPoint(graphicContext, rect.size.width, rect.size.height);
    }
    CGContextStrokePath(graphicContext);
 }
 
- (void)dealloc {
    [super dealloc];
}

@end
@interface StorePkgDetailTableViewCell()
{
    NSArray* _products;
}

@end

@implementation StorePkgDetailTableViewCell
@synthesize coverImageView, titleLabel, downloadButton;
@synthesize delegate;
@synthesize backToShelfButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setButtomImage
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(didDownloadedXML:) name:NOTIFICATION_DOWNLOADED_VOICE_PKGXML object:nil];
    [self.backToShelfButton showText:STRING_START_LEARNING forBlue:NO];
    
    if ([_info.url isEqualToString:STRING_STORE_URL_ADDRESS_BASE]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iapStatusChanged:) name:NOTIFICATION_IAPSTATUS_CHANGED object:nil];
        PartnerIAPProcess* iapProcess = [PartnerIAPProcess sharedInstance];
        [self setCurrentBuyButonStatus:iapProcess.status];
    } else {
        [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];       
    }
}

- (void)iapStatusChanged:(NSNotification *)notification {
    NSNumber* status = notification.object;// (SKPaymentTransaction *)transaction
    if (status == nil) {
        return;
    }
    [self setCurrentBuyButonStatus:[status intValue]];
}

- (void)setVoiceData:(DownloadDataPkgInfo*)info
{
    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    info.libID = lib.currentLibID;
    Database* db = [Database sharedDatabase];
    if ([db loadVoicePkgInfo:info] == nil) {
        [self.backToShelfButton setHidden:YES];
        [self.downloadButton setHidden:NO];
    } else {
        [self.backToShelfButton setHidden:NO];
        [self.downloadButton setHidden:YES];
    }
    
    _info = info;
    [self setButtomImage];

    self.titleLabel.text = info.title;
     if (info.receivedCoverImagePath == nil) {
        // download cover
        NSString* url = info.url;
        NSString* coverUrl = info.coverURL;
        if (coverUrl != nil && url != nil) {
            NSString* path = [NSString stringWithFormat:@"%@/%@", url, coverUrl];
            NSURL* url = [NSURL URLWithString:path];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setValue:@"cover" forHTTPHeaderField:@"User-Agent"];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            [fetcher beginFetchWithDelegate:self
                          didFinishSelector:@selector(fetcher:finishedWithData:error:)];
            
        }
        
    } else {
        UIImage* im = [UIImage imageWithContentsOfFile:info.receivedCoverImagePath];
        self.coverImageView.image = im;
    }
}

- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error != nil) {
        
    } else {
        if (_info != nil) {
            NSString* pngPath =  [NSString stringWithFormat:@"%@%d", NSTemporaryDirectory(),(arc4random())];
            [data writeToFile:pngPath atomically:YES];
            _info.receivedCoverImagePath = pngPath;
            UIImage* im = [UIImage imageWithData:data];
            self.coverImageView.image = im;
        }
    }
}

- (void) dealloc
{
    _info = nil;
    [super dealloc];
}

- (IBAction)clickButton:(id)sender
{
    if ([_info.url isEqualToString:STRING_STORE_URL_ADDRESS_BASE]) {
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
    } else {
        if ([[self.downloadButton titleForState:UIControlStateNormal] isEqual:STRING_DOWNLOAD]) {
            // begin download
            [self.downloadButton  setTitle:STRING_DOWNLOADING forState:UIControlStateNormal];
            self.downloadButton.enabled = NO;
            [self.delegate doDownload:_info];
        }
    
    }
}

- (void)setCurrentBuyButonStatus:(IAP_STATUS)s
{
    [self.backToShelfButton setHidden:YES];
    [self.downloadButton setHidden:NO];
    switch (s) {
        case IAP_STATUS_NONE:
            [self.downloadButton start];
            break;
        case IAP_STATUS_CHECKING_NETWORK:
            [self.downloadButton start];
            break;
        case IAP_STATUS_NETWORK_FAILED:
            [self.downloadButton showText:STRING_RETRY forBlue:YES];
            break;
        case IAP_STATUS_REQUESTING_IAP:
            [self.downloadButton start];
            break;
        case IAP_STATUS_REQUEST_IAP_FAILED:
            [self.downloadButton showText:STRING_RETRY forBlue:YES];
            break;
        case IAP_STATUS_NO_PRODUCT:
            break;
        case IAP_STATUS_READY_TO_BUY:
            [self.downloadButton showText:STRING_BUYING forBlue:YES];
            break;
        case IAP_STATUS_BUYING_PRODUCT:
            [self.downloadButton showText:STRING_ON_BUYING forBlue:YES];
            break;
        case IAP_STATUS_ALREADY_BUYED:
            [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];
            break;
        case IAP_STATUS_BUYED_FAILED:
            [self.downloadButton showText:STRING_BUYING forBlue:YES];
            
        default:
            break;
    }
}

- (IBAction)clickStartLearn:(id)sender;
{
    [self.delegate startLearning:_info];
}

- (void)didDownloadedXML:(NSNotification *)aNotification
{
	NSString *infoTitle = [aNotification object];
    if ([infoTitle isEqualToString:_info.title]) {
        [self.downloadButton setEnabled:NO];
        [self performSelector:@selector(delayShowBackToShelfButton) withObject:nil afterDelay:0.5];
    }
}

- (void)delayShowBackToShelfButton
{
    [self.downloadButton setHidden:YES];
    [self.backToShelfButton setHidden:NO];
}
@end
