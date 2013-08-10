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
#import "PartnerIAPHelper.h"

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

- (void)productPurchased:(NSNotification *)notification { 
    if ([_info.url isEqualToString:STRING_STORE_URL_ADDRESS_BASE]) {
        if ([[PartnerIAPHelper sharedInstance] productPurchased:STORE_UNLOCK_ID]) {
            [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];
        } else {
            [self.downloadButton showText:STRING_BUYING forBlue:YES];
        }
    }
}

- (void)productFailed:(NSNotification *)notification {
    if ([_info.url isEqualToString:STRING_STORE_URL_ADDRESS_BASE]) {
        if ([[PartnerIAPHelper sharedInstance] productPurchased:STORE_UNLOCK_ID]) {
            [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];
        } else {
            [self.downloadButton showText:STRING_BUYING_FAILED forBlue:YES];
        }
    }
}

- (void)productDone:(NSNotification *)notification {
    if ([_info.url isEqualToString:STRING_STORE_URL_ADDRESS_BASE]) {
        if ([[PartnerIAPHelper sharedInstance] productPurchased:STORE_UNLOCK_ID]) {
            [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];
        } else {
            [self.downloadButton showText:STRING_BUYING_FAILED forBlue:YES];
        }
    }
}

- (void)requestFailed:(NSNotification *)notification {
    if ([_info.url isEqualToString:STRING_STORE_URL_ADDRESS_BASE]) {
        if ([[PartnerIAPHelper sharedInstance] productPurchased:STORE_UNLOCK_ID]) {
            [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];
        } else {
            [self.downloadButton showText:STRING_BUYING forBlue:YES];
        }
    }
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
    [self.downloadButton start];
    [self.backToShelfButton showText:STRING_START_LEARNING forBlue:NO];
    
    if ([_info.url isEqualToString:STRING_STORE_URL_ADDRESS_BASE]) {
        if ([[PartnerIAPHelper sharedInstance] productPurchased:STORE_UNLOCK_ID]) {
            [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];
        } else {
            [self.downloadButton showText:STRING_BUYING forBlue:YES];
        }
    }
}

- (void)setVoiceData:(DownloadDataPkgInfo*)info
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedTransactionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productDone:) name:IAPHelperProductDoneTransactionNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:IAPHelperProductRequestFailedNotification object:nil];

    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    info.libID = lib.currentLibID;
    Database* db = [Database sharedDatabase];
    if ([db loadVoicePkgInfo:info] == nil) {
        [self.backToShelfButton setHidden:YES];
        [self.downloadButton setHidden:NO];
       if (_products != nil) {
            [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];
        } else {
            [self.downloadButton start];
        }
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
    if ([[self.downloadButton titleForState:UIControlStateNormal] isEqual:STRING_BUYING]
        || [[self.downloadButton titleForState:UIControlStateNormal] isEqual:STRING_BUYING_FAILED]) {
        
        if ([_info.url isEqualToString:STRING_STORE_URL_ADDRESS_BASE]) {
            if ([[PartnerIAPHelper sharedInstance] productPurchased:STORE_UNLOCK_ID]) {
                [self.downloadButton showText:STRING_DOWNLOAD forBlue:YES];
            } else {
                [self.downloadButton showText:STRING_ON_BUYING forBlue:YES];
            }
        }
        
        [[PartnerIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                
                _products = products;
                SKProduct * product = (SKProduct *)_products[0];
                
                NSLog(@"Buying %@...", product.productIdentifier);
                [[PartnerIAPHelper sharedInstance] buyProduct:product];
            } else {
                [self.downloadButton  setTitle:STRING_BUYING_FAILED forState:UIControlStateNormal];
            }
        }];
        
    } else if ([[self.downloadButton titleForState:UIControlStateNormal] isEqual:STRING_DOWNLOAD]) {
        // begin download
        [self.downloadButton  setTitle:STRING_DOWNLOADING forState:UIControlStateNormal];
        self.downloadButton.enabled = NO;
        [self.delegate doDownload:_info];        
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
