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
#import "ButtonPlayObject.h"
#import "CurrentInfo.h"
#import "CustomViewController.h"
#import "UIViewController+MJPopupViewController.h"

#define LOADINGVIEWTAG      20933
#define WAITINGVIEWTAG      20934
#define DOWNLOADINGVIEWTAG  20936
#define FAILEDRECORDINGVIEW_TAG 45505
#define PLAY_SRC_VOICE_BUTTON_TAG 50001
#define PLAY_USER_VOICE_BUTTON_TAG 50002
#define RECORDING_USER_VOICE_BUTTON_TAG 50003

#define RECORDING_WAVE_CELL_TAG 20001
#define PLAYINGSRC_WAVE_CELL_TAG 20002

#define FONT_SIZE_OF_SRC    22
#define FONT_SIZE_OF_TRANS    14

#define STRING_KEY_LESSONFILE @"lessonFile"
#define STRING_KEY_DATAPATH @"dataPath"
#define STRING_KEY_COURSETITLE @"title"
#define STRING_KEY_LESSONPATH @"lessonPath"
#define STRING_KEY_TRYSERVERLIST @"tryServerListIndex"
#define STRING_KEY_FILETYPE @"fileType"
#define STRING_KEY_FILETYPE_XIN @"xin"
#define STRING_KEY_FILETYPE_ISB @"isb"
#define STRING_KEY_FILETYPE_LES @"les"
#define HEIGHT_OF_WAVECELL      122
#define HEIGHT_OF_LISTENINGCELL 107
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
@synthesize readeButton, practiceButton;

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
        nLesson = settingData.eReadingMode == READING_MODE_WHOLE_TEXT ?  PLAY_LESSON : PLAY_READING_FLOWME;
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(willEnterToBackground:) name:NOTI_WILLENTERFOREGROUND object:nil];
        nLastScrollPos = 0;
        bInit = NO;
        bParseWAV = NO;
        resourcePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Image"]];
        _recording = [[RecordingObject alloc] init];
        [_recording setAddInView:self.view];
        _bReadFlowMe = NO;
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
    if (_downloadLessonObj) {
        [_downloadLessonObj release];
        _downloadLessonObj = nil;
    }
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
    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    Database* db = [Database sharedDatabase];
    [db setPkgListendwithPath:lib.currentPkgDataPath];
    lastClickIndex = -1;
    clickindex = -1;
    NSString* backString = STRING_BACK;
    [self.sentencesTableView setBackgroundView:nil];
    [self.sentencesTableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    [self.sentencesTableView setBackgroundColor:UIColor.clearColor];
    
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStyleBordered target:nil action:nil];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backItem;
    [backItem release];
    
    
    [self addWaitingView:WAITINGVIEWTAG withText:STRING_WAITING_TEXT withAnimation:YES];
  
    
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

   [self performSelector:@selector(initDownload) withObject:nil afterDelay:1.0];
}

- (void)initDownload;
{
    UIView* loadingView = [self.view viewWithTag:WAITINGVIEWTAG];
    if (loadingView != nil) {
        [loadingView removeFromSuperview];
    }
    if (![self downloadLesson]) {
        return;
    }
    
    if ([_downloadLessonObj isDownloaed]) {
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
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = lesson.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    //self.navigationItem.title = lesson.title;
    
    
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
        didSection = -1;
        [self performSelector:@selector(firstOneClicked) withObject:self afterDelay:0.2f];
//        [self.listeningToolbar enableToolbar:YES];
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
        bOrinWave = YES;
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
    didSection = -1;
    [self performSelector:@selector(firstOneClicked) withObject:self afterDelay:0.2f];
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
//        [self setStatusPause];
        Sentence* sentence = [self.sentencesArray objectAtIndex:nPosition];
        self.player.currentTime = [sentence startTime];
//        [self updateUI];
    }
    if (self.player) {
        [self.player stop];
    }
    
   [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CLOSE_LESSONS object:nil];
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
	height = fmax(height, HEIGHT_OF_LISTENINGCELL);
	return height;
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
    if (_downloadLessonObj == nil) {
        _downloadLessonObj = [[DownloadLesson alloc] init];
    }
    _downloadLessonObj.nPositionInCourse = self.nPositionInCourse;
    _downloadLessonObj.courseParser = self.courseParser;
    _downloadLessonObj.delegate = (id)self;
    if ([_downloadLessonObj checkIsNeedDownload]) {
        [self addDownloadingView];
    }
    return YES;
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
    [self removeDownloadingView];
    [self displayLesson];

}
- (void)downloadfailed:(DownloadLesson*)download {
    [self removeDownloadingView];
    [self addDownloadingFailedView];
   
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
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, HEIGHT_OF_WAVECELL * 2)];
    Sentence * sentence = [self.sentencesArray objectAtIndex:index];        
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RecordingWaveCell" owner:self options:nil];
    
    RecordingWaveCell *cellPlay = [array objectAtIndex:0];
    cellPlay.tag = PLAYINGSRC_WAVE_CELL_TAG;
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
    cell.tag = RECORDING_WAVE_CELL_TAG;
    cell.frame = CGRectMake(0, cellPlay.frame.size.height, cellPlay.frame.size.width, cellPlay.frame.size.height);
    cell.waveView.layer.borderWidth = 1;
    cell.waveView.layer.borderColor = [[UIColor whiteColor] CGColor];
        //cell.backgroundColor = [UIColor colorWithRed:f green:f blue:f alpha:1.0];
    cell.backgroundColor = [UIColor whiteColor];
    itemImage = [UIImage imageNamed:@"Btn_Record@2x.png"];
    cell.sentence = (id)sentence;
   
    cell.playingUpButton.hidden = NO;
    cell.playingDownButton.hidden = NO;
    cell.playingButton.hidden = YES;
    [cell.playingUpButton setImage:itemImage forState:UIControlStateNormal];
    cell.playingUpButton.tag = RECORDING_USER_VOICE_BUTTON_TAG;
    
    itemImage = [UIImage imageNamed:@"Btn_Play@2x.png"];
    [cell.playingDownButton setImage:itemImage forState:UIControlStateNormal];
    cell.playingDownButton.enabled = NO;
    cell.playingDownButton.tag = PLAY_USER_VOICE_BUTTON_TAG;

    cell.delegate = (id)self;
    NSString *recordFile = [self getRecordingFilePath:index];
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
    if (open) {
        if ((lastClickIndex != -1) && (lastClickIndex != index)) {
            [self.collpaseLesson closeCollapseClickCellAtIndex:lastClickIndex animated:NO];
        }
       lastClickIndex = clickindex;
       clickindex = index;
        CollapseClickCell* wholeCell = [self.collpaseLesson collapseClickCellForIndex:clickindex];
        
        UIView* contentView = [wholeCell.ContentView viewWithTag:102];
        CGFloat animationTime = 0.1;
        if (contentView != nil) {
            RecordingWaveCell* playingSrcCell = (RecordingWaveCell*)[contentView viewWithTag:PLAYINGSRC_WAVE_CELL_TAG];
            if (playingSrcCell != nil) {
                UIView* playingbutton =[playingSrcCell viewWithTag:PLAY_SRC_VOICE_BUTTON_TAG];
                if (playingbutton != nil) {
                    [self performSelector:@selector(playAnimationWithView:) withObject:playingbutton afterDelay:animationTime];
                }
            }
            RecordingWaveCell* recoringCell = (RecordingWaveCell*)[contentView viewWithTag:RECORDING_WAVE_CELL_TAG];
            if (recoringCell != nil) {
                UIView* recoringbutton =recoringCell.playingUpButton;
                if (recoringbutton != nil) {
                    [self performSelector:@selector(playAnimationWithView:) withObject:recoringbutton afterDelay:animationTime];
                }
                
                UIView* playingbutton = recoringCell.playingDownButton;
                if (playingbutton != nil) {
                    //[self playAnimationWithView:playingbutton];
                    [self performSelector:@selector(playAnimationWithView:) withObject:playingbutton afterDelay:animationTime];
               }
            }
            
        }
         [self.collpaseLesson scrollToCollapseClickCellAtIndex:index animated:YES];
   }
    

    V_NSLog(@"%d and it's open:%@", index, (open ? @"YES" : @"NO"));
}

- (void)playAnimationWithView:(UIView*)viewWillAnimation
{
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    theAnimation.duration = 0.3;
    theAnimation.autoreverses = NO;
    theAnimation.fromValue = [NSNumber numberWithFloat:0.2];
    theAnimation.toValue = [NSNumber numberWithFloat:1.0];
    [viewWillAnimation.layer addAnimation:theAnimation forKey:nil];
}

- (void)playing:(NSInteger)buttonTag withSentence:(id)sen withCell:(RecordingWaveCell *)cell
{
    switch (buttonTag) {
        case PLAY_SRC_VOICE_BUTTON_TAG:
        {
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: wavefile];
            AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
            [fileURL release];
            
            self.player = newPlayer;
            bOrinWave = YES;
            [player prepareToPlay];
            [player setDelegate:(id<AVAudioPlayerDelegate>)self];
            [newPlayer release];
            Sentence* sentence = (Sentence*)sen;
            self.player.currentTime = [sentence startTime];
            cell.playingButton.enabled = NO;
            NSTimeInterval inter = [sentence endTime] - self.player.currentTime;
             UInt32 doChangeDefaultRoute = 1;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                     sizeof (doChangeDefaultRoute),
                                     &doChangeDefaultRoute);
            [self.player play];
            if (_buttonPlay == nil) {
               _buttonPlay = [[ButtonPlayObject alloc] init];

            }
            _buttonPlay.progressview = cell.progressView;
            _buttonPlay.durTime = inter;
            [_buttonPlay play];
            [self performSelector:@selector(pausePlaying:) withObject:cell afterDelay:inter];
        }
            cell.progressUpView.hidden = YES;
            cell.progressDownView.hidden = YES;
           break;
        case PLAY_USER_VOICE_BUTTON_TAG:
        {
            Sentence* sentence = (Sentence*)sen;
            NSString* recordingFilePath = [self getRecordingFilePath:clickindex];
            [_recording start:recordingFilePath];
             NSTimeInterval inter = [sentence endTime] - [sentence startTime] + 0.3;
          if (_buttonPlay == nil) {
                _buttonPlay = [[ButtonPlayObject alloc] init];
                
            }
            cell.progressDownView.hidden = NO;
            _buttonPlay.progressview = cell.progressDownView;
            _buttonPlay.durTime = inter;
            [_buttonPlay play];
            
            cell.progressUpView.hidden = YES;
            cell.progressView.hidden = YES;
            
            
            NSString *recordFile = recordingFilePath;
            NSFileManager* mgr = [NSFileManager defaultManager];
            if ([mgr fileExistsAtPath:recordFile]) {
                
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:recordFile];
                AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
                [fileURL release];
                self.player = newPlayer;
                bOrinWave = NO;
                [player prepareToPlay];
                [player setDelegate:(id<AVAudioPlayerDelegate>)self];
                [newPlayer release];
                self.player.currentTime = timeStart;
                self.player.volume = 5.0;
            }
            
        }
            break;
        case RECORDING_USER_VOICE_BUTTON_TAG:
        {
            [self cleanScoreImageView];
            Sentence* sentence = (Sentence*)sen;
            NSString* recordingFilePath = [self getRecordingFilePath:clickindex];
            [_recording start:recordingFilePath];
            cell.playingUpButton.enabled = NO;
            cell.playingDownButton.enabled = NO;
            NSTimeInterval inter = [sentence endTime] - [sentence startTime] + 0.3;
            if (_buttonPlay == nil) {
                _buttonPlay = [[ButtonPlayObject alloc] init];
                
            }
            cell.progressUpView.hidden = NO;
            _buttonPlay.progressview = cell.progressUpView;
            _buttonPlay.durTime = inter;
            [_buttonPlay play];
            cell.progressDownView.hidden = YES;
            cell.progressView.hidden = YES;
            [self performSelector:@selector(stopRecording:) withObject:cell afterDelay:inter];
          
        }
            break;

        default:
            break;
    }
}

- (void)pausePlaying:(RecordingWaveCell *)cell
{
    [self.player pause];
    cell.playingButton.enabled = YES;
    
}

- (void)stopRecording:(RecordingWaveCell *)cell
{
    [_recording stop];
    cell.playingUpButton.enabled = YES;
    NSString *recordFile = [self getRecordingFilePath:clickindex];
    NSFileManager* mgr = [NSFileManager defaultManager];
    if ([mgr fileExistsAtPath:recordFile]) {
        cell.playingDownButton.enabled = YES;
    }
   if (cell != nil) {
        cell.waveView.wavefilename = recordFile;
        [cell.waveView loadwavedata];
        cell.timelabel.text = [NSString stringWithFormat:@"Time: %.2f", cell.waveView.dwavesecond];
    }
    NSMutableDictionary* scoreDic = [[NSMutableDictionary alloc] init];
    int score = [RecordingObject scoreForSentence:cell.sentence file:recordFile toResult:scoreDic];
    CollapseClickCell* wholeCell = [self.collpaseLesson collapseClickCellForIndex:clickindex];
    ListeningCell* header = (ListeningCell*)[wholeCell.TitleView viewWithTag:101];
    if (header != nil) {
        NSMutableArray* words = [scoreDic objectForKey:@"words"];
        if (words != nil) {
            [header changeTextColor:words];
        }
        if (nLesson == PLAY_READING_FLOWME) {
            [_scroeArray addObject:@(score)];
        }
        [header showScore:score];
    }
    [scoreDic release];
    
    if (nLesson == PLAY_READING_FLOWME) {
        Sentence* sentence = [_sentencesArray objectAtIndex:clickindex];
        NSTimeInterval inter = [sentence endTime] - [sentence startTime];
        if ((clickindex + 1) < [self.sentencesArray count]) {
            clickindex++;
            [self performSelector:@selector(startNextPractice) withObject:nil afterDelay:inter];
        } else {
            ePlayStatus = PLAY_STATUS_NONE;
            [self finishedFllowMe];
        }
    }
}

- (void)cleanScoreImageView
{
    CollapseClickCell* wholeCell = [self.collpaseLesson collapseClickCellForIndex:clickindex];
    ListeningCell* header = (ListeningCell*)[wholeCell.TitleView viewWithTag:101];
    if (header != nil) {
        [header resetCellState];
    }
}

- (void)playWholeLesson
{
    if (self.player == nil) {
        return;
    }
    
    if (bOrinWave) {
        if (nLesson == PLAY_LESSON) {
            [self playfromCurrentPos];
        }
        else {
            self.player.currentTime = 0;
            self.player.volume = 5.0;
            [self playfromCurrentPos];
        }
    }
    else
    {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: wavefile];
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
        [fileURL release];
        
        self.player = newPlayer;
        bOrinWave = YES;
        [player prepareToPlay];
        [player setDelegate:(id<AVAudioPlayerDelegate>)self];
        [newPlayer release];
        self.player.currentTime = 0;
        self.player.volume = 5.0;
        clickindex = 0;
        [self playfromCurrentPos];
    }
}

- (IBAction)readwholelesson:(id)sender;
{
    clickindex = 0;
    [practiceButton setImage:[UIImage imageNamed:@"Btn_Play_S@2x.png"] forState:UIControlStateNormal];
    switch (ePlayStatus) {
        case PLAY_STATUS_NONE:
            ePlayStatus = PLAY_STATUS_PLAYING;
            [readeButton setImage:[UIImage imageNamed:@"Btn_Pause_S@2x.png"] forState:UIControlStateNormal];
            [self playWholeLesson];
            break;
        case PLAY_STATUS_PAUSING:
            ePlayStatus = PLAY_STATUS_PLAYING;
            [readeButton setImage:[UIImage imageNamed:@"Btn_Pause_S@2x.png"] forState:UIControlStateNormal];
            [self playWholeLesson];
            break;
        case PLAY_STATUS_PLAYING:
            ePlayStatus = PLAY_STATUS_PAUSING;
            [readeButton setImage:[UIImage imageNamed:@"Btn_Play_S@2x.png"] forState:UIControlStateNormal];
            if (self.player) {
                [self.player pause];
            }
            break;
        default:
            break;
    }
    nLesson = PLAY_LESSON;
}

- (IBAction)practicewholelesson:(id)sender;
{
    [_scroeArray release];
    _scroeArray = nil;
    _scroeArray = [[NSMutableArray alloc] init];
    V_NSLog(@"practicewholelesson %d", clickindex);
   [readeButton setImage:[UIImage imageNamed:@"Btn_Play_S@2x.png"] forState:UIControlStateNormal];
    switch (ePlayStatus) {
        case PLAY_STATUS_NONE:
            ePlayStatus = PLAY_STATUS_PLAYING;
            [practiceButton setImage:[UIImage imageNamed:@"Btn_Pause_S@2x.png"] forState:UIControlStateNormal];
            [self playWholeLesson];
            break;
        case PLAY_STATUS_PAUSING:
            ePlayStatus = PLAY_STATUS_PLAYING;
            [practiceButton setImage:[UIImage imageNamed:@"Btn_Pause_S@2x.png"] forState:UIControlStateNormal];
            [self playWholeLesson];
            break;
        case PLAY_STATUS_PLAYING:
            ePlayStatus = PLAY_STATUS_PAUSING;
            [practiceButton setImage:[UIImage imageNamed:@"Btn_Play_S@2x.png"] forState:UIControlStateNormal];
            if (self.player) {
                [self.player pause];
            }
            break;
        default:
            break;
    }

    nLesson = PLAY_READING_FLOWME;
}

- (void)playfromCurrentPos
{
    if (ePlayStatus != PLAY_STATUS_PLAYING) {
        [self.player pause];
        return;
    }
    
    if (clickindex < [_sentencesArray count]) {
        [self updateUI];
        Sentence* sentence = [_sentencesArray objectAtIndex:clickindex];
        NSTimeInterval inter = [sentence endTime] - self.player.currentTime;
        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                 sizeof (doChangeDefaultRoute),
                                 &doChangeDefaultRoute);
        [self.player play];
        [self performSelector:@selector(pauseintime) withObject:self afterDelay:inter];
    }
    else {
        [self.player play];
    }
}

- (void)updateUI
{
    [self.collpaseLesson openCollapseClickCellAtIndex:clickindex animated:YES];

}

- (void)finishedFllowMe {
    CustomViewController* customController = [[CustomViewController alloc] initWithNibName:@"CustomViewController" bundle:nil];
    NSInteger score = 0;
    NSInteger av = 0;
    for (NSInteger i = 0; i < [_scroeArray count]; i++) {
        av = [[_scroeArray objectAtIndex:i] intValue];
        av = (av + score)/2;
        score = av;
    }
    customController.showTitle = [NSString stringWithFormat:@"%@%d", STRING_FINISHREADINGFOLLOWME, score];
    [self presentPopupViewController:customController animationType:MJPopupViewAnimationSlideBottomTop];
    [self performSelector:@selector(dimissFinishFllowMe:) withObject:customController afterDelay:1.0];
}

- (void)dimissFinishFllowMe:(UIViewController*)controlloer {
    [controlloer dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)myplayer successfully:(BOOL)flag
{
    if (flag) {
        if (nLesson == PLAY_LESSON || nLesson == PLAY_READING_FLOWME) {
            ePlayStatus = PLAY_STATUS_PLAYING;
            myplayer.currentTime = 0;
            [practiceButton setImage:[UIImage imageNamed:@"Btn_Play_S@2x.png"] forState:UIControlStateNormal];
            [readeButton setImage:[UIImage imageNamed:@"Btn_Play_S@2x.png"] forState:UIControlStateNormal];           
        }
    }
}

- (void)pauseintime;
{
    if (ePlayStatus != PLAY_STATUS_PLAYING) {
        return;
    }
    
    Sentence* sentence = [_sentencesArray objectAtIndex:clickindex];
    NSTimeInterval inter = [sentence endTime] - [sentence startTime];
    if (nLesson == PLAY_LESSON) {
        // reading lesson.
        [self.player pause];
        if (clickindex < ([_sentencesArray count] - 1)) {
            clickindex++;
            sentence = [_sentencesArray objectAtIndex:clickindex];
            self.player.currentTime = [sentence startTime];
            [self performSelector:@selector(playfromCurrentPos) withObject:self afterDelay:(settingData.dTimeInterval+inter)];
        } 
    } else {
        // reading and practice.
        [self.player pause];
        if (clickindex < ([_sentencesArray count] - 1)) {
             sentence = [_sentencesArray objectAtIndex:clickindex];
            self.player.currentTime = [sentence startTime];
            [self performSelector:@selector(showReadyRecording:) withObject:[NSNumber numberWithInt:clickindex] afterDelay:(settingData.dTimeInterval+inter)];
            clickindex++;
        }
    }
}

- (void)showReadyRecording:(NSNumber*)clickNumber
{
    UILabel* ready = [[UILabel alloc] initWithFrame:self.view.bounds];
    ready.backgroundColor = [UIColor clearColor];
    ready.font = [UIFont fontWithName:@"Arial" size:60];
    ready.textAlignment = NSTextAlignmentCenter;
    ready.tag = READYRECORDINGVIEW_TAG;
    ready.text = STRING_READY_RECORDING;
    [self.view addSubview:ready];
    [ready release];
    
    /*CustomViewController* showReadyRecording = [[CustomViewController alloc] initWithNibName:@"CustomViewController" bundle:nil];
    showReadyRecording.titleView.text = STRING_READY_RECORDING;
    [self presentPopupViewController:showReadyRecording animationType:MJPopupViewAnimationSlideBottomTop];
     */
    NSMutableDictionary* dicValue = [[NSMutableDictionary alloc] init];
    [dicValue setObject:ready forKey:@"view"];
    [dicValue setObject:clickNumber forKey:@"index"];
    [self performSelector:@selector(playRecordingAnimationWithView:) withObject:dicValue afterDelay:1];
}

- (void)playRecordingAnimationWithView:(NSMutableDictionary*)dicValue
{
    if (dicValue == nil) {
        return;
    }
    
    UILabel* viewWillAnimation = [dicValue objectForKey:@"view"];
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    theAnimation.duration = 0.3;
    theAnimation.autoreverses = NO;
    viewWillAnimation.text = STRING_RECORDING_TEXT;
    //viewWillAnimation.text = [NSString stringWithFormat:@"%d", [number integerValue]];
    theAnimation.fromValue = [NSNumber numberWithFloat:0.2];
    theAnimation.toValue = [NSNumber numberWithFloat:1.0];
    theAnimation.delegate = (id)self;
    [theAnimation setValue:@"practiceforready" forKey:@"id"];
    if ([dicValue objectForKey:@"index"] != nil) {
        [theAnimation setValue:[dicValue objectForKey:@"index"] forKey:@"index"];
    }
    viewWillAnimation.tag = READYRECORDINGVIEW_TAG;
   [viewWillAnimation.layer addAnimation:theAnimation forKey:@"transform.scale"];
    [dicValue release];
    
}


- (void)animationDidStop:(CAAnimation *)theAnimation2 finished:(BOOL)flag {
    CABasicAnimation *theAnimation = (CABasicAnimation*)theAnimation2;
    NSString* valueKey = [theAnimation valueForKey:@"id"];
    if([valueKey isEqual:@"practiceforready"]) {
        NSNumber* clickNum = [theAnimation valueForKey:@"index"];
        if (clickNum == nil) {
            return;
        }
        NSInteger index = [clickNum intValue];
        // start recording
        CollapseClickCell* wholeCell = [self.collpaseLesson collapseClickCellForIndex:index];
        
        UIView* contentView = [wholeCell.ContentView viewWithTag:102];
        if (contentView != nil) {
            RecordingWaveCell* recoringCell = (RecordingWaveCell*)[contentView viewWithTag:RECORDING_WAVE_CELL_TAG];
            Sentence* sentence = [_sentencesArray objectAtIndex:index];
            // recording, stop recording in this function:
            clickindex = index;
            [self playing:RECORDING_USER_VOICE_BUTTON_TAG withSentence:sentence withCell:recoringCell];
        }
    }
}
- (void)startNextPractice
{
    V_NSLog(@"startNextPractice %d", clickindex);
    UILabel* t = (UILabel*)[self.view viewWithTag:READYRECORDINGVIEW_TAG];
    [t removeFromSuperview];
    [self.collpaseLesson openCollapseClickCellAtIndex:clickindex animated:YES];
    ePlayStatus = PLAY_STATUS_NONE;
    [self practicewholelesson:nil];
}

- (NSString*)getRecordingFilePath:(NSInteger)nIndex {
    NSRange r = [self.wavefile rangeOfString:@"." options:NSBackwardsSearch];
    if (r.location != NSNotFound) {
        NSString* path = [self.wavefile substringToIndex:r.location];
        NSString* recordingPath = [NSString stringWithFormat:@"%@_%d.wav", path, nIndex];
        return recordingPath;
    }
    return @"";
}
@end
