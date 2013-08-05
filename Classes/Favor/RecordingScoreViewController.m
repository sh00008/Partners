//
//  RecordingScoreViewController.m
//  Partners
//
//  Created by JiaLi on 13-8-5.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "RecordingScoreViewController.h"
#import "Database.h"
#import "VoicePkgInfoObject.h"
#import "VoiceDef.h"
@interface RecordingScoreViewController ()
{
    NSMutableArray* _scoreArray;
}
@end

@implementation RecordingScoreViewController
@synthesize scoreTable;
@synthesize waveFile;
@synthesize naviBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage* bk = IS_IPAD ? [UIImage imageNamed:@"4-light-menu-barPad_P.png"] :[UIImage imageNamed:@"4-light-menu-bar.png"];
    if([ self.naviBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [ self.naviBar setBackgroundImage:bk forBarMetrics:UIBarMetricsDefault];
    }
    self.naviBar.tintColor = [UIColor grayColor];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = STRING_RECORDING_INFO;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Arial" size:22];
    self.naviBar.topItem.titleView = titleLabel;
    [titleLabel release];
    
   if (_scoreArray == nil) {
        Database* db = [Database sharedDatabase];
        _scoreArray = [db loadRecordingInfo:self.waveFile];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearRecordingScore:(id)sender {
    Database* db = [Database sharedDatabase];
    [db clearAllRecordingInfo:self.waveFile];
    [self.scoreTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_scoreArray count];
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"scoreCell"];
    NSInteger i = indexPath.row;
    if (i < [_scoreArray count]) {
        RecordingInfo* info = [_scoreArray objectAtIndex:i];
        cell.textLabel.text = [NSString stringWithFormat:@" %d", info.score];
        cell.detailTextLabel.text = info.date;
    }
    return [cell autorelease];
}
@end
