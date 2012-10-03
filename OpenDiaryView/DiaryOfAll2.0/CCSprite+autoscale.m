//
//  CCSprite+autoscale.m
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 9. 25..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#include "CCSprite+autoscale.h"

@implementation CCNode (autoscale)
-(CGPoint)invY : (CGPoint) p{
    p.y = self.contentSize.height - p.y;
    return p;
}
-(CGPoint)invX : (CGPoint) p{
    p.x = self.contentSize.width - p.x;
    return p;
}
-(void)resizeTo:(CGSize) theSize
{
    CGSize scale = [self scaleWithSize:theSize];
    self.scaleX = scale.width;
    self.scaleY = scale.height;
}
-(CGSize)scaleWithSize : (CGSize) size{
    return ccs(size.width/self.contentSize.width,size.height/self.contentSize.height);
}
-(CGPoint)positionWithIndex : (CGPoint) gridIndex
                   GridSize : (CGSize) gridSize {
    return ccp((gridIndex.x + self.anchorPoint.x) * gridSize.width ,
               (gridIndex.y + self.anchorPoint.y) * gridSize.height);
}

@end

@implementation CCSprite (autoscale)
@end