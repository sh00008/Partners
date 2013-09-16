//
//  LessonsViewController.m
//  Say
//
//  Created by JiaLi on 11-7-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LessonsViewController.h"
#import "ListeningViewController.h"
#import "SettingViewController.h"
#import "LessonCell.h"
#import "ConfigData.h"
#import "VoiceDef.h"
#import "Globle.h"
#import "DMCustomModalViewController.h"
//#import "MobiSageSDK.h"

@implementation LessonsViewController
@synthesize scenesName = _scenesName;
@synthesize pageSegment = _pageSegment;
@synthesize dataPath;
@synthesize delegate;
@synthesize pkgName;
@synthesize lessonTableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    nSelectedPage = 0;
    
    ConfigData* configData = [ConfigData sharedConfigData];
    nPageCount = IS_IPAD ?configData.nPageCountOfiPad :configData.nPageCountOfiPhone;
    _lastRow = nil;
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[_courseParser release];
    [self.scenesName release];
    //[_daybayday release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)loadView 
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString* backString = STRING_BACK;
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [backItem release];
    [self loadCourses];
    ConfigData* configData = [ConfigData sharedConfigData];
    if (configData.bPagination) {
        if ([_courseParser.course.lessons count] > nPageCount) {
            [self loadToolbarItems];
        } else {
           configData.bPagination = NO;
        }
    } 
    
    if (configData.bLessonViewAsRootView) {
        NSString* displayName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleDisplayName"];
        self.title = displayName;
        UIBarButtonItem* itemSetting = [[UIBarButtonItem alloc] initWithTitle:STRING_SETTING
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(onSetting:)];
        self.navigationItem.rightBarButtonItem = itemSetting;
        
        [itemSetting release];        
        /*if (_daybayday == nil) {
            _daybayday = [[DayByDayObject alloc] init];
            _daybayday.navigationController = self.navigationController;
            [_daybayday performSelector:@selector(loadDaybyDayView) withObject:nil afterDelay:0.2];
        }*/
    }
    self.lessonTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSString* resourcePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Image"]];
    UIImage* bkimage = [[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/background_gray.png", resourcePath]] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bkimage];
    self.lessonTableView.backgroundColor = [UIColor colorWithPatternImage:bkimage];
    [resourcePath release];
    if (!IS_IPAD) {
        CGFloat screenOfheight =  ([[UIScreen mainScreen] bounds].size.height) ;
        CGFloat height =  (screenOfheight - (screenOfheight == 568 ? (64+20+40) : 15)) * 0.8;
        self.lessonTableView.frame = CGRectMake(0, 0, self.lessonTableView.frame.size.width, height);
    } else {
        CGFloat screenOfheight =  ([[UIScreen mainScreen] bounds].size.height) ;
        CGFloat height =  (screenOfheight - 696) * 0.8;
        self.lessonTableView.frame = CGRectMake(0, 0, self.lessonTableView.frame.size.width, height);
       
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.lessonTableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
{
    [self.lessonTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    ConfigData* configData = [ConfigData sharedConfigData];
    
    if (configData.bADLesson) {
        return IS_IPAD ? 60 : 40;
    } else {
        return 0;
    }
}

// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    return nil;
    ConfigData* configData = [ConfigData sharedConfigData];
    if (!configData.bADLesson) {
        return nil;
    }
    UIView* header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)] autorelease];
    [header setBackgroundColor:[UIColor clearColor]];
   /* MobiSageAdBanner * adBanner = [[MobiSageAdBanner alloc] initWithAdSize:IS_IPAD? Ad_748X60: Ad_320X40];
    adBanner.frame = CGRectMake((self.view.bounds.size.width - adBanner.frame.size.width)/2, 0, adBanner.frame.size.width, adBanner.frame.size.height);
    adBanner.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    //设置广告轮显方式
    [header addSubview:adBanner];
    [adBanner release];*/
    return header;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    ConfigData* configData = [ConfigData sharedConfigData];
    if (!(configData.bPagination)) {
        return [_courseParser.course.lessons count];
    } else {
        NSInteger nCount = (nSelectedPage+1) * nPageCount;
        if (nCount <= [_courseParser.course.lessons count]) {
            return nPageCount;
        } else {
            return (nPageCount - (nCount - [_courseParser.course.lessons count]));
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    static NSString *CellIdentifier = @"LessonCell";
    
    LessonCell *cell = (LessonCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[LessonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }else {
        [cell cleanUp];
    }
    
    ConfigData* configData = [ConfigData sharedConfigData];
    NSInteger nPostion = nSelectedPage * nPageCount + indexPath.row;
    if (!(configData.bPagination)) {
        nPostion = indexPath.row;
    }
    if (nPostion < [_courseParser.course.lessons count]) {
        Lesson * lesson = [_courseParser.course.lessons objectAtIndex:nPostion];
         cell.nStyle =configData.nLessonCellStyle;
        cell.lessonTitle = lesson.title;
        cell.useDarkBackground = (nPostion % 2 == 0);
        cell.nIndex = nPostion;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (_lastRow != nil && _lastRow.row == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;

        }
    } else {
        UITableViewCell * cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LessonCellBlank"] autorelease];
        return cell;
        
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConfigData* configData = [ConfigData sharedConfigData];
    if (configData.bPagination) {
        NSInteger nPostion = nSelectedPage*nPageCount + indexPath.row;
        if (nPostion < ([_courseParser.course.lessons count])) {
            LessonCell *cell = (LessonCell*)[self tableView: tableView cellForRowAtIndexPath: indexPath];
            
            CGFloat width = self.view.bounds.size.width - WIDTH_OF_OFFSET;
            CGSize size   = [Globle calcTextHeight:cell.lessonTitle withWidth:width];
            NSLog(@"heightForRow pos %d  widht %f height %f", indexPath.row, size.width, size.height);
            return size.height;
            
        } else {
            return 44;
        }

    } else {
        
        LessonCell *cell = (LessonCell*)[self tableView: tableView cellForRowAtIndexPath: indexPath];
        CGFloat width = self.view.bounds.size.width - WIDTH_OF_OFFSET;
        CGSize size   = [Globle calcTextHeight:cell.lessonTitle withWidth:width];
         return size.height+20;
    }
}


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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_lastRow != nil) {
        UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:_lastRow];
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    _lastRow = indexPath;
    [_lastRow retain];
    [self dismissModal];
    ListeningViewController *detailViewController = [[ListeningViewController alloc] initWithNibName:@"ListeningViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    ConfigData* configData = [ConfigData sharedConfigData];
    NSInteger nPostion = 0;
    if (configData.bPagination) {
        nPostion = nSelectedPage*nPageCount + indexPath.row;
    } else {
        nPostion = indexPath.row;
    }
    if (nPostion < ([_courseParser.course.lessons count])) {
        detailViewController.nPositionInCourse = nPostion;
        detailViewController.courseParser = _courseParser;
        detailViewController.delegate = (id)self;
  		[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_ADDNEWNAVI object: detailViewController];
        [detailViewController release];
    }

    

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)loadCourses
{
    if (_courseParser != nil) {
        return;
    }
    _courseParser = [[CourseParser alloc] init];
    
	// Load and parse the books.xml file
    /*NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* stringResource = STRING_RESOURCE_DATA;
    resourcePath = [NSString stringWithFormat:@"%@/%@", resourcePath, stringResource];*/
    NSString* resourcePath;
    if (self.scenesName != nil) {
        resourcePath = [NSString stringWithFormat:@"/%@/%@", self.dataPath, self.scenesName];
    }
    NSString* indexString = STRING_LESSONS_INDEX_XML;
    _courseParser.resourcePath = resourcePath;
    [_courseParser loadCourses:indexString];
 }

- (void) loadToolbarItems;
{
    self.navigationController.toolbarHidden = NO;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    // Flexible Space
    UIBarButtonItem* itemFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    // Flexed Space
    UIBarButtonItem* itemFlexedSpaceSmall = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    itemFlexedSpaceSmall.width = 5;
    
    // Flexed Space
    UIBarButtonItem* itemFlexedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    
    itemFlexedSpace.width = IS_IPAD ? 35.0 : 2.0;
    /*itemFlexedSpace.width = [[UIDevice currentDevice] userInterfaceIdiom] == [UIUserInterfaceIdiomPad]? 35.0 : 20.0;*/
    
    [items addObject:itemFlexibleSpace];
    
    // Previous
    [items addObject:itemFlexedSpaceSmall];
    UIBarButtonItem* itemPrevious = [[UIBarButtonItem alloc] initWithTitle:STRING_PRE_PAGE
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(onPrevious:)];
    [items addObject:itemPrevious];
    //self.previousItem = itemPrevious;
    [itemPrevious release];
    
    // playImage
    [items addObject:itemFlexedSpace];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger nMode = [_courseParser.course.lessons count] % nPageCount;
    NSInteger nCountTemp =[_courseParser.course.lessons count] / nPageCount;
    NSInteger nCount = nMode == 0 ? nCountTemp : (nCountTemp + 1);
    for (NSInteger i = 0; i < nCount; i++) {
        [array addObject:[NSString stringWithFormat:@"    %d    ", (i+1)]];
    }
    UISegmentedControl* seg = [[UISegmentedControl alloc] initWithItems:array];
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    ConfigData* configData = [ConfigData sharedConfigData];
    seg.tintColor = [UIColor colorWithRed:configData.naviRed green:configData.naviGreen blue:configData.naviBlue alpha:1.0];
    [array release];
    UIBarButtonItem* itemPlay = [[UIBarButtonItem alloc] initWithCustomView:seg];
    [items addObject:itemPlay];
    [seg addTarget:self action:@selector(onSelectedPage:) forControlEvents:UIControlEventValueChanged];
    self.pageSegment = seg;
    self.pageSegment.selectedSegmentIndex = nSelectedPage;
    self.pageSegment.momentary = NO;
    [itemPlay release];
    
    // nextImage
    [items addObject:itemFlexedSpace];
    UIBarButtonItem* itemNext = [[UIBarButtonItem alloc] initWithTitle:STRING_NEXT_PAGE
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(onNext:)];
    [items addObject:itemNext];
    //self.nextItem = itemNext;
    [itemNext release];
    
    
    
    [items addObject:itemFlexedSpaceSmall];
    [items addObject:itemFlexibleSpace];
    
    [itemFlexibleSpace release];
    [itemFlexedSpace release];
    [itemFlexedSpaceSmall release];
    [self setToolbarItems:items animated:YES];
    [items release];
    
}

- (void) onPrevious:(id)sender;
{
    if (nSelectedPage > 0) {
        nSelectedPage --;
        self.pageSegment.selectedSegmentIndex = nSelectedPage;
        [self.lessonTableView reloadData];
    }
}

- (void) onNext:(id)sender;
{
    NSInteger nSegmentNum = self.pageSegment.numberOfSegments;
    if (nSelectedPage < (nSegmentNum-1)) {
        nSelectedPage ++;
        self.pageSegment.selectedSegmentIndex = nSelectedPage;
        [self.lessonTableView reloadData];
    }
    
}

- (void) onSelectedPage:(id)sender;
{
    NSInteger nSelected = self.pageSegment.selectedSegmentIndex;
    if (nSelected != nSelectedPage) {
        nSelectedPage = nSelected;
        [self.lessonTableView reloadData];
    }
}

- (void) onSetting:(id)sender;
{
    SettingViewController* setting = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    
    NSString* settingTitle = STRING_SETTING_TITLE;
    setting.title = settingTitle;
    [self.navigationController pushViewController:setting animated:YES];
    [setting release];
}

- (NSString*)getPkgTitle
{
    return self.pkgName;
}

- (NSString*)getCourseTitle;
{
    return self.scenesName;
}

- (void)dismissModal
{
    //if you import DMCustomModalViewController.h in you modal root controller it add some magic to it
    //you can freely access your DMCustomModalViewController
    [self.customModalViewController dismissRootViewControllerWithcompletion:^{
        
    }];
}

@end
