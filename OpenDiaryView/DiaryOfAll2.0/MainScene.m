//
//  MainScene.m
//  DiaryOfAll_MAC
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "MainScene.h"


@implementation MainScene

@synthesize calendarLayer;
@synthesize dayLayer;
-(id) init{
    self = [super init];
    if(self){
        calendarLayer = [[CalendarLayer alloc]init];
        dayLayer      = [[DayLayer alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.contentSize.width,250)];
        [self addChild:calendarLayer];
        [self addChild:dayLayer];
    }
    return self;
}
-(void) dealloc{
    [self.calendarLayer release];
    [self.dayLayer release];
    [super dealloc];
}
@end
