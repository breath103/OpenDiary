//
//  GridTemplate.h
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 9. 27..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface GridTemplate : NSObject
@property (nonatomic,assign) CCNode* parent;
@property (nonatomic,assign) CGSize cellSize;
@property (nonatomic,assign) CGSize gridSize;
@property (nonatomic,assign) CGSize margin;
@property (nonatomic,assign) CGSize offset;
@property (nonatomic,readonly) CGSize totalCellSize;

-(id) initWithParent : (CCNode*) aParent
            CellSize : (CGSize) aCellSize
            gridSize : (CGSize) aGridSize
              margin : (CGSize) aMargin
              offset : (CGSize) aOffset;
-(CGPoint)positionWithIndex : (CGPoint) gridIndex
                    ForNode : (CCNode*) node;
-(CGSize) totalCellSize;
@end
