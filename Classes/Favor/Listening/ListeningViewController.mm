//
//  ListeningViewController.m
//  Say
//
//  Created by JiaLi on 11-7-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/NSDate.h>
#import "ListeningViewController.h"
#import "Sentence.h"
#import "Teacher.h"
#import "Lesson.h"
#import "Course.h"
#import "UACellBackgroundView.h"
#import "Globle.h"
#import "SettingViewController.h"
#import "isaybioDecode.h"
#import "ConfigData.h"
#import "VoiceDef.h"
#import "GTMHTTPFetcher.h"
#import "Database.h"
#import "ListeningCell.h"
#import "RecordingWaveCell.h"
#import "RecordingObject.h"

#define LOADINGVIEWTAG      20933
#define DOWNLOADINGVIEWTAG  20936
#define FAILEDRECORDINGVIEW_TAG 45505
#define PLAY_SRC_VOICE_BUTTON_TAG 50001
#define PLAY_USER_VOICE_BUTTON_TAG 50002
#define RECORDING_USER_VOICE_BUTTON_TAG 50003
#define FONT_SIZE_OF_SRC    22
#define FONT_SIZE_OF_TRANS    14

#define STRING_KEY_LESSONFILE @"lessonFile"
#define STRING_KEY_DATAPATH @"dataPath"
#define STRING_KEY_COURSETITLE @"title"
#define STRING_KEY_LESSONPATH @"lessonPath"
#define STRING_KEY_TRYSERVERLIST @"tryServerListIndex"
#define STRING_KEY_FILETYPE @"fileType"
#define STRING_KEY_FILETYPE_XAT @"xat"
#define STRING_KEY_FILETYPE_ISB @"isb"

@implementation ListeningViewController
@synthesize sentencesArray = _sentencesArray;
@synthesize teachersArray = _teachersArray;
@synthesize sentencesTableView = _sentencesTableView;
//@synthesize listeningToolbar = _listeningToolbar;
@synthesize recordingItem = _recordingItem;
@synthesize progressBar;
//@synthesize timepreces;
//@synthesize timelast;
@synthesize senCount;
@synthesize updataeTimer;
@synthesize wavefile;
@synthesize player;
@synthesize isbfile = _isbfile;
@synthesize courseParser;
@synthesize delegate;
@synthesize adView;
@synthesize collpaseLesson;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;

        progressBar.minimumValue = 0.0;
        progressBar.maximumValue = 10.0;
        
        updateTimer = nil;
        timeStart = 0.0;
        nPosition = 0;
        nLesson = PLAY_LESSON_TYPE_NONE;
        bRecording = NO;
        ePlayStatus = PLAY_STATUS_NONE;
        settingData = [[SettingData alloc] init];
        [settingData loadSettingData];
        nCurrentReadingCount = 1;
        nLesson = settingData.eReadingMode == READING_MODE_WHOLE_TEXT ?  PLAY_LESSON : PLAY_SENTENCE;
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(willEnterToBackground:) name:NOTI_WILLENTERFOREGROUND object:nil]; 
        bAlReadyPaused = NO;
        nLastScrollPos = 0;
        bInit = NO;
        bParseWAV = NO;
        resourcePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Image"]];
    }
    return self;
}

- (void)dealloc
{
    [settingData release];
    settingData = nil;
    [resourcePath release];
    resourcePath = nil;
    [self.isbfile release];
//    [self.listeningToolbar release];
    [self.sentencesArray release];
    [self.teachersArray release];
    [progressBar release];
    [updateTimer release];
    [self.senCount release];
    [resourcePath release];
    [self.player stop];
    [self.player release];
    [self.courseParser release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)initMembers;
{
    NSString* backString = STRING_BACK;
    _bDownloadedXAT = NO;
    _bDownloadedISB = NO;
    [self.sentencesTableView setBackgroundView:nil];
    [self.sentencesTableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    [self.sentencesTableView setBackgroundColor:UIColor.clearColor];
    
    
    /*UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"Btn_Back."] forState:UIControlStateNormal];
    [button setTitle:@"Delete" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    [button.layer setCornerRadius:4.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor: [[UIColor grayColor] CGColor]];
    button.frame=CGRectMake(0.0, 100.0, 60.0, 30.0);
    [button addTarget:self action:@selector(batchDelete) forControlEvents:UIControlEventTouchUpInside];*/

    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStyleBordered target:nil action:nil];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backItem;
    [backItem release];
    
    
    
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[UIColor blackColor] forKey:UITextAttributeTextColor];
    [dict setObject:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
    [dict setObject:[UIFont fontWithName:@"Arial" size:16] forKey:UITextAttributeFont];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    [dict release];
    
    UIImage* bkimage = [[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/background_gray.png", resourcePath]] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bkimage];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(settingChanged:) name:NOTI_CHANGED_SETTING_VALUE object:nil]; 
//    [self.listeningToolbar loadToolbar:self];
    
    UIImage* imageThumb = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/slider-handle.png", resourcePath]];
    
    [self.progressBar setThumbImage:imageThumb forState:UIControlStateNormal];
    
    UIImage* imageTrack = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/slider-track-right.png", resourcePath]];
    [self.progressBar setMaximumTrackImage:imageTrack forState:UIControlStateNormal];
    [self.progressBar setMinimumTrackImage:imageTrack forState:UIControlStateNormal];
    NSInteger maxValue = [_sentencesArray count];
    maxValue = maxValue == 0? 1: maxValue;
    [self.progressBar setMaximumValue:maxValue];
    [self.progressBar setMinimumValue:1];
    [self.progressBar addTarget:self action:@selector(onGotoSentence:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressBar addTarget:self action:@selector(onChangingGotoSentence:) forControlEvents:UIControlEventTouchDragInside];
    
    self.progressBar.continuous = YES;
    self.progressBar.enabled = NO;
//    [self.listeningToolbar enableToolbar:NO];

    if (![self downloadLesson]) {
        return;
    }

    if (_bDownloadedISB && _bDownloadedXAT) {
        [self displayLesson];
    }
}

- (void)displayLesson;
{
    Lesson* lesson = (Lesson*)[self.courseParser.course.lessons objectAtIndex:self.nPositionInCourse];
    [self.courseParser loadLesson:self.nPositionInCourse];
    self.sentencesArray = lesson.setences;
    self.teachersArray = lesson.teachers;
    self.wavefile = lesson.wavfile;
    self.isbfile = lesson.isbfile;
    self.navigationItem.title = lesson.title;
    
    
    // 解压wave
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:wavefile]) {
        [self addLoadingView];
        bParseWAV = YES;
        self.sentencesTableView.hidden = YES;
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self performSelector:@selector(parseWAVFile) withObject:nil afterDelay:2.0];
    } else {
        self.sentencesTableView.hidden = NO;
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [self initValue];
        NSInteger maxValue = [_sentencesArray count];
        [self.progressBar setMaximumValue:maxValue];
        [self.progressBar setMinimumValue:1];
        self.progressBar.enabled = YES;
//        [self.listeningToolbar enableToolbar:YES];
    }
    
    didSection = -1;
    [self performSelector:@selector(firstOneClicked) withObject:self afterDelay:0.2f];
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
    loadingView.center = self.view.center;
    [self.view addSubview:loadingView];
    [loadingView release];

}
- (void)addLoadingView;
{
    [self addWaitingView:LOADINGVIEWTAG withText:STRING_LOADING_TEXT withAnimation:YES];
}

- (void)removeLoadingView;
{
    UIView* loadingView = [self.view viewWithTag:LOADINGVIEWTAG];
    if (loadingView != nil) {
        [loadingView removeFromSuperview];
    }
}

- (void)addDownloadingView
{
    self.sentencesTableView.hidden = YES;
    [self.navigationItem setHidesBackButton:NO animated:YES];
   [self removeDownloadingView];
    [self addWaitingView:DOWNLOADINGVIEWTAG withText:STRING_DOWNLOADING_TEXT withAnimation:YES];

}

- (void)removeDownloadingView
{
    UIView* loadingView = [self.view viewWithTag:DOWNLOADINGVIEWTAG];
    if (loadingView != nil) {
        [loadingView removeFromSuperview];
    }

}

- (void)addDownloadingFailedView;
{
    self.sentencesTableView.hidden = NO;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [self addWaitingView:DOWNLOADINGVIEWTAG withText:STRING_DOWNLOADING_FAILED_TEXT withAnimation:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!bInit) {
        bInit = YES;
        [self initMembers];
    }
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)initValue;
{
    if (self.player == nil) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: wavefile];
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
        [fileURL release];
        
        self.player = newPlayer;
        [player prepareToPlay];
        [player setDelegate:(id<AVAudioPlayerDelegate>)self];
        [newPlayer release];
        self.player.currentTime = timeStart;
        self.player.volume = 5.0;
    }
    
    self.senCount.text = [NSString stringWithFormat:@"%d / %d ", (nPosition+1), [self.sentencesArray count]];
    loopstarttime = 0.0;
    loopendtime = self.player.duration;
    fVolumn = 5.0;
        
//    self.listeningToolbar.previousItem.enabled = (nPosition != 0);
//    self.listeningToolbar.nextItem.enabled = ((nPosition + 1) != [_sentencesArray count]);
}

- (void)parseWAVFile;
{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:wavefile]) {
        NSRange range = [wavefile rangeOfString:@"/" options:NSBackwardsSearch];
        NSString* wavePath = [wavefile substringToIndex:range.location];
        [fileMgr createDirectoryAtPath:wavePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //NSLog(@"%@", wavePath);
    char strwavefile[256];
    [wavefile getCString:strwavefile maxLength:256 encoding:NSUTF8StringEncoding];
    
    char strisbfile[256];
    [self.isbfile getCString:strisbfile maxLength:256 encoding:NSUTF8StringEncoding];
    [isaybioDecode ISB_Isb:strisbfile toWav:strwavefile];
    [self removeLoadingView];
    [self initValue];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    bParseWAV = NO;
    [self.sentencesTableView reloadData];
    self.sentencesTableView.hidden = NO;
    NSInteger maxValue = [_sentencesArray count];
    [self.progressBar setMaximumValue:maxValue];
    [self.progressBar setMinimumValue:1];
   // [self.listeningToolbar enableToolbar:YES];
    self.progressBar.enabled = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NOTI_CHANGED_SETTING_VALUE object:nil]; 
    [self.recordingItem release];
    self.recordingItem = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!bParseWAV) {
        [self reloadTableView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    timeStart = 0.0;
    
    if (ePlayStatus == PLAY_STATUS_PLAYING) {
        [self setStatusPause];
        Sentence* sentence = [self.sentencesArray objectAtIndex:nPosition];
        self.player.currentTime = [sentence startTime];
        [self updateUI];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
     //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
{
  /*  ListeningVolumView* volumView = (ListeningVolumView*)[self.view viewWithTag:(NSInteger)VOLUMNVIEW_TAG];
    if (volumView != nil) {
        [volumView removeFromSuperview];
    }*/

    [self reloadTableView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    Sentence * sentence = [self.sentencesArray objectAtIndex:section];
   	NSString *aMsg = sentence.orintext;
    NSString *transText = sentence.transtext;
    CGFloat divide = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone?  0.9 : 0.95;
    CGFloat width = self.view.bounds.size.width * divide - 2*MAGIN_OF_BUBBLE_TEXT_START - 72;
	CGSize size    = [Globle calcTextHeight:aMsg withWidth:width];
    if (sentence.transtext != nil) {
        CGSize szTrans = [Globle calcTextHeight:transText withWidth:width];
        size = CGSizeMake(size.width, size.height + szTrans.height + MAGIN_OF_TEXTANDTRANSLATE);
    }
	size.height += 5;
	
	CGFloat height = (size.height < 44) ? 44 : size.height;
	
	return fmax(height, 107);
}


- (void)firstOneClicked{
    
    self.collpaseLesson.CollapseClickDelegate = (id)self;
    [self.collpaseLesson reloadCollapseClick];
    
    // If you want a cell open on load, run this method:
    [self.collpaseLesson openCollapseClickCellAtIndex:0 animated:YES];
}
#pragma Notifications
- (void)settingChanged:(NSNotification *)aNotification
{
    [settingData loadSettingData];
}

- (void)willEnterToBackground:(NSNotification *)aNotification
{
    if (ePlayStatus == PLAY_STATUS_PLAYING) {
        ePlayStatus = PLAY_STATUS_PAUSING;
        [player pause];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
      //  self.listeningToolbar.playItem.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/play.png", resourcePath]];
    }
}

- (void)reloadTableView;
{
}

- (BOOL)downloadLesson;
{
   Database* db = [Database sharedDatabase];
    
    VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByTitle:[self.delegate getPkgTitle]];
    if (info == nil) {
        return NO;
    }
    [self downloadXATByURL:info.url withTryIndex:-1];
    [self downloadISBByURL:info.url withTryIndex:-1];
    if (!_bDownloadedISB || !_bDownloadedXAT) {
        [self addDownloadingView];
    }
    return YES;
}

- (void)downloadXATByURL:(NSString*)url withTryIndex:(NSInteger)tryIndex
{
    Lesson* lesson = (Lesson*)[self.courseParser.course.lessons objectAtIndex:self.nPositionInCourse];
    Database* db = [Database sharedDatabase];
    
    VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByTitle:[self.delegate getPkgTitle]];
    if (info == nil) {
        return;
    }

    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    [dic setObject:lesson.file forKey:STRING_KEY_LESSONFILE];
    [dic setObject:info.dataPath forKey:STRING_KEY_DATAPATH];
    [dic setObject:[self.delegate getCourseTitle] forKey:STRING_KEY_COURSETITLE];
    [dic setObject:lesson.path forKey:STRING_KEY_LESSONPATH];
    [dic setObject:[NSNumber numberWithInteger:tryIndex] forKey:STRING_KEY_TRYSERVERLIST];
    V_NSLog(@"try list xat %d", tryIndex);
    NSString* dataFile = [lesson.file substringToIndex:[lesson.file length] - 4];
    {
        NSString* xatFile = [dataFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_XAT];
        NSString* xatURLpath = [NSString stringWithFormat:@"%@/%@/%@", url, lesson.path, xatFile];
        
        NSString* xatDatafile = [NSString stringWithFormat:@"%@/%@/%@/%@",info.dataPath, [self.delegate getCourseTitle], lesson.path, xatFile];
        V_NSLog(@"xatURLPath:  %@", xatURLpath);
        V_NSLog(@"xatDataPath:  %@", xatDatafile);
        
        if (![fileManager fileExistsAtPath:xatDatafile]) {
            NSURL* url = [NSURL URLWithString:xatURLpath];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setValue:STRING_KEY_FILETYPE_XAT forHTTPHeaderField:@"User-Agent"];
            NSMutableDictionary* userDic = [[[NSMutableDictionary alloc] initWithDictionary:dic] autorelease];
            [userDic setObject:STRING_KEY_FILETYPE_XAT forKey:STRING_KEY_FILETYPE];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            fetcher.userData = userDic;
            [fetcher beginFetchWithDelegate:self
                          didFinishSelector:@selector(fetcher:finishedWithData:error:)];
            
            _bDownloadedXAT = NO;
        } else {
            _bDownloadedXAT = YES;
        }
    }
    
}

- (void)downloadISBByURL:(NSString *)url withTryIndex:(NSInteger)tryIndex
{
    Lesson* lesson = (Lesson*)[self.courseParser.course.lessons objectAtIndex:self.nPositionInCourse];
    Database* db = [Database sharedDatabase];
    
    VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByTitle:[self.delegate getPkgTitle]];
    if (info == nil) {
        return;
    }
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    [dic setObject:lesson.file forKey:STRING_KEY_LESSONFILE];
    [dic setObject:info.dataPath forKey:STRING_KEY_DATAPATH];
    [dic setObject:[self.delegate getCourseTitle] forKey:STRING_KEY_COURSETITLE];
    [dic setObject:lesson.path forKey:STRING_KEY_LESSONPATH];
    [dic setObject:[NSNumber numberWithInteger:tryIndex] forKey:STRING_KEY_TRYSERVERLIST];
    V_NSLog(@"try list isb %d", tryIndex);
  
    NSString* dataFile = [lesson.file substringToIndex:[lesson.file length] - 4];
    NSString* isbFile = [dataFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_ISB];
    NSString* isbpath = [NSString stringWithFormat:@"%@/%@/%@", url, lesson.path, isbFile];
    NSString* isbDatafile = [NSString stringWithFormat:@"%@/%@/%@/%@",info.dataPath, [self.delegate getCourseTitle], lesson.path, isbFile];
    V_NSLog(@"isbPath:  %@", isbpath);
    V_NSLog(@"isbDataPath:  %@", isbDatafile);
    if (![fileManager fileExistsAtPath:isbDatafile]) {
        NSURL* url = [NSURL URLWithString:isbpath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:STRING_KEY_FILETYPE_ISB forHTTPHeaderField:@"User-Agent"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        NSMutableDictionary* userDic = [[[NSMutableDictionary alloc] initWithDictionary:dic] autorelease];
        [userDic setObject:STRING_KEY_FILETYPE_ISB forKey:STRING_KEY_FILETYPE];
        fetcher.userData = userDic;
        [fetcher beginFetchWithDelegate:self
                      didFinishSelector:@selector(fetcher:finishedWithData:error:)];
        _bDownloadedISB = NO;
        
    } else {
        _bDownloadedISB = YES;
    }
}

- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error != nil) {
        // try serverlist url
        DownloadServerInfo* info = [DownloadServerInfo sharedDownloadServerInfo];
        if (info != nil) {
            NSMutableArray* serverlist = info.serverList;
            NSMutableDictionary* dic = fecther.userData;
            if (dic != nil) {
                NSNumber* indexNumber = [dic objectForKey:STRING_KEY_TRYSERVERLIST];
                if (indexNumber == nil) {
                    [self removeDownloadingView];
                    [self addDownloadingFailedView];
                } else {
                    NSInteger index = [indexNumber integerValue];
                    index++;
                     if (index < [serverlist count]) {
                        NSString* url = [serverlist objectAtIndex:index];
                        NSString* fileType = [dic objectForKey:STRING_KEY_FILETYPE];
                        if ([fileType isEqualToString:STRING_KEY_FILETYPE_XAT]) {
                            [self downloadXATByURL:url withTryIndex:index];
                         } else if ([fileType isEqualToString:STRING_KEY_FILETYPE_ISB]) {
                            [self downloadISBByURL:url withTryIndex:index];
                        }
                     } else {
                         [self removeDownloadingView];
                         [self addDownloadingFailedView];
                     }
                 }
            }
        } else {
            [self removeDownloadingView];
            [self addDownloadingFailedView];
        }
    } else {
        NSMutableDictionary* dic = fecther.userData;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* lessonPath = [dic objectForKey:STRING_KEY_LESSONPATH];
        NSString* dataPath = [dic objectForKey:STRING_KEY_DATAPATH];
        NSString* courseTitle = [dic objectForKey:STRING_KEY_COURSETITLE];
        NSString* lessonFile = [dic objectForKey:STRING_KEY_LESSONFILE];
        NSString* xatFile = [lessonFile substringToIndex:[lessonFile length] - 4];
        //NSNumber* indexNumber = [dic objectForKey:STRING_KEY_TRYSERVERLIST];
        V_NSLog(@"try list %d", [indexNumber integerValue]);
        
        NSString* fileType = [dic objectForKey:STRING_KEY_FILETYPE];
        if ([fileType isEqualToString:STRING_KEY_FILETYPE_XAT]) {
            xatFile = [xatFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_XAT];
            _bDownloadedXAT = YES;
         } else if ([fileType isEqualToString:STRING_KEY_FILETYPE_ISB]) {
            xatFile = [xatFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_ISB];
             _bDownloadedISB = YES;
        }
        NSString* path = [NSString stringWithFormat:@"%@/%@/%@",dataPath, courseTitle, lessonPath];
        
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
         NSString* filePath = [NSString stringWithFormat:@"%@/%@", path, xatFile];
        V_NSLog(@"write path: %@", filePath);
        [data writeToFile:filePath atomically:YES];
        
        if (_bDownloadedISB && _bDownloadedXAT) {
            [self removeDownloadingView];
            [self displayLesson];
        }
    }
    
}

#pragma collapse cell
-(int)numberOfCellsForCollapseClick {
    return [self.sentencesArray count];
}

-(UIView *)viewForCollapseClickAtIndex:(int)index {

    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ListeningCell" owner:self options:nil];
    ListeningCell *cell = [array objectAtIndex:0];
    [cell layoutCell];
    
    int nTeacher = 0;
    Teacher* teacher1 = nil;
    Teacher* teacher2 = nil;
    NSInteger section = index;
    Sentence * sentence = [self.sentencesArray objectAtIndex:section];
    if ([self.teachersArray count] > 1) {
        teacher1 = [self.teachersArray objectAtIndex:0];
        if ([teacher1.teacherid isEqualToString:sentence.techerid]) {
            nTeacher = 1;
        } else {
            nTeacher = 2;
        }
    } else {
        if (section % 2 == 0) {
            nTeacher = 1;
        } else {
            nTeacher = 2;
        }
    }
    ConfigData* configData = [ConfigData sharedConfigData];
    NSString* teacherfemale1 = configData.nTeacherHeadStyle == 0 ? @"female_a@2x.png" :@"female_b@2x.png";
    NSString* teachermale1 = configData.nTeacherHeadStyle == 0 ? @"male_a@2x.png" :@"male_b@2x.png";;
    NSString* teacherfemale2 = configData.nTeacherHeadStyle == 0 ?@"male_a@2x.png" :@"male_b@2x.png";
    NSString* teachermale2 = configData.nTeacherHeadStyle == 0 ? @"female_a@2x.png" :@"female_b@2x.png";
    switch (nTeacher) {
        case 1:
        {
            NSString* imagePath = nil;
            if ([[teacher1 gender] isEqualToString:@"female"]) {
                imagePath = [[NSString alloc] initWithFormat:@"%@/%@%@", resourcePath, @"teachers/", teacherfemale1];
            } else {
                imagePath = [[NSString alloc] initWithFormat:@"%@/%@%@", resourcePath, @"teachers/", teachermale1];
            }
            UIImage* im = [UIImage imageWithContentsOfFile:imagePath];
            cell.teatcherImageView.image = im;
            [imagePath release];
        }
            
            break;
        case 2:
        {
            NSString* imagePath = nil;
            if ([[teacher1 gender] isEqualToString:@"female"]) {
                imagePath =  [[NSString alloc] initWithFormat:@"%@/%@%@", resourcePath, @"teachers/", teacherfemale1];
            } else {
                imagePath =  [[NSString alloc] initWithFormat:@"%@/%@%@", resourcePath, @"teachers/", teachermale1];
            }
            if ([[teacher2 gender] isEqualToString:@"female"]) {
                imagePath = [[NSString alloc] initWithFormat:@"%@/%@%@", resourcePath, @"teachers/", teacherfemale2];
            } else {
                imagePath = [[NSString alloc] initWithFormat:@"%@/%@%@", resourcePath, @"teachers/", teachermale2];
            }
            
            UIImage* im = [UIImage imageWithContentsOfFile:imagePath];
            cell.teatcherImageView.image = im;
            [imagePath release];
            break;
        }
        default:
            NSString* imagePath = [[NSString alloc] initWithFormat:@"%@/%@%@", resourcePath, @"teachers/", teacherfemale1];
            UIImage* im = [UIImage imageWithContentsOfFile:imagePath];
            cell.teatcherImageView.image = im;
            [imagePath release];
            break;
    }
    [cell setMsgText:sentence.orintext withTrans:sentence.transtext];
    
    return cell;
}

- (UIView *)viewForCollapseClickContentViewAtIndex:(int)index {
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 134 * 2)];
    Sentence * sentence = [self.sentencesArray objectAtIndex:index];        
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RecordingWaveCell" owner:self options:nil];
    
    RecordingWaveCell *cellPlay = [array objectAtIndex:0];
    UIImage* itemImage = [UIImage imageNamed:@"Btn_Play@2x.png"];
    
    [cellPlay.playingButton setImage:itemImage forState:UIControlStateNormal];
    cellPlay.playingButton.tag = PLAY_SRC_VOICE_BUTTON_TAG;
    cellPlay.sentence = (id)sentence;
    cellPlay.waveView.starttime = [sentence startTime] * 1000;
    cellPlay.waveView.endtime = [sentence endTime] *1000;
    cellPlay.waveView.wavefilename = wavefile;
    //[cell.waveView loadwavedatafromTime];
    cellPlay.selectionStyle = UITableViewCellSelectionStyleNone;
    cellPlay.delegate = (id)self;
    cellPlay.waveView.bReadfromTime = YES;
    [cellPlay.waveView setNeedsLayout];
    cellPlay.timelabel.text = [NSString stringWithFormat:@"Time: %.2f",[sentence endTime] - [sentence startTime]];
    [contentView addSubview:cellPlay];
    
        
    array = [[NSBundle mainBundle] loadNibNamed:@"RecordingWaveCell" owner:self options:nil];
    RecordingWaveCell *cell = [array objectAtIndex:0];
    cell.frame = CGRectMake(0, cellPlay.frame.size.height, cellPlay.frame.size.width, cellPlay.frame.size.height);
    cell.waveView.layer.borderWidth = 1;
    cell.waveView.layer.borderColor = [[UIColor whiteColor] CGColor];
        //cell.backgroundColor = [UIColor colorWithRed:f green:f blue:f alpha:1.0];
    cell.backgroundColor = [UIColor whiteColor];
    itemImage = [UIImage imageNamed:@"Btn_Record@2x.png"];
    
    cell.playingUpButton.hidden = NO;
    cell.playingDownButton.hidden = NO;
    cell.playingButton.hidden = YES;
    [cell.playingUpButton setImage:itemImage forState:UIControlStateNormal];
    cell.playingUpButton.tag = RECORDING_USER_VOICE_BUTTON_TAG;
    
    itemImage = [UIImage imageNamed:@"Btn_Play@2x.png"];
    [cell.playingDownButton setImage:itemImage forState:UIControlStateNormal];
    cell.playingDownButton.tag = PLAY_USER_VOICE_BUTTON_TAG;
    cell.playingDownButton.enabled = NO;

    cell.delegate = (id)self;
    NSString *recordFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"recordedFile.wav"];
    /*NSFileManager *mgr = [NSFileManager defaultManager];
    if ([mgr fileExistsAtPath:recordFile isDirectory:nil]) {
        cell.playingButton.enabled = YES;
    } else {
        cell.playingButton.enabled = NO;
    }
       */ 
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //recordCell = cell;
    cell.waveView.bReadfromTime = NO;
    cell.waveView.wavefilename = recordFile;
    [cell.waveView setNeedsLayout];
    [contentView addSubview:cell];
    return contentView;
}


-(void)didClickCollapseClickCellAtIndex:(int)index isNowOpen:(BOOL)open {
    NSLog(@"%d and it's open:%@", index, (open ? @"YES" : @"NO"));
}

- (void)playing:(NSInteger)buttonTag withSentence:(id)sen
{
    switch (buttonTag) {
        case PLAY_SRC_VOICE_BUTTON_TAG:
        {
            Sentence* sentence = (Sentence*)sen;
            NSTimeInterval inter = [sentence endTime] - self.player.currentTime;
            UInt32 doChangeDefaultRoute = 1;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                     sizeof (doChangeDefaultRoute),
                                     &doChangeDefaultRoute);
            [self.player play];
            [self performSelector:@selector(pausePlaying) withObject:self afterDelay:inter];
        }
            break;
        case PLAY_USER_VOICE_BUTTON_TAG:
        {
            
        }
            break;
        case RECORDING_USER_VOICE_BUTTON_TAG:
        {
            
        }
            break;

        default:
            break;
    }
}

- (void)pausePlaying
{
    [self.player pause];
}

@end