//
//  DiaryDate.m
//  DiaryOfAll
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "DiaryDate.h"
#import "DiaryEvent.h"

@implementation DiaryDate
@synthesize feeling;
@synthesize dateComponents;
@synthesize events;
-(id) initWithStringDate:(NSString *)date
                    Dict:(NSDictionary *)dict
{
    self = [super init];
    if(self){
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate* targetDate = [formatter dateFromString: date];
        dateComponents  = [[NSCalendar currentCalendar]components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                                         fromDate:targetDate];
        
        feeling = [[dict objectForKey:@"FEELING"] doubleValue];
        events = [[NSMutableArray alloc]initWithCapacity:dict.count];
        if(([dict objectForKey:@"EVENTS"]))
        {
            for(NSDictionary* eventDict in ([dict objectForKey:@"EVENTS"]))
            {
                [events addObject:[[DiaryEvent alloc]initWithDict:eventDict]];
            }
        }
    }
    return self;
}
-(NSString*) description{
    return [NSString stringWithFormat:@"DATE : %@ \n%f\n%@",dateComponents,feeling,events];
}
@end
