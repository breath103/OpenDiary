//
//  GridTemplate.m
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 9. 27..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "GridTemplate.h"
#import "CCSprite+autoscale.h"
@implementation GridTemplate
@synthesize parent;
@synthesize cellSize;
@synthesize gridSize;
@synthesize margin;
@synthesize offset;
@synthesize totalCellSize;

-(id) initWithParent : (CCNode*) aParent
            CellSize : (CGSize) aCellSize
            gridSize : (CGSize) aGridSize
              margin : (CGSize) aMargin
              offset : (CGSize) aOffset{
    self = [super init];
    if(self){
        self.parent   = aParent;
        self.cellSize = aCellSize;
        self.gridSize = aGridSize;
        self.margin   = aMargin;
        self.offset   = aOffset;
    }
    return self;
}
-(CGSize) totalCellSize {
    return CGSizeMake(cellSize.width + margin.width,
                      cellSize.height + margin.height);
}

-(CGPoint)positionWithIndex : (CGPoint) gridIndex
                    ForNode : (CCNode*) node {
    return ccp(offset.width + (gridIndex.x + node.anchorPoint.x) * self.totalCellSize.width ,
                parent.contentSize.height -
               (offset.height + (gridIndex.y + node.anchorPoint.y) * self.totalCellSize.height));
}


@end
