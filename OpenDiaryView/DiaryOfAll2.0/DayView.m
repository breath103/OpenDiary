//
//  DayView.m
//  DiaryOfAll_MAC
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "DayView.h"
#import "DiaryEvent.h"
#import "CCSprite+autoscale.h"


@implementation DayView

@synthesize feeling;
@synthesize events;
@synthesize eventIcon;
@synthesize eventsIndicator;
@synthesize dateComponents;
@synthesize paints;
@synthesize year;
@synthesize month;
@synthesize day;
@synthesize weekDay;

-(void) initComponents{
    
    self.anchorPoint = ccp(0.5,0.5);
    
    
    events = [[NSMutableArray alloc]init];
    eventIcon = [CCSprite spriteWithFile:@"event_badge.png"];
    eventIcon.anchorPoint = ccp(0.5,0.5);
    [eventIcon resizeTo:ccs(60,60)];
    eventIcon.position = ccp(self.contentSize.width * 0.8,self.contentSize.height * 0.8);
    eventsIndicator = [CCLabelBMFont labelWithString:@"01111" fntFile:@"defaultFont.fnt"];
    eventsIndicator.color = ccc3(0,0,0);
    eventsIndicator.anchorPoint = ccp(0.5,0.5);
    eventsIndicator.position    = ccp(eventIcon.contentSize.width/2 -2,
                                      eventIcon.contentSize.height/2 + 4);
    eventsIndicator.scale = 1.3f;
    eventIcon.visible = FALSE;
    
    paints = [NSMutableArray new];
    
    [eventIcon addChild:eventsIndicator];
    [self addChild:eventIcon];
   
}
-(void) setInfoWithDateString : (NSString*) dateStr
                         dict : (NSDictionary*) dict
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* targetDate = [formatter dateFromString: dateStr];
    dateComponents  = [[NSCalendar currentCalendar]components : NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit
                                                     fromDate : targetDate];

    year     = dateComponents.year;
    month    = dateComponents.month;
    day      = dateComponents.day;
    weekDay  = dateComponents.weekday;
    
    feeling = [[dict objectForKey:@"FEELING"] doubleValue];
    events = [[NSMutableArray alloc] init];
    for(NSDictionary* eventDict in ([dict objectForKey:@"EVENTS"]))
    {
        NSLog(@"%@",eventDict);
        [events addObject:[[DiaryEvent alloc]initWithDict:eventDict]];
    }
    eventsIndicator.string = [NSString stringWithFormat:@"%ld",events.count];
}
-(void) showEventCount{
    eventIcon.opacity = 0.0f;
    eventIcon.visible = TRUE;
    [eventIcon stopAllActions];
    [eventIcon runAction:[CCFadeIn actionWithDuration:0.5f]];
}
-(void) hideEventCount{
    [eventIcon stopAllActions];
    [eventIcon runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.3f],[CCCallBlock actionWithBlock:^{
        eventIcon.visible = FALSE;
    }] ,nil]];
}

@end
