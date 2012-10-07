//
//  CCPolyLine.m
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 10. 6..
//  Copyright 2012년 상현 이. All rights reserved.
//

#import "CCPolyLine.h"

@implementation CCLineSegement
@synthesize color;
@synthesize lineWidth;
-(id) init {
    self = [super init];
    if(self){
        lineWidth = 3;
    }
    return self;
}
@end


@implementation CCPolyLine
@synthesize lineSegements;
@synthesize currentLine;
-(id) initWithFrame : (CGRect) rect{
    self = [super init];
    if(self){
        self.anchorPoint = ccp(0.5,0.5);
        self.position = rect.origin;
        self.contentSize = rect.size;
        
        self.lineSegements = [NSMutableArray new];
        [self createNewLine];
        opacity = 255;
    }
    return self;
}
-(GLubyte) opacity{
    return opacity;
}
-(void) setOpacity: (GLubyte) _opacity{
    opacity = _opacity;
}
-(void) draw{
    [super draw];
    glEnable(GL_LINE_SMOOTH);
    for(CCLineSegement* line in lineSegements){
        if(line.count > 0)
        {
            CGPoint points[line.count];
            for(int i=0;i<line.count;i++){
                points[i] = [line getControlPointAtIndex:i];
                points[i].y = self.contentSize.height - points[i].y;
            }
            
            ccColor3B color = line.color;
            ccDrawColor4B(color.r,color.g,color.b,opacity);
            glLineWidth(line.lineWidth);
            ccDrawPoly( points, line.count, FALSE);
        }
    }
}
-(void) addPointToCurrentLine : (CGPoint) point
{
    [currentLine addControlPoint:point];
}
-(void) createNewLine{
    currentLine = [CCLineSegement new];
    [lineSegements addObject:currentLine];
}

@end
