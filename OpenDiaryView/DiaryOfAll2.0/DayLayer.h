//
//  DayLayer.h
//  DiaryOfAll_MAC
//
//  Created by 이상현 on 12. 9. 21..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DayView.h"
#import "PatternLockSprite.h"
@interface DayLayer : CCNode {
    CCSprite* labelContainer;
    CCLabelBMFont* dateLabel;
}
@property (nonatomic,retain) PatternLockSprite* patternLockSprite;
@property(nonatomic,assign) DayView* currentDayView;
-(id) initWithFrame : (CGRect) frame;
-(void) showDay : (DayView*) dayView;
@end
