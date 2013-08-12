//
//  ButtonPlayObject.h
//  Partners
//
//  Created by JiaLi on 13-6-15.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CERoundProgressView.h"
#define NOTI_STOP_ANIMITIONPRESS_RIGHTNOW      @"StopPressAnimitionRightNowNotification"

@interface ButtonPlayObject : NSObject
- (void) play;
- (void) pause;
@property (assign) float durTime;  
@property (assign) float position;
@property (assign) CERoundProgressView* progressview;

@end
