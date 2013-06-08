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
#import "isaybio.h"
#import "ConfigData.h"
#import "VoiceDef.h"
#import "GTMHTTPFetcher.h"
#import "Database.h"
#import "ListeningCell.h"
#import "RecordingWaveCell.h"

#define LOADINGVIEWTAG      20933
#define DOWNLOADINGVIEWTAG  20936
#define FAILEDRECORDINGVIEW_TAG 45505
#define PLAY_SRC_VOICE_BUTTON_TAG 50001
#define PLAY_USER_VOICE_BUTTON_TAG 50002
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
         //SettingViewController* setting = (SettingViewController*)[self.tabBarController.viewControllers objectAtIndex:1];
        
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
    loadingText.textAlignment  = UITextAlignmentCenter;
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
    [isaybio ISB_Isb:strisbfile toWav:strwavefile];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sentencesArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == didSection) {
        return 2;
    }
    return 0;
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


// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ListeningCell" owner:self options:nil];
    ListeningCell *cell = [array objectAtIndex:0];
    [cell layoutCell];
    
     int nTeacher = 0;
    Teacher* teacher1 = nil;
    Teacher* teacher2 = nil;
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
            cell.teatcherImageView.image = [UIImage imageWithContentsOfFile:imagePath];
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
            
            cell.teatcherImageView.image = [UIImage imageWithContentsOfFile:imagePath];
            [imagePath release];
            break;
        }
        default:
            NSString* imagePath = [[NSString alloc] initWithFormat:@"%@/%@%@", resourcePath, @"teachers/", teacherfemale1];
            cell.teatcherImageView.image = [UIImage imageWithContentsOfFile:imagePath];
            [imagePath release];
            break;
    }
    [cell setMsgText:sentence.orintext withTrans:sentence.transtext];
    UIButton* selectButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [selectButton setTag:section];
    [selectButton addTarget:self action:@selector(openCell:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:selectButton];
    [selectButton release];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Sentence * sentence = [self.sentencesArray objectAtIndex:indexPath.section];
   if (indexPath.row == 0) {
           
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RecordingWaveCell" owner:self options:nil];
       
       RecordingWaveCell *cell = [array objectAtIndex:0];
        UIImage* itemImage = [UIImage imageNamed:@"Btn_Play@2x.png"];
        
        [cell.playingButton setImage:itemImage forState:UIControlStateNormal];
        cell.playingButton.tag = PLAY_SRC_VOICE_BUTTON_TAG;
        UIImage *iconImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/teachers/male1.png", resourcePath]];
        CGFloat f = 211.0/255.0;
        cell.waveView.layer.borderWidth = 1;
        cell.waveView.layer.borderColor = [[UIColor whiteColor] CGColor];
        //cell.backgroundColor = [UIColor colorWithRed:f green:f blue:f alpha:1.0];
        cell.icon.image = iconImage;
        /*cell.waveView.starttime = 0;
         cell.waveView.endtime = 1*1000;
         cell.waveView.wavefilename = [NSString stringWithFormat:@"%@/recordedFile.wav", resourcePath];*/
        
        cell.waveView.starttime = [sentence startTime] * 1000;
        cell.waveView.endtime = [sentence endTime] *1000;
        cell.waveView.wavefilename = wavefile;
        //[cell.waveView loadwavedatafromTime];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = (id)self;
        cell.waveView.bReadfromTime = YES;
        [cell.waveView setNeedsLayout];
        cell.timelabel.text = [NSString stringWithFormat:@"Time: %.2f",[sentence endTime] - [sentence startTime]];
        return cell;
        
        
    } else {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RecordingWaveCell" owner:self options:nil];
        RecordingWaveCell *cell = [array objectAtIndex:0];

        cell.waveView.layer.borderWidth = 1;
        cell.waveView.layer.borderColor = [[UIColor whiteColor] CGColor];
        //cell.backgroundColor = [UIColor colorWithRed:f green:f blue:f alpha:1.0];
        cell.backgroundColor = [UIColor whiteColor];
        UIImage* itemImage = [UIImage imageNamed:@"Btn_Record@2x.png"];
        [cell.playingButton setImage:itemImage forState:UIControlStateNormal];
        cell.playingButton.tag = PLAY_USER_VOICE_BUTTON_TAG;
        UIImage *iconImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/recording.png", resourcePath]];
        cell.icon.image = iconImage;
        cell.delegate = (id)self;
        NSFileManager *mgr = [NSFileManager defaultManager];
        NSString *recordFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"recordedFile.wav"];
        if ([mgr fileExistsAtPath:recordFile isDirectory:nil]) {
            cell.playingButton.enabled = YES;
        } else {
            cell.playingButton.enabled = NO;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //recordCell = cell;
        cell.waveView.bReadfromTime = NO;
        cell.waveView.wavefilename = recordFile;
        [cell.waveView setNeedsLayout];
        return cell;
    }
}

- (void)firstOneClicked{
    didSection = 0;
    endSection = 0;
    [self didSelectCellRowFirstDo:YES nextDo:NO];
}

- (void)addCell:(UIButton *)bt{
    endSection = bt.tag;
    if (didSection == self.sentencesArray.count+1) {
        ifOpen = NO;
        didSection = endSection;
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    else{
        if (didSection == endSection) {
            [self didSelectCellRowFirstDo:NO nextDo:NO];
        }
        else{
            [self didSelectCellRowFirstDo:NO nextDo:YES];
        }
    }
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert{
    [self.sentencesTableView beginUpdates];
    ifOpen = firstDoInsert;
    NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:didSection];
    [rowToInsert addObject:indexPath];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:didSection];
    [rowToInsert addObject:indexPath1];
    if (!ifOpen) {
        didSection = self.sentencesArray.count + 1;
        [self.sentencesTableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [self.sentencesTableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationFade];
    }
    [rowToInsert release];
    [self.sentencesTableView endUpdates];
    if (nextDoInsert) {
        didSection = endSection;
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    [self.sentencesTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != didSection) {
        return 0;
    }
    
	return 107.0f;
}

/*- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
    // create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(2, 0.0, self.view.bounds.size.width, 5.0)] autorelease];
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 5.0;
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (int)getSentenceIndex:(NSTimeInterval)time
{
    Sentence* sentence = nil;
    for (int i = 0; i < [_sentencesArray count]; i++) {
        sentence = [_sentencesArray objectAtIndex:i];
        if (time < [sentence endTime]) {
           // NSLog(@"%d", i);
            return i;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*Sentence* sentence = [self.sentencesArray objectAtIndex:indexPath.section];
  
    NSIndexPath * lastpath = [NSIndexPath indexPathForRow:0  inSection:nLastScrollPos];
    BubbleCell* cell = (BubbleCell*)[self.sentencesTableView cellForRowAtIndexPath:lastpath];
    [cell setIsHighlightText:NO];
    nPosition = indexPath.section;
    
    [_sentencesTableView scrollToRowAtIndexPath:indexPath
                               atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    cell = (BubbleCell*)[self.sentencesTableView cellForRowAtIndexPath:indexPath];
    [cell setIsHighlightText:YES];
    nLastScrollPos = nPosition;
    self.player.currentTime = [sentence startTime];
    RecordingViewController *detailViewController = [[RecordingViewController alloc] initWithNibName:@"RecordingViewController" bundle:nil];
    detailViewController.recordingdelegate = (id)self;
    detailViewController.sentence = sentence;
    detailViewController.nPos = nPosition;
    detailViewController.nTotalCount = [_sentencesArray count];
    detailViewController.wavefile = wavefile;
    detailViewController.resourcePath = resourcePath;
    [self updateUI];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];*/
 }

#pragma Action
- (IBAction)onOther:(id)sender;
{
    /*ListeningVolumView* volumView = (ListeningVolumView*)[self.view viewWithTag:(NSInteger)VOLUMNVIEW_TAG];
    if (volumView != nil) {
        return;
    }
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ListeningVolumView" owner:self options:NULL];
    if ([array count] > 0) {
        volumView = [array objectAtIndex:0];
        volumView.frame = self.view.frame;
        volumView.centerView.center = CGPointMake(self.view.center.x, self.view.center.y - 25);
        volumView.viewDelegate = (id)self;
        [volumView loadResource];
        [volumView setVolumnDisplay:fVolumn];
        volumView.tag = VOLUMNVIEW_TAG;
        [self.view addSubview:volumView];
    }*/
}

- (IBAction)onPrevious:(id)sender;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    nCurrentReadingCount = 0;
    ePlayStatus = PLAY_STATUS_PLAYING;
    if (nPosition > 0) {
        [self highlightCell:(nPosition-1)];
        nLastScrollPos = nPosition-1;
        nPosition = nPosition - 1;
        Sentence* sentence = [_sentencesArray objectAtIndex:nPosition];
        player.currentTime = [sentence startTime];
        [self updateUI];
        [self playfromCurrentPos];
    }
}

- (IBAction)onNext:(id)sender;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    nCurrentReadingCount = 0;
    ePlayStatus = PLAY_STATUS_PLAYING;
    if (nPosition < [_sentencesArray count] - 1) {
        ePlayStatus = PLAY_STATUS_PLAYING;
        // scroll to cell
        [self highlightCell:(nPosition+1)];
        nPosition = nPosition + 1;
        Sentence* sentence = [_sentencesArray objectAtIndex:nPosition];
        player.currentTime = [sentence startTime];
        [self updateUI];
        [self playfromCurrentPos];
    }
}

- (void)scrollCell
{
    if (bAlReadyPaused) {
        return;
    }
    int nCurrentIndex = [self getSentenceIndex:self.player.currentTime];
    
   if (nLesson == PLAY_SENTENCE) {
        if (nCurrentIndex != nPosition) {
            bAlReadyPaused = YES;
            // NSLog(@"pause sentence");
            [player pause];
            Sentence* sentence = [_sentencesArray objectAtIndex:nPosition];
            NSTimeInterval inter = [sentence endTime] - [sentence startTime];
            inter = inter + inter * 0.1;
            
            [NSTimer scheduledTimerWithTimeInterval:inter target:self selector:@selector(continueReading) userInfo:nil repeats:NO];
            
            if (nCurrentReadingCount == settingData.nReadingCount) {
                // scroll to cell
                [self highlightCell:nCurrentIndex];
                nPosition = nCurrentIndex;
                nCurrentReadingCount = 0;
                // NSLog(@"scroll to cell %d", nCurrentIndex);
            } 
            

            // set the time Interval
        } else if (nCurrentIndex == nPosition) {
            [self highlightCell:nPosition];
        }

    } else {
        if (nCurrentIndex != nPosition) {
            // scroll to cell
            
            bAlReadyPaused = YES;
            [self highlightCell:nCurrentIndex];
            NSInteger nLast = nPosition;
            nPosition = nCurrentIndex;
            
            // set the time Interval
            [player pause];
            if (nLast == ([_sentencesArray count] - 1) && !settingData.bLoop) {
                ePlayStatus = PLAY_STATUS_NONE;
                [player stop];
                bAlReadyPaused = NO;
                //self.listeningToolbar.playItem.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/play.png", resourcePath]];
                [self updateUI];
                
            } else {
                [NSTimer scheduledTimerWithTimeInterval:settingData.dTimeInterval target:self selector:@selector(continueReading) userInfo:nil repeats:NO];
            }
        } else if (nCurrentIndex == nPosition) {
            // scroll to cell
            [self highlightCell:nCurrentIndex];
        }
    }
}

- (IBAction)onStart:(id)sender;
{
    Sentence* sentence = [_sentencesArray objectAtIndex:nPosition];
    loopstarttime = [sentence startTime];
    loopendtime = [sentence endTime];    
    switch (ePlayStatus) {
        case PLAY_STATUS_NONE:
        {
            [self highlightCell:nPosition];
            player.currentTime = [sentence startTime];
            ePlayStatus = PLAY_STATUS_PLAYING;
            nCurrentReadingCount = 0;
       }
            break;
        case PLAY_STATUS_PLAYING:
        {
            [self setStatusPause];
        }
            break;
        case PLAY_STATUS_PAUSING:
        {
            ePlayStatus = PLAY_STATUS_PLAYING;
        }
            break;
        default:
            break;
    }
    [self updateUI];
    [self playfromCurrentPos];
}

- (void)onRecording;
{
    /*Sentence* sentence = [self.sentencesArray objectAtIndex:nPosition];
    RecordingViewController *detailViewController = [[RecordingViewController alloc] initWithNibName:@"RecordingViewController" bundle:nil];
    detailViewController.recordingdelegate = (id)self;
    detailViewController.sentence = sentence;
    detailViewController.nPos = nPosition;
    detailViewController.nTotalCount = [_sentencesArray count];
    detailViewController.wavefile = wavefile;
    detailViewController.resourcePath = resourcePath;
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
*/
}

- (IBAction)onSetting:(id)sender;
{
    SettingViewController* setting = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    
    NSString* settingTitle = STRING_SETTING_TITLE;
    setting.title = settingTitle;
    [self.navigationController pushViewController:setting animated:YES];
    [setting release];
}

- (IBAction)onGotoSentence:(id)sender;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    nCurrentReadingCount = 0;
    CGFloat v = self.progressBar.value - 1;
    nPosition = (v - 1);
    ePlayStatus = PLAY_STATUS_PLAYING;
    nPosition = v;
    Sentence* sentence = [_sentencesArray objectAtIndex:nPosition];
    loopstarttime = [sentence startTime];
    loopendtime = [sentence endTime];    
    player.currentTime = loopstarttime;
    [self updateUI];
    [self playfromCurrentPos];
}

- (IBAction)onChangingGotoSentence:(id)sender;
{
    NSInteger v = (NSInteger)self.progressBar.value;
    nPosition = (v - 1);
    if (ePlayStatus == PLAY_STATUS_PLAYING) {
        [self setStatusPause];
    }
    [self highlightCell:nPosition];
    [self updateUI];
}

#pragma mark - Update timer

- (void)updateCurrentTime
{
    if (ePlayStatus != PLAY_STATUS_PLAYING) {
        return;
    }
        
    [self scrollCell];
//    self.listeningToolbar.previousItem.enabled = (nPosition != 0);
//    self.listeningToolbar.nextItem.enabled = ((nPosition + 1) != [_sentencesArray count]);
}

- (void)continueReading
{
    if (ePlayStatus == PLAY_STATUS_PLAYING) {
        if (nLesson == PLAY_SENTENCE) {
            if (nCurrentReadingCount != settingData.nReadingCount) {
                nCurrentReadingCount++;
                // NSLog(@"nCurrentReadingCount++");
                Sentence* sentence = [_sentencesArray objectAtIndex:nPosition];
                player.currentTime = [sentence startTime];
            }
            // NSLog(@"reading Count %d", nCurrentReadingCount);
        }
        bAlReadyPaused = NO;
        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                 sizeof (doChangeDefaultRoute),
                                 &doChangeDefaultRoute); 
       [player play];            
    
        [self updateUI];
    }
}

- (void)highlightCell:(NSInteger)nPos;
{
    /*
    if (nLastScrollPos != nPos) {
        NSIndexPath * lastpath = [NSIndexPath indexPathForRow:0  inSection:nLastScrollPos];
        BubbleCell* cell = (BubbleCell*)[self.sentencesTableView cellForRowAtIndexPath:lastpath];
        if (cell != nil && [cell isKindOfClass:[BubbleCell class]]) {
            // interrupted somtimes.
            [cell setIsHighlightText:NO];
        }
    }
    
    NSIndexPath * path = [NSIndexPath  indexPathForRow:0  inSection:nPos];
    if (nLastScrollPos != nPos) {
        [_sentencesTableView scrollToRowAtIndexPath:path
                                   atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    BubbleCell* cell = (BubbleCell*)[self.sentencesTableView cellForRowAtIndexPath:path];
    [cell setIsHighlightText:YES];
    nLastScrollPos = nPos;*/
}

- (void)updateUI
{
    //self.listeningToolbar.previousItem.enabled = (nPosition != 0);
   // self.listeningToolbar.nextItem.enabled = ((nPosition + 1) != [_sentencesArray count]);
	progressBar.value = nPosition + 1;
    self.senCount.text = [NSString stringWithFormat:@"%d / %d ", nPosition + 1, [self.sentencesArray count]];
    if (nLesson == PLAY_LESSON && settingData.bLoop) {
        self.player.numberOfLoops = -1;
    } else {
        self.player.numberOfLoops = 1;
    }
    
    if (ePlayStatus == PLAY_STATUS_PLAYING) {
      //  self.listeningToolbar.playItem.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/pause.png", resourcePath]];
    } else {
       // self.listeningToolbar.playItem.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/play.png", resourcePath]];
    }
   
}

- (void)updateViewForPlayer
{
    if (nLesson == PLAY_LESSON && settingData.bLoop) {
        self.player.numberOfLoops = -1;
    } else {
        self.player.numberOfLoops = 1;
    }
    
    if (ePlayStatus == PLAY_STATUS_PLAYING) {
      //  self.listeningToolbar.playItem.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/pause.png", resourcePath]];
    } else {
     //   self.listeningToolbar.playItem.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/play.png", resourcePath]];
    }
    
       
	if (updateTimer) 
		[updateTimer invalidate];

    updateTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    
}
- (void)setVolumn:(CGFloat)fV;
{
    fVolumn = fV;
}

- (void)finishedRemovePromptAnimation:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
    [UIView setAnimationDelegate:nil];
   // ListeningVolumView* volumView = (ListeningVolumView*)[self.view viewWithTag:(NSInteger)VOLUMNVIEW_TAG];
    //if (volumView != nil) {
    //    [volumView removeFromSuperview];
    //}
}

#pragma Notifications
- (void)settingChanged:(NSNotification *)aNotification
{
    [settingData loadSettingData];
    if (settingData.bLoop && nLesson == PLAY_LESSON) {
        self.player.numberOfLoops = -1;
    } else {
        self.player.numberOfLoops = 1;
    }
    
    if (settingData.eReadingMode == 0) {
        // 设置起始终止时间
        loopstarttime = 0.0;
        loopendtime = self.player.duration;
        nLesson = PLAY_LESSON;
   } else {
       // 设置单句起始和终止时间
       int nCurrentIndex = [self getSentenceIndex:self.player.currentTime];
       Sentence* sentence = [_sentencesArray objectAtIndex:nCurrentIndex];
       loopstarttime = [sentence startTime];
       loopendtime = [sentence endTime];    
       nLesson = PLAY_SENTENCE;
    }
    [self reloadTableView];
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

#pragma Toolbar
- (BOOL)isPlaying
{
    return (ePlayStatus == PLAY_STATUS_PLAYING);
}

- (BOOL)isLesson
{
    return (nLesson == PLAY_LESSON);
}

- (void)reloadTableView;
{
    [self highlightCell:nPosition];
    [self.sentencesTableView reloadData];
}

- (Sentence*)getSentencefromPos:(NSInteger)pos;
{
    if (pos > -1 && pos < [_sentencesArray count]) {
        Sentence* sentence = [_sentencesArray objectAtIndex:pos];
        return sentence;
    }

    return nil;
}

- (void)playfromCurrentPos;
{
    if (ePlayStatus != PLAY_STATUS_PLAYING) {
        return;
    }
    if (nLesson != PLAY_LESSON) {
        nCurrentReadingCount++;
    } 
    [self highlightCell:nPosition];
    [self updateUI];
    Sentence* sentence = [_sentencesArray objectAtIndex:nPosition];
    NSTimeInterval inter = [sentence endTime] - self.player.currentTime;
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                             sizeof (doChangeDefaultRoute),
                             &doChangeDefaultRoute); 
    [self.player play];
    [self performSelector:@selector(pauseintime) withObject:self afterDelay:inter];
    //[NSTimer scheduledTimerWithTimeInterval:inter target:self selector:@selector(pauseintime) userInfo:nil repeats:NO];        
}

- (void)pauseintime;
{
    if (ePlayStatus != PLAY_STATUS_PLAYING) {
        return;
    }
    
    Sentence* sentence = [_sentencesArray objectAtIndex:nPosition];
    NSTimeInterval inter = [sentence endTime] - [sentence startTime];
    if (nLesson == PLAY_LESSON) {
        [self.player pause];
        if (nPosition < ([_sentencesArray count] - 1)) {
            nPosition++;
            sentence = [_sentencesArray objectAtIndex:nPosition];
            self.player.currentTime = [sentence startTime];
            [self performSelector:@selector(playfromCurrentPos) withObject:self afterDelay:settingData.dTimeInterval];
           
            //[NSTimer scheduledTimerWithTimeInterval:(settingData.dTimeInterval) target:self selector:@selector(playfromCurrentPos) userInfo:nil repeats:NO];        
        } else {
            if (settingData.bLoop) {
                nPosition = 0;
                sentence = [_sentencesArray objectAtIndex:nPosition];
                self.player.currentTime = [sentence startTime];
                [self performSelector:@selector(playfromCurrentPos) withObject:self afterDelay:settingData.dTimeInterval];
            } else {
                [self setStatusPause];
                [self updateUI];
                nPosition = 0;
                sentence = [_sentencesArray objectAtIndex:nPosition];
                self.player.currentTime = [sentence startTime];
            }

            //[NSTimer scheduledTimerWithTimeInterval:(settingData.dTimeInterval) target:self selector:@selector(playfromCurrentPos) userInfo:nil repeats:NO];        
           
        }
    } else {
        [self.player pause];
        self.player.currentTime = [sentence startTime];
        if (nCurrentReadingCount < settingData.nReadingCount) {
          // [NSTimer scheduledTimerWithTimeInterval:inter target:self selector:@selector(playfromCurrentPos) userInfo:nil repeats:NO];        
            [self performSelector:@selector(playfromCurrentPos) withObject:self afterDelay:inter];

        } else {
            nCurrentReadingCount = 0;
            if (nPosition < ([_sentencesArray count] - 1)) {
                nPosition++;
                sentence = [_sentencesArray objectAtIndex:nPosition];
                self.player.currentTime = [sentence startTime];
                //[NSTimer scheduledTimerWithTimeInterval:inter target:self selector:@selector(playfromCurrentPos) userInfo:nil repeats:NO]; 
                [self performSelector:@selector(playfromCurrentPos) withObject:self afterDelay:inter];

            } else {
                ePlayStatus = PLAY_STATUS_NONE;
                [self updateUI];
            }
          
        }
    }
}

- (void)setStatusPause;
{
    [self highlightCell:nPosition];
    ePlayStatus = PLAY_STATUS_PAUSING;
    [player pause];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
        NSNumber* indexNumber = [dic objectForKey:STRING_KEY_TRYSERVERLIST];
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

- (void)openCell:(id)sender;
{
    UIButton* button = (UIButton*)sender;
    endSection = button.tag;
    if (didSection == self.sentencesArray.count + 1) {
        ifOpen = NO;
        didSection = endSection;
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    else{
        if (didSection == endSection) {
            [self didSelectCellRowFirstDo:NO nextDo:NO];
        }
        else{
            [self didSelectCellRowFirstDo:NO nextDo:YES];
        }
    }
}

@end
