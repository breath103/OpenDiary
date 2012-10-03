//
//  DiaryDate.h
//  DiaryOfAll
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiaryDate : NSObject
@property (nonatomic,strong) NSDateComponents* dateComponents;
@property (atomic,assign) double feeling;
@property (nonatomic,strong) NSMutableArray* events;
-(id) initWithStringDate : (NSString*) date
                    Dict : (NSDictionary*) dict;
@end
