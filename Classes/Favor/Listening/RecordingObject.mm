//
//  RecordingObject.m
//  Partners
//
//  Created by JiaLi on 13-6-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "RecordingObject.h"
#import <QuartzCore/QuartzCore.h>
#import "Word.h"
#import "isaybiosscroe.h"
#import "VoiceDef.h"
//弹出信息
#define ALERT(msg) [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show]
char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4] = {""}, *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

@implementation RecordingObject

+ (int)scoreForSentence:(Sentence*)sentence file:(NSString*)filename toResult:(NSMutableDictionary*)scoreDictionary
{
    // Score
    ISAYB5WORD * pWord;
    int nWord;
    int score;
   FILE* file = fopen([filename cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    
    fseeko(file, 0, SEEK_END);
    long fileLength = ftell(file);
    
    fseeko(file, 0, SEEK_SET);
    short *buffer = (short*)new char[fileLength];
    
    int n = fread(buffer, 1, fileLength, file);
    // 跳到data数据区
    int nOffset = 2046;
    
    if (strncmp((char*)&buffer[nOffset - 2], "data", 4) != 0) {
        char * p = (char*) &buffer[0];
        nOffset = 0;
        while (strncmp(p, "data", 4) != 0) {
            nOffset += 2;
            p += 4;
        }
        //        p += 4;
        nOffset += 2;
    }
    
    NSLog(@"%d, %d", n, nOffset);
    
    [isaybios ISAYB_Recognition:[sentence.orintext cStringUsingEncoding:NSUTF8StringEncoding]
                           From:&buffer[nOffset]
                         Length:(n / 2) - nOffset
                             To: &pWord
                         Length: &nWord
                       AndScore: &score];
    
    delete[] buffer;
    
    NSString* tempString = [NSString stringWithFormat:@"<%@>得分：\n", sentence.orintext];
    score = 0;
    for(int i = 0;i < [sentence.words count]; i++)
    {
        Word* word = [sentence.words objectAtIndex:i];
        NSComparisonResult cr = [[word text] compare:[NSString stringWithCString:pWord[i].text encoding:NSUTF8StringEncoding] options:NSCaseInsensitiveSearch];
        if (cr == NSOrderedSame) {
            double time = [word.endtime doubleValue] - [word.starttime doubleValue];
            double per = time - (pWord[i].fTimeEd - pWord[i].fTimeSt) / time;
            score += (30 * (1 - fabs(per)) + 70) / nWord;
            printf("%f %f %s\n",pWord[i].fTimeSt - pWord[i].fTimeEd, time, pWord[i].text);
            printf("%d \n", score);
        }
        tempString = [tempString stringByAppendingFormat:@"%f -> %f : %s\n", pWord[i].fTimeSt,pWord[i].fTimeEd, pWord[i].text];
    }
    
    //tempString = [tempString stringByAppendingFormat:@"Score: %d", score];
    //ALERT(tempString);
    [scoreDictionary setObject:@(score) forKey:@"score"];
    return score;
}

- (void)start
{
    BOOL bOK = recorder->StartRecord(CFSTR("recordedFile.wav"));
    
    
    [self setFileDescriptionForFormat:recorder->DataFormat() withName:@"Recorded File"];
    if (!bOK) {
        [self addFailedRecordingView];
        recorder->StopRecord();
        [NSTimer scheduledTimerWithTimeInterval: 3 target: self selector:@selector(removeFailedRecordingView) userInfo: nil repeats: NO];
    }

}
-(void)setFileDescriptionForFormat: (CAStreamBasicDescription)format withName:(NSString*)name
{
	char buf[5];
	const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
	NSString* description = [[NSString alloc] initWithFormat:@"(%d ch. %s @ %g Hz)", (unsigned int)(format.NumberChannels()), dataFormat, format.mSampleRate, nil];
	//fileDescription.text = description;
	[description release];
}

- (void)addFailedRecordingView:(UIView*)toView;
{
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    loadingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    loadingView.layer.cornerRadius = 8;
    loadingView.tag = FAILEDRECORDINGVIEW_TAG;
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    UILabel* loadingText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, loadingView.frame.size.width, 20)];
    loadingText.textColor = [UIColor whiteColor];
    loadingText.text = STRING_RECORDING_ERROR;
    loadingText.font = [UIFont systemFontOfSize:14];
    loadingText.backgroundColor = [UIColor clearColor];
    loadingText.textAlignment  = NSTextAlignmentCenter;
    loadingText.center = loadingView.center;
    [loadingView addSubview:loadingText];
    [loadingText release];
    loadingView.center = toView.center;
    [toView addSubview:loadingView];
    [loadingView release];
    
}

- (void)stop
{
  	recorder->StopRecord();
  
}
@end
