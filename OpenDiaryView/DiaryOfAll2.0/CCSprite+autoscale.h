//
//  CCSprite+autoscale.h
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 9. 25..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#ifndef DiaryOfAll2_0_CCSprite_autoscale_h
#define DiaryOfAll2_0_CCSprite_autoscale_h

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define ccs(w,h) (CGSizeMake(w,h))

@interface CCNode (autoscale)
-(CGPoint)invY : (CGPoint) p;
-(CGPoint)invX : (CGPoint) p;
-(void)resizeTo:(CGSize) theSize;
-(CGSize)scaleWithSize : (CGSize) size;
-(CGPoint)positionWithIndex : (CGPoint) gridIndex
                   GridSize : (CGSize) gridSize ;
@end

@interface CCSprite (autoscale)


@end

#endif
