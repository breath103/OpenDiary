//
//  PatternLockSprite.m
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 9. 23..
//  Copyright 2012년 상현 이. All rights reserved.
//

#import "PatternLockSprite.h"
#import "NSObject+block.h"

#define PATTERN_WIDTH (3)
#define PATTERN_HEIGHT (3)

@implementation PatternLockSprite
@synthesize backgroundSprite;
@synthesize motionStreak;
-(id) initWithFrame : (CGRect) frame
{
    self = [super init];
    if(self){
        self.position    = frame.origin;
        self.contentSize = frame.size;
        self.anchorPoint = ccp(0,0);
        
        backgroundSprite = [CCSprite spriteWithFile:@"back.png" rect:CGRectMake(0, 0,
                                                                                self.contentSize.width,
                                                                                self.contentSize.height)];
        backgroundSprite.color = ccc3(255, 255, 255);
        backgroundSprite.opacity = 0.0f;
        backgroundSprite.anchorPoint = ccp(0,0);
        backgroundSprite.position = ccp(0,0);
        [self addChild: backgroundSprite];
        
        
        int dotWidth  = self.contentSize.width  / PATTERN_WIDTH;
        int dotHeight = self.contentSize.height / PATTERN_HEIGHT;
        dotSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"dot.png"];
        for(int i = 0;i<PATTERN_WIDTH;i++){
            for(int j=0;j<PATTERN_HEIGHT;j++){
                CCSprite* dotSprite = [CCSprite spriteWithTexture:dotSpriteBatchNode.texture];
                dotSprite.anchorPoint = ccp(0.5,0.5);
                dotSprite.position = ccp(dotWidth * (i + 0.5),dotHeight * (j+0.5));
                [dotSpriteBatchNode addChild:dotSprite];
            }
        }
        [self addChild:dotSpriteBatchNode];
        
        dummyFinger = [[CCNode alloc]init];
        dummyFinger.position = ccp(0,0);
        dummyFinger.anchorPoint = ccp(0,0);
        dummyFinger.contentSize = CGSizeMake(1, 1);
        [self addChild:dummyFinger];
        
        
        motionStreak = [CCMotionStreak streakWithFade : 1.5f
                                               minSeg : 0.5f
                                                width : 10.0f
                                                color : ccc3(0,150,255)
                                      textureFilename : @"lineTexture.png"];
        [self addChild:motionStreak];
        
        [self scheduleUpdate];
        
    }
    return self;
}
-(void) update:(ccTime)delta
{
    motionStreak.position = dummyFinger.position;
}

-(void) onPathActionEnd
{
    dummyFinger.position = startPoint;
    motionStreak.position = dummyFinger.position;
    [motionStreak reset];
}

-(void) showPattern : (NSMutableArray*) indexArray{
    [dummyFinger stopAllActions];
    
    
    int dotWidth  = self.contentSize.width  / PATTERN_WIDTH;
    int dotHeight = self.contentSize.height / PATTERN_HEIGHT;
    
    NSMutableArray* moveActions = [NSMutableArray new];
    
    for(NSNumber* index in indexArray){
        int iIndex = [index intValue];
        int xIndex = (iIndex - 1) % PATTERN_WIDTH;
        int yIndex = (iIndex - 1) / PATTERN_HEIGHT;
    
        [moveActions addObject:[CCMoveTo actionWithDuration:0.2f
                                                   position:ccp(dotWidth * (xIndex+0.5),self.contentSize.height- dotHeight * (yIndex+0.5))]];
    }
    

    startPoint = motionStreak.position = dummyFinger.position =
                [((CCMoveTo*)[moveActions objectAtIndex:0]) getEndPosition];
    
    [moveActions addObject:[CCDelayTime actionWithDuration:1.0f]];
    [moveActions addObject:[CCCallFunc actionWithTarget:self selector:@selector(onPathActionEnd)]];
    [dummyFinger runAction: [CCRepeatForever actionWithAction:[CCSequence actionWithArray:moveActions]]];
}
@end
