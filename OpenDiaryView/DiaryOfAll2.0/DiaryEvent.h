//
//  DiaryEvent.h
//  DiaryOfAll
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiaryEvent : NSObject
@property (nonatomic,retain) NSString* writter;
@property (nonatomic,retain) NSString* text;
-(id) initWithDict : (NSDictionary*) dict;
@end
