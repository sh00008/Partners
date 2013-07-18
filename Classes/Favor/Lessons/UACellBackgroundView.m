//
//  UACellBackgroundView.m
//  Voice
//
//  Created by JiaLi on 11-7-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UACellBackgroundView.h"


#define TABLE_CELL_BACKGROUND    { 1, 1, 1, 1, 0.866, 0.866, 0.866, 1}			// #FFFFFF and #DDDDDD
#define kDefaultMargin           10

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight);

@implementation UACellBackgroundView

@synthesize position;
@synthesize fromRed,fromGreen,fromBlue,toRed,toGreen,toBlue;
@synthesize bDark;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        fromRed = 1.0;
        fromGreen = 1.0;
        fromBlue = 1.0;
        toRed = 0.926;
        toGreen = 0.926;
        toBlue = 0.926;
    }
    return self;
}

- (BOOL) isOpaque {
    return NO;
}

-(void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef graphicContext = UIGraphicsGetCurrentContext();
	CGColorSpaceRef colors_pace;
	
	size_t num_locations = 3;
	CGFloat locations[3] = { 0.0, 0.2, 1.0};
	CGFloat components[12] = { 0.92, 0.92, 0.92, 1.0,
		0.96, 0.96, 0.96, 1.0,  0.92, 0.92, 0.920, 1.0};
	
	
	colors_pace =  CGColorSpaceCreateDeviceRGB();;
	CGGradientRef gradientRef = CGGradientCreateWithColorComponents (colors_pace, components,
																	 locations, num_locations);
	
	CGPoint ptStart, ptEnd;
	ptStart.x = 0.0;
	ptStart.y = 0.0;
	ptEnd.x = 0.0;
	ptEnd.y = rect.size.height;
	CGContextDrawLinearGradient (graphicContext, gradientRef, ptStart, ptEnd, kCGGradientDrawsAfterEndLocation);
	
	CGPoint ptLine1 = CGPointMake(0, 1);
	CGPoint ptLine2 = CGPointMake(self.frame.size.width, 1);
	/*CGContextSetRGBStrokeColor(graphicContext, 1.0, 1.0, 1.0, 1.0);
	CGContextMoveToPoint(graphicContext, ptLine1.x, ptLine1.y);
	CGContextSetLineWidth(graphicContext, 0.5);
	CGContextAddLineToPoint(graphicContext, ptLine2.x, ptLine2.y);
	CGContextStrokePath(graphicContext);
	*/
	ptLine1 = CGPointMake(0, 0);
	ptLine2 = CGPointMake(self.frame.size.width, 1);
	CGContextSetRGBStrokeColor(graphicContext, 0.8, 0.8, 0.8, 0.3);
	CGContextMoveToPoint(graphicContext, ptLine1.x, ptLine1.y);
	CGContextAddLineToPoint(graphicContext, ptLine2.x, ptLine2.y);
	CGContextStrokePath(graphicContext);
	
	CGColorSpaceRelease(colors_pace);
    /*
    CGContextRef c = UIGraphicsGetCurrentContext();	
    
    CGFloat lineWidth = 0.5;
    
    CGRect rect = [self bounds];
    if (bDark) {
        CGContextSetFillColorWithColor(c, [[UIColor colorWithRed:toRed green:toGreen blue:toBlue alpha:1.0] CGColor]);

    } else {
        CGContextSetFillColorWithColor(c, [[UIColor whiteColor] CGColor]);
    }
    
    CGContextFillRect(c, rect);
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:66.0/255.0 green:168.0/255.0 blue:250.0/255.0 alpha:1.0] CGColor]);
    CGContextSetLineWidth(c, 1);
    CGContextMoveToPoint(c, 10, rect.size.height);
    CGContextAddLineToPoint(c, rect.size.width - 10, rect.size.height);
    CGContextStrokePath(c);
    return;
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    miny -= 1;
    
    CGFloat locations[3] = { 0.0, 0.2, 0.8 };
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient = nil;
    CGFloat components[12] = {toRed+10, toGreen+10, toBlue+10, 1.0, toRed, toGreen, toBlue, 1.0,toRed, toGreen, toBlue, 1.0};
    CGContextSetStrokeColorWithColor(c, [[UIColor grayColor] CGColor]);
    CGContextSetLineWidth(c, lineWidth);
    CGContextSetAllowsAntialiasing(c, YES);
    CGContextSetShouldAntialias(c, YES);
    
    if (position == UACellBackgroundViewPositionTop) {
        
        miny += 1;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, minx, maxy);
        CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, maxy, kDefaultMargin);
        CGPathAddLineToPoint(path, NULL, maxx, maxy);
        CGPathAddLineToPoint(path, NULL, minx, maxy);
        CGPathCloseSubpath(path);
        
        // Fill and stroke the path
        CGContextSaveGState(c);
        CGContextAddPath(c, path);
        CGContextClip(c);
        
        myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, 3);
        CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
        
        CGContextAddPath(c, path);
        CGPathRelease(path);
        CGContextStrokePath(c);
        CGContextRestoreGState(c);		
        
    } else if (position == UACellBackgroundViewPositionBottom) {
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, minx, miny);
        CGPathAddArcToPoint(path, NULL, minx, maxy, midx, maxy, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, maxx, maxy, maxx, miny, kDefaultMargin);
        CGPathAddLineToPoint(path, NULL, maxx, miny);
        CGPathAddLineToPoint(path, NULL, minx, miny);
        CGPathCloseSubpath(path);
        
        // Fill and stroke the path
        CGContextSaveGState(c);
        CGContextAddPath(c, path);
        CGContextClip(c);
        
        myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, 3);
        CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
        
        CGContextAddPath(c, path);
        CGPathRelease(path);
        CGContextStrokePath(c);
        CGContextRestoreGState(c);
        
        
    } else if (position == UACellBackgroundViewPositionMiddle) {
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, minx, miny);
        CGPathAddLineToPoint(path, NULL, maxx, miny);
        CGPathAddLineToPoint(path, NULL, maxx, maxy);
        CGPathAddLineToPoint(path, NULL, minx, maxy);
        CGPathAddLineToPoint(path, NULL, minx, miny);
        CGPathCloseSubpath(path);
        
        // Fill and stroke the path
        CGContextSaveGState(c);
        CGContextAddPath(c, path);
        CGContextClip(c);
        
        myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, 3);
        CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
        
        CGContextAddPath(c, path);
        CGPathRelease(path);
        CGContextStrokePath(c);
        CGContextRestoreGState(c);
        
    } else if (position == UACellBackgroundViewPositionSingle) {
        miny += 1;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, minx, midy);
        CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, kDefaultMargin);
        CGPathCloseSubpath(path);
        
        
        // Fill and stroke the path
        CGContextSaveGState(c);
        CGContextAddPath(c, path);
        CGContextClip(c);
        
        
        myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, 3);
        CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
        
        CGContextAddPath(c, path);
        CGPathRelease(path);
        CGContextStrokePath(c);
        CGContextRestoreGState(c);	
    }
    
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    return;*/
}

- (void)dealloc {
    [super dealloc];
}

- (void)setPosition:(UACellBackgroundViewPosition)newPosition {
    if (position != newPosition) {
        position = newPosition;
        [self setNeedsDisplay];
    }
}

@end

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight) {
    float fw, fh;
    
    if (ovalWidth == 0 || ovalHeight == 0) {// 1
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);// 2
    
    CGContextTranslateCTM (context, CGRectGetMinX(rect),// 3
                           CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
    fw = CGRectGetWidth (rect) / ovalWidth;// 5
    fh = CGRectGetHeight (rect) / ovalHeight;// 6
    
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);// 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);// 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);// 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
    CGContextClosePath(context);// 12
    
    CGContextRestoreGState(context);// 13
}
