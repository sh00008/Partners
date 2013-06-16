//
//  ButtonPlayObject.m
//  Partners
//
//  Created by JiaLi on 13-6-15.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "ButtonPlayObject.h"
@interface ButtonPlayObject ()
{
    NSTimer *timer;
}


@end

@implementation ButtonPlayObject
@synthesize durTime, position;

- (void)dealloc
{
    [timer invalidate];
    self.progressview = nil;
    [super dealloc];
}

- (void) play
{
    if(timer)
        return;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
}
- (void) pause
{
    [timer invalidate];
    timer = nil;
    self.progressview = nil;
}

- (void) timerDidFire:(NSTimer *)theTimer
{
    if(self.position >= 1.0)
    {
        self.position = 0.0;
        [timer invalidate];
        timer = nil;
        //[self.delegate playerDidStop:self];
        self.progressview.progress = 0.0;
    }
    else
    {
        self.position += 0.1/durTime;
        self.progressview.progress = self.position;
        //[self.delegate player:self didReachPosition:self.position];
    }
}


@end
