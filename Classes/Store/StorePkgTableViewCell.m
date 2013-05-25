//
//  StorePkgTableViewCell.m
//  Sanger
//
//  Created by JiaLi on 12-9-19.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import "StorePkgTableViewCell.h"
#import "GTMHTTPFetcher.h"

@implementation CustomBackgroundView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
       NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString* stringResource = @"bg_cell.png";
        NSString* imagePath = [NSString stringWithFormat:@"%@/%@", resourcePath, stringResource];
        UIImage* bgImage = [UIImage imageWithContentsOfFile:imagePath];
        self.backgroundColor = [UIColor colorWithPatternImage:bgImage];
	}
	return self;
}

/*- (void)drawRect:(CGRect)rect {
	CGContextRef graphicContext = UIGraphicsGetCurrentContext();
    //CGRect shadowTopRect = CGRectMake(0, 0, rect.size.width, 10);
    CGPoint line1PointStart = CGPointMake(0, 0);
    CGPoint line1PointEnd = CGPointMake(rect.size.width, 0);
    CGContextMoveToPoint(graphicContext, line1PointStart.x, line1PointStart.y);
    CGContextAddLineToPoint(graphicContext, line1PointEnd.x, line1PointEnd.y);//(graphicContext, line1PointStart);
  
    CGRect middleRect = CGRectMake(0, 1, rect.size.width, rect.size.height - 6);
    CGRect shadowBottomRect = CGRectMake(0, rect.size.height - 5, rect.size.width, 5);
    CGContextSetFillColorWithColor(graphicContext, [[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0] CGColor]);
    //CGContextFillRect(graphicContext, shadowTopRect);
    CGContextFillRect(graphicContext, middleRect);

    CGContextSetFillColorWithColor(graphicContext, [[UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1.0] CGColor]);

    CGContextFillRect(graphicContext, shadowBottomRect);
}
*/
- (void)dealloc {
    [super dealloc];
}


@end
@implementation StorePkgTableViewCell

@synthesize coverImageView;
@synthesize titleLabel;
@synthesize introLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setVoiceData:(DownloadDataPkgInfo*)info
{
    _info = info;
    self.titleLabel.text = info.title;
    self.introLabel.text = info.intro;
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
            _info.receivedCoverImagePath = pngPath;
            [data writeToFile:pngPath atomically:YES];
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
@end
