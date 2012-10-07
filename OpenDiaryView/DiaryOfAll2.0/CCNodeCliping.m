//
//  CCNodeCliping.m
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 10. 6..
//  Copyright 2012년 상현 이. All rights reserved.
//

#import "CCNodeCliping.h"


@implementation CCNodeCliping
-(id) init{
    self = [super init];
    if(self){
        contentsContainer = [CCNode new];
        contentsContainer.position = ccp(0,0);
    }
    return self;
}
- (void) visit
{
	glEnable(GL_SCISSOR_TEST);
    CGPoint point = self.position;
   // CGPoint point = [self convertToWorldSpace:self.position];
	glScissor(point.x,point.y,self.contentSize.width,self.contentSize.height);
	[super visit];
	glDisable(GL_SCISSOR_TEST);
}
@end
