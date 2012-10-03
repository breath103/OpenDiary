//
//  DayView.h
//  DiaryOfAll_MAC
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DiaryDate.h"

@class DayView;

@interface DayView : CCSprite {
    
}
@property (nonatomic,retain) CCSprite* eventIcon;
@property (nonatomic,retain) CCLabelBMFont* eventsIndicator;
@property (atomic   ,assign) double feeling;
@property (nonatomic,retain) NSMutableArray* events;
@property (nonatomic,retain) NSDateComponents* dateComponents;
@property (nonatomic,readonly) NSInteger year;
@property (nonatomic,readonly) NSInteger month;
@property (nonatomic,readonly) NSInteger day;
@property (nonatomic,readonly) NSInteger weekDay;

-(void) initComponents;
-(void) setInfoWithDateString : (NSString*) dateStr
                         dict : (NSDictionary*) dict;
-(void) showEventCount;
-(void) hideEventCount;
@end
