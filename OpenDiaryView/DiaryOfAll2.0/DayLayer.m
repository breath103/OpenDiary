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
#define DAY_COL_WIDTH ( ( 1280 - LEFT_FRAME_SIZE) /3.0)

@implementation DayLayer
@synthesize currentDayView;
@synthesize patternLockSprite;
@synthesize currentPaintingLine;

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
        
        labelContainer = [[CCNodeCliping alloc]init];
        labelContainer.contentSize = ccs(DAY_COL_WIDTH, self.contentSize.height);
        labelContainer.anchorPoint = ccp(0,0);
        labelContainer.position    = ccp(LEFT_FRAME_SIZE,0);
        
        [self addChild:labelContainer];
        
        dateLabel = [CCLabelBMFont labelWithString:@"01.01 Tue " fntFile:@"defaultFont.fnt" width:200 alignment:kCCTextAlignmentCenter];
        dateLabel.color = ccc3(255, 180, 255);
        dateLabel.position = [self invY:ccp(LEFT_FRAME_SIZE/2, 0)];
        dateLabel.scale    = 1.9;
        dateLabel.anchorPoint  = ccp(0.5,0.5);
        [self addChild : dateLabel];
        
        paintContainer = [[CCNodeCliping alloc] init];
        paintContainer.contentSize = self.contentSize;
        paintContainer.position = ccp(0,0);
        [self addChild:paintContainer];
    }
    return self;
}
-(void) startPainting : (CCPolyLine*) newPainting{
    currentPaintingLine = newPainting;
  //  [paintContainer addChild:newPainting];
    [self addChild:newPainting];
    [self.currentDayView.paints addObject:newPainting];
}
-(void) endPainting{
    
    id scale = [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:self.contentSize.height/currentPaintingLine.contentSize.height]];
    id move  = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp(LEFT_FRAME_SIZE + DAY_COL_WIDTH,
                                                              self.contentSize.height/2)]];
    id callback = [CCCallBlock actionWithBlock:^{
        //가져오는 애니메이션이 끝난 뒤에 새로운 컨테이너로 옮긴다
        [paintContainer.children.getNSArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CCPolyLine* paint = obj;
            [paint runAction:[CCMoveBy actionWithDuration:0.5f position:ccp(paint.contentSize.width,0)]];
        }];
        [currentPaintingLine removeFromParentAndCleanup:FALSE];
        [paintContainer addChild:currentPaintingLine];
    }];
    [currentPaintingLine runAction:[CCSequence actions:[CCSpawn actions:scale,move,nil],callback,nil]];
}

-(CGPoint) getEventLabelPosWithIndex : (int) index{
    return [self invY:CGPointMake( DAY_COL_WIDTH * (index/DAY_EVENT_ROW ),
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
    dateLabel.string = [NSString stringWithFormat:@"%02ld.%02ld %@",dayView.month,dayView.day,weekDayName[dayView.weekDay - 1] ];
    
    if(dayView != currentDayView)
    {
        // 이전 뷰들을 모두 숨김.
        for(CCLabelBMFont* labelNode in labelContainer.children){
            id action = [CCSequence actions:[CCFadeOut actionWithDuration:0.3],
                         [CCCallBlock actionWithBlock:^{
                [labelNode removeFromParentAndCleanup:TRUE];
            }],nil];
            
            [labelNode runAction:action];
        }
        for(CCPolyLine* labelNode in paintContainer.children){
            id action = [CCSequence actions:[CCFadeOut actionWithDuration:0.3],
                         [CCCallBlock actionWithBlock:^{
                [labelNode removeFromParentAndCleanup:TRUE];
            }],nil];
            [labelNode runAction:action];
        }
        
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
        }
    }
    else //이미 보고있는 뷰를 업데이트
    {
        DiaryEvent* event = [dayView.events lastObject];
        if(event){
            
        CCLabelBMFont* newLabel = [[CCLabelBMFont alloc] initWithString : event.text
                                   //[NSString stringWithFormat:@"%@ : %@",event.writter,event.text]
                                                                fntFile : @"defaultFont.fnt"];
        newLabel.anchorPoint = ccp(0,1);
        newLabel.alignment   = kCCTextAlignmentLeft;
        newLabel.position    = [self getEventLabelPosWithIndex:dayView.events.count - 1];
        newLabel.color       = ccc3(CCRANDOM_0_1() * 255,CCRANDOM_0_1() * 255,CCRANDOM_0_1() * 255);
        [labelContainer addChild:newLabel];
        newLabel.scaleX = newLabel.scaleY = 0.001f;
        
        [newLabel runAction:[CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5f
                                                                                      scaleX:1
                                                                                      scaleY:1]
                                                        period:0.3]];
            
        }
    }
    currentDayView = dayView;
}
@end
