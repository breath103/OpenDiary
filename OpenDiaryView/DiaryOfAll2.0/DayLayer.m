//
//  DayLayer.m
//  DiaryOfAll_MAC
//
//  Created by 이상현 on 12. 9. 21..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "DayLayer.h"
#import "DiaryEvent.h"
#import "NSObject+block.h"
#import "CCSprite+autoscale.h"

#define DAY_EVENT_ROW (5)
#define LEFT_FRAME_SIZE (250)
#define DAY_COL_WIDTH ( ( 1280 - 250) /2.0)


@implementation DayLayer
@synthesize currentDayView;
@synthesize patternLockSprite;
-(id) initWithFrame : (CGRect) frame{
    self = [super init];
    if(self)
    {
        self.anchorPoint = ccp(0,0);
        self.contentSize = frame.size;
        self.position    = frame.origin;
        patternLockSprite = [[PatternLockSprite alloc]initWithFrame:CGRectMake(LEFT_FRAME_SIZE/2, 10,
                                                                               200,200)];
        patternLockSprite.anchorPoint = ccp(0.5,0);
        [self addChild:patternLockSprite];
        
        labelContainer = [[CCSprite alloc]init];
        [self addChild:labelContainer];
        
        dateLabel = [CCLabelBMFont labelWithString:@"01.01 Tue " fntFile:@"defaultFont.fnt" width:200 alignment:kCCTextAlignmentCenter];
        dateLabel.color = ccc3(255, 180, 255);
        dateLabel.position = [self invY:ccp(LEFT_FRAME_SIZE/2, 0)];
        NSLog(@"%@ %f",dateLabel,dateLabel.position.y);
        dateLabel.scale    = 1.9;
        dateLabel.anchorPoint  = ccp(0.5,0.5);
        [self addChild : dateLabel];
    }
    return self;
}
-(CGPoint) getEventLabelPosWithIndex : (int) index{
    return [self invY:CGPointMake( DAY_COL_WIDTH * (index/DAY_EVENT_ROW ) + LEFT_FRAME_SIZE,
                                    index % DAY_EVENT_ROW * 40)];
}
-(void) showDay : (DayView*) dayView{
    static NSString* weekDayName[7] = {
        @"Sun",
        @"Mon",
        @"Tue",
        @"Wed",
        @"Thu",
        @"Fri",
        @"Sat"
    };
    
    
    NSLog(@"%ld %ld %ld %ld",dayView.year,dayView.month,dayView.day,dayView.weekDay);
    dateLabel.string = [NSString stringWithFormat:@"%02ld.%02ld %@",dayView.month,dayView.day,weekDayName[dayView.weekDay - 1] ];
    
    int index = 0;
    for(CCLabelBMFont* labelNode in labelContainer.children){
        id action = [CCSequence actions:[CCFadeOut actionWithDuration:1.0f],
                            [CCCallBlock actionWithBlock:^{
                                [labelNode removeFromParentAndCleanup:TRUE];
                            }],nil];
        
        [labelNode runAction:action];
    }
    
    if(dayView != currentDayView)
    {
        int eventIndex = 0;
        for(DiaryEvent* event in [dayView.events reverseObjectEnumerator])
        {
            CCLabelBMFont* newLabel = [[CCLabelBMFont alloc] initWithString : event.text
                                //[NSString stringWithFormat:@"%@ : %@",event.writter,event.text]
                                                                    fntFile : @"defaultFont.fnt"];
            newLabel.anchorPoint = ccp(0,1);
            newLabel.alignment   = kCCTextAlignmentLeft;
            newLabel.position    = [self getEventLabelPosWithIndex:eventIndex++];
            newLabel.color       = ccc3(CCRANDOM_0_1() * 255,CCRANDOM_0_1() * 255,CCRANDOM_0_1() * 255);
            [labelContainer addChild:newLabel];
            newLabel.opacity = 0.0f;
            [newLabel runAction:[CCFadeIn actionWithDuration:1.0f]];
            index ++ ;
        }
    }
    else //이미 보고있는 뷰를 업데이트
    {
        int eventIndex = 0;
        for(DiaryEvent* event in [dayView.events reverseObjectEnumerator])
        {
            CCLabelBMFont* newLabel = [[CCLabelBMFont alloc] initWithString : event.text
                                       //[NSString stringWithFormat:@"%@ : %@",event.writter,event.text]
                                                                    fntFile : @"defaultFont.fnt"];
            newLabel.anchorPoint = ccp(0,1);
            newLabel.alignment   = kCCTextAlignmentLeft;
             newLabel.position    = [self getEventLabelPosWithIndex:eventIndex++];
            newLabel.color       = ccc3(CCRANDOM_0_1() * 255,CCRANDOM_0_1() * 255,CCRANDOM_0_1() * 255);
            [labelContainer addChild:newLabel];
            index ++ ;
        }
    }
    currentDayView = dayView;
}
@end
