//
//  RecordingObject.m
//  Partners
//
//  Created by JiaLi on 13-6-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "RecordingObject.h"
#import "Word.h"
//弹出信息
#define ALERT(msg) [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show]

@implementation RecordingObject

- (int)scoreForSentence:(Sentence*)sentence file:(NSString*)filename
{
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
    
    NSLog([NSString stringWithFormat:@"%d, %d", n, nOffset]);
    
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
    
    tempString = [tempString stringByAppendingFormat:@"Score: %d", score];
    ALERT(tempString);
    return score;
}

@end
