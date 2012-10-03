//
//  MainScene.h
//  DiaryOfAll_MAC
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CalendarLayer.h"
#import "DayLayer.h"

@interface MainScene : CCScene {
}
@property (nonatomic,retain) CalendarLayer* calendarLayer;
@property (nonatomic,retain) DayLayer* dayLayer;
@end
