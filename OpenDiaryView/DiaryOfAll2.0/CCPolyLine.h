//
//  CCPolyLine.h
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 10. 6..
//  Copyright 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCLineSegement : CCPointArray
{
}
@property (atomic,assign) ccColor3B color;
@property (atomic,assign) float lineWidth;
@end

@interface CCPolyLine : CCNode<CCRGBAProtocol> {
    GLubyte opacity;
}
@property (nonatomic,retain) NSMutableArray* lineSegements;
@property (nonatomic,retain) CCLineSegement* currentLine;
-(id) initWithFrame : (CGRect) rect;
-(void) addPointToCurrentLine : (CGPoint) point;
-(void) createNewLine;
@end
