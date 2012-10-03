//
//  PatternLockSprite.h
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 9. 23..
//  Copyright 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PatternLockSprite : CCNode {
    CCNode* dummyFinger;
    CGPoint startPoint;
    CCSpriteBatchNode* dotSpriteBatchNode;
}

@property (nonatomic,retain) CCSprite* backgroundSprite;
@property (nonatomic,retain) CCMotionStreak* motionStreak;
-(id) initWithFrame : (CGRect) frame;
-(void) showPattern : (NSMutableArray*) indexArray;
@end
