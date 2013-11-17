//
//  StoreCourceTableViewCell.m
//  Sanger
//
//  Created by JiaLi on 12-9-25.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import "StoreCourceTableViewCell.h"
#import "GTMHTTPFetcher.h"

@implementation StoreCourceTableViewCellBackground
@synthesize bDark;
@synthesize bSeperator;

- (void)drawRect:(CGRect)rect
{
    CGContextRef graphicContext = UIGraphicsGetCurrentContext();
    if (graphicContext == nil) {
        return;
    }
    if (bDark) {
        // fill rect
        CGContextSetFillColorWithColor(graphicContext, [[UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:233.0/255.0 alpha:1.0] CGColor]);
        
        CGRect middleRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
        CGContextFillRect(graphicContext, middleRect);

        
        // draw line h
        CGContextSetStrokeColorWithColor(graphicContext, [[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(graphicContext, 0, 0);
        CGContextAddLineToPoint(graphicContext, rect.size.width, 0);
        CGContextStrokePath(graphicContext);
        CGContextSetStrokeColorWithColor(graphicContext, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(graphicContext, 0, 1);
        CGContextAddLineToPoint(graphicContext, rect.size.width, 1);
        CGContextStrokePath(graphicContext);
 
        // draw bottom
        CGContextSetStrokeColorWithColor(graphicContext, [[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(graphicContext, 0, rect.size.height);
        CGContextAddLineToPoint(graphicContext, rect.size.width, rect.size.height);
        CGContextStrokePath(graphicContext);

    } else {
        
        // fill rect
        CGContextSetFillColorWithColor(graphicContext, [[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:242.0/255.0 alpha:1.0] CGColor]);
        
        CGRect middleRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
        CGContextFillRect(graphicContext, middleRect);
        CGContextStrokePath(graphicContext);

        CGContextSetStrokeColorWithColor(graphicContext, [[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(graphicContext, 0, 0);
        CGContextAddLineToPoint(graphicContext, rect.size.width, 0);
        CGContextStrokePath(graphicContext);
        CGContextSetStrokeColorWithColor(graphicContext, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(graphicContext, 0, 1);
        CGContextAddLineToPoint(graphicContext, rect.size.width, 1);
        CGContextStrokePath(graphicContext);
      
        // draw bottom
        CGContextSetStrokeColorWithColor(graphicContext, [[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(graphicContext, 0, rect.size.height);
        CGContextAddLineToPoint(graphicContext, rect.size.width, rect.size.height);
        CGContextStrokePath(graphicContext);
    }
    if (bSeperator) {
        // draw line v
        CGContextSetStrokeColorWithColor(graphicContext, [[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(graphicContext, 50, 0);
        CGContextAddLineToPoint(graphicContext, 50, rect.size.height);
        CGContextStrokePath(graphicContext);
        
        CGContextSetStrokeColorWithColor(graphicContext, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(graphicContext, 51, 0);
        CGContextAddLineToPoint(graphicContext, 51, rect.size.height);
        CGContextStrokePath(graphicContext);

    }

}

@end

@implementation StoreCourceTableViewCell
@synthesize courseIndexLabel;
@synthesize courseNameLabel ;

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

- (void)setCourseData:(DownloadDataPkgCourseInfo*)course withURL:(NSString*)parentURL;
{
     _course = course;
    if (_course.receivedXMLPath == nil) {
        NSString* path = [NSString stringWithFormat:@"%@/%@", parentURL, course.file];
        NSURL* url = [NSURL URLWithString:path];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:@"cover" forHTTPHeaderField:@"User-Agent"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        [fetcher beginFetchWithDelegate:self
                      didFinishSelector:@selector(fetcher:finishedWithData:error:)];
    }
}

- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error != nil) {
        
    } else {
        if (_course != nil) {
            NSString* xmlPath =  [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(),_course.file];
            [data writeToFile:xmlPath atomically:YES];
            _course.receivedXMLPath = xmlPath;
         }
    }
}

- (void)dealloc
{
    [self.courseIndexLabel release];
    [self.courseNameLabel release];
    [super dealloc];
}

@end
