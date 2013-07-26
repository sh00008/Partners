//
//  DownloadWholeViewController.m
//  Partners
//
//  Created by JiaLi on 13-7-26.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "DownloadWholeViewController.h"
#import "CourseParser.h"
#import "Course.h"
#import "Lesson.h"
#import "VoiceDef.h"
#import <QuartzCore/QuartzCore.h>
#import "DACircularProgressView.h"
#import "DownloadLesson.h"

@interface DownloadWholeViewController ()
{
    CourseParser* _courseParser;
    DACircularProgressView* _progressview;

}
@end

@implementation DownloadWholeViewController
@synthesize scenesName, pkgName, dataPath;
@synthesize delegate;
@synthesize buttonCancel,buttonDownload;

- (void)loadCourses
{
    if (_courseParser != nil) {
        return;
    }
    _courseParser = [[CourseParser alloc] init];
    
    NSString* resourcePath;
    if (self.scenesName != nil) {
        resourcePath = [NSString stringWithFormat:@"/%@/%@", self.dataPath, self.scenesName];
    }
    NSString* indexString = STRING_LESSONS_INDEX_XML;
    _courseParser.resourcePath = resourcePath;
    [_courseParser loadCourses:indexString];
}

- (void)viewDidLoad
{
    if (_progressview == nil) {
        _progressview = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 20.0f, 40.0f, 40.0f)];
        _progressview.center = self.view.center;
        [self.view addSubview:_progressview];
        _progressview.progress = 0;
        _progressview.hidden = YES;
        self.view.layer.cornerRadius = 2;
        self.view.layer.shadowRadius = 8;
        UIImage *normalImage = nil;
        UIImage *highlightedImage = nil;
        normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-cancel"];
        highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-cancel-d"];
        [self.buttonCancel setTitleColor:[UIColor colorWithWhite:0.3 alpha:1] forState:UIControlStateNormal];
        [self.buttonCancel setTitleColor:[UIColor colorWithWhite:0.3 alpha:0.8] forState:UIControlStateHighlighted];
        
        CGFloat hInset = floorf(normalImage.size.width / 2);
        CGFloat vInset = floorf(normalImage.size.height / 2);
        UIEdgeInsets insets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
        normalImage = [normalImage resizableImageWithCapInsets:insets];
        highlightedImage = [highlightedImage resizableImageWithCapInsets:insets];
        [self.buttonCancel setBackgroundImage:normalImage forState:UIControlStateNormal];
        [self.buttonCancel setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        
        normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-default"];
        highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-default-d"];
        [self.buttonDownload setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
        [self.buttonDownload setTitleColor:[UIColor colorWithWhite:0.4 alpha:0.8] forState:UIControlStateHighlighted];
        normalImage = [normalImage resizableImageWithCapInsets:insets];
        highlightedImage = [highlightedImage resizableImageWithCapInsets:insets];
        [self.buttonDownload setBackgroundImage:normalImage forState:UIControlStateNormal];
        [self.buttonDownload setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        
    }
    [super viewDidLoad];
}
- (IBAction)closePopup:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.delegate cancelButtonClicked:self];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_courseParser release];
    _courseParser = nil;
    self.buttonCancel = nil;
    self.buttonDownload = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self.delegate cancelButtonClicked:self];
}

- (IBAction)downAll:(id)sender
{
    [self startDownload];
}

- (void)startDownload
{
    [self loadCourses];
    _progressview.hidden = NO;
    for (NSInteger i = 0; i < [_courseParser.course.lessons count]; i++) {
        // download
        DownloadLesson* download = [[[DownloadLesson alloc] init] autorelease];
        download.nPositionInCourse = i;
        download.courseParser = _courseParser;
        if (![download checkIsNeedDownload]) {
            _progressview.progress = (CGFloat)i/(CGFloat)[_courseParser.course.lessons count];
            
        }
    }
}

- (void)startDownloadingXinFile:(DownloadLesson*)download {
    
}

- (void)endDownloadingXinFile:(DownloadLesson*)download {
    
}

- (void)startDownloadingLesFile:(DownloadLesson*)download {
    
}

- (void)endDownloadingLesFile:(DownloadLesson*)download {
    
}

- (void)startDownloadingIsbFile:(DownloadLesson*)download {
    
}
- (void)endDownloadingIsbFile:(DownloadLesson*)download {
    
}

- (void)downloadSucceed:(DownloadLesson*)download {
    _progressview.progress = (CGFloat)download.nPositionInCourse/(CGFloat)[_courseParser.course.lessons count];
}

- (void)downloadfailed:(DownloadLesson*)download {
     
}

@end
