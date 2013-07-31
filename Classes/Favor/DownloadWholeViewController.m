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
#import "Database.h"
#import "StoreDownloadPkg.h"
#import "StoreVoiceDataListParser.h"

@interface DownloadWholeViewController ()
{
    CourseParser* _courseParser;
    DACircularProgressView* _progressview;
    NSInteger _downloadCount;
    BOOL _isStop;

}
@end

@implementation DownloadWholeViewController
@synthesize scenesName, pkgName, dataPath;
@synthesize delegate;
@synthesize buttonCancel,buttonDownload;
@synthesize eViewType;
@synthesize viewTitle;
@synthesize buttonRenew;
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
        self.viewTitle.text = self.eViewType == POPVIEW_TYPE_BORROW ? STRING_PROMPT_EXPIRED : STRING_PROMPT_DOWNLOADALL;
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

         [self.buttonRenew setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
        [self.buttonRenew setTitleColor:[UIColor colorWithWhite:0.4 alpha:0.8] forState:UIControlStateHighlighted];
        [self.buttonRenew setBackgroundImage:normalImage forState:UIControlStateNormal];
        [self.buttonRenew setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];

        self.buttonRenew.hidden = self.eViewType == POPVIEW_TYPE_BORROW ? NO: YES;
        self.buttonDownload.hidden = !self.buttonRenew.hidden;
        self.buttonCancel.hidden = !self.buttonRenew.hidden;
       _downloadCount= 0;
        _isStop = NO;
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
    self.viewTitle = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    _isStop = YES;
    [self.delegate cancelButtonClicked:self];
}

- (IBAction)downAll:(id)sender
{
    [self startDownload];
}

- (IBAction)renew:(id)sender
{
    self.buttonRenew.enabled = NO;
    [self.buttonRenew setTitle:STRING_RENEWING forState:UIControlStateNormal];
    // delete all content in scenesName folder
    NSString* scenseFolderPath = [NSString stringWithFormat:@"%@/%@", self.dataPath, self.scenesName];
    NSFileManager* mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:scenseFolderPath error:nil];

    // create directory
    [mgr createDirectoryAtPath:scenseFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSRange r = [self.dataPath rangeOfString:@"/" options:NSBackwardsSearch];
    if (r.location != NSNotFound) {
        NSString* path = [self.dataPath substringToIndex:(r.location)];
          
        NSString* pkgNameString = [self.dataPath substringFromIndex:(r.location + r.length)];
        r = [path rangeOfString:@"/" options:NSBackwardsSearch];
        if (r.location != NSNotFound) {
            NSString* libValue = [path substringFromIndex:(r.location+r.length)];
            NSInteger libID = [libValue intValue];
            Database* db = [Database sharedDatabase];
            VoiceDataPkgObjectFullInfo* fullInfo = [db loadVoicePkgInfoByTitle:pkgNameString withLibID:libID];
            NSString* libURL = nil;
            if (fullInfo !=  nil) {
                libURL = fullInfo.url;
            }
            NSInteger pkgID = [db getVoicePkgInfoID:pkgNameString withPath:[NSString stringWithFormat:@"%d/%@", libID, pkgNameString]];
            if (pkgID != -1) {
                DownloadDataPkgCourseInfo* course = [db loadPkgCourseInfoByTitle:self.scenesName withPKGID:pkgID];
                if (libURL != nil && course != nil) {
                    StoreDownloadCourse* downloadCourse = [[[StoreDownloadCourse alloc] init] autorelease];
                    downloadCourse.pkgPath = [NSString stringWithFormat:@"%@/%@", self.dataPath, self.scenesName];
                    
                    downloadCourse.pkgURL = libURL;
                    downloadCourse.course = course;
                    downloadCourse.delegate = (id)self;
                    [downloadCourse startDownload];
                    
                }
            }
                               
          }

    }
}

- (void)finishDowloaded:(NSError*)error
{
    if (error != nil) {
        self.viewTitle.text = STRING_RENEW_FAILED;
    } else {
        self.viewTitle.text = STRING_RENEW_SUCCEED;       
    }
    if ([self.delegate respondsToSelector:@selector(dimissPopView:)]) {
        [self.delegate performSelector:@selector(dimissPopView:) withObject:self afterDelay:1.0];
    }
}

- (void)startDownload
{
    [self loadCourses];
    _progressview.progress = 0;
    _progressview.hidden = NO;
    [self.buttonDownload setTitle:STRING_DOWNLOADINGALL forState:UIControlStateNormal];
    self.buttonDownload.enabled = NO;
    for (NSInteger i = 0; i < [_courseParser.course.lessons count]; i++) {
        // download
        if (_isStop) {
            return;
        }
        DownloadLesson* download = [[[DownloadLesson alloc] init] autorelease];
        download.delegate = (id)self;
        download.nPositionInCourse = i;
        download.courseParser = _courseParser;
        if (![download checkIsNeedDownload]) {
            _downloadCount++;
           // _progressview.progress = (CGFloat)i/(CGFloat)[_courseParser.course.lessons count];
            
        }
    }
    if (_downloadCount == [_courseParser.course.lessons count]) {
        Database* db = [Database sharedDatabase];
        NSRange r = [self.dataPath rangeOfString:STRING_VOICE_PKG_DIR];
        if (r.location != NSNotFound) {
            NSString* path = [self.dataPath substringFromIndex:(r.location + r.length + 1)];
            [db updateDownloadedInfo:self.scenesName withPath:path];
            [self.delegate cancelButtonClicked:self];
           
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
    _downloadCount++;
    _progressview.progress = (CGFloat)_downloadCount/(CGFloat)[_courseParser.course.lessons count];
    if (_downloadCount == [_courseParser.course.lessons count]) {
        Database* db = [Database sharedDatabase];
        NSRange r = [self.dataPath rangeOfString:STRING_VOICE_PKG_DIR];
        if (r.location != NSNotFound) {
            NSString* path = [self.dataPath substringFromIndex:(r.location + r.length + 1)];
            [db updateDownloadedInfo:self.scenesName withPath:path];
            [self.delegate cancelButtonClicked:self];
            
        }
    }
}

- (void)downloadfailed:(DownloadLesson*)download {
    _downloadCount++;
    if (_downloadCount == [_courseParser.course.lessons count]) {
        Database* db = [Database sharedDatabase];
        NSRange r = [self.dataPath rangeOfString:STRING_VOICE_PKG_DIR];
        if (r.location != NSNotFound) {
            NSString* path = [self.dataPath substringFromIndex:(r.location + r.length + 1)];
            [db updateDownloadedInfo:self.scenesName withPath:path];
            [self.delegate cancelButtonClicked:self];
            
        }
    }
}

@end
