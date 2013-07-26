//
//  DownloadWholeLessonViewController.m
//  Partners
//
//  Created by JiaLi on 13-7-26.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "DownloadWholeLessonViewController.h"
#import "CourseParser.h"
#import "Course.h"
#import "Lesson.h"
#import "VoiceDef.h"
@interface DownloadWholeLessonViewController ()
{
    CourseParser* _courseParser;

}
@end

@implementation DownloadWholeLessonViewController
@synthesize scenesName, pkgName, dataPath;
@synthesize delegate;


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
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    for (NSInteger i = 0; i < [_courseParser.course.lessons count]; i++) {
        // download
    }
}
@end
