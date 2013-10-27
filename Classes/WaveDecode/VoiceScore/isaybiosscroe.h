//
//  isaybios.h
//  isaybios
//
//  Created by kouyuhuoban on 13-3-23.
//  Copyright (c) 2013年 Isayb. All rights reserved.
//

#import <Foundation/Foundation.h>

struct ISAYB6WORDSCORE
{
	char text[128];
	char pronun[128];
	float curve[40];
	float fTimeSt;
	float fTimeEd;
	float fScore;
};

@interface isaybios : NSObject

{
    
}

+(bool) ISAYB_SetModel:(const char * )model;
+(bool) ISAYB_SetLesson:(const char *)filename;
+(bool) ISAYB_Recognition:(const char *)sentence From:(short *)pWAV Length:(int)nWAV  To:(ISAYB6WORDSCORE **)ppWORD Length:(int *)pnWORD AndScore:(int*)pscore;

@end
