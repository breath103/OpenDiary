//
//  DiaryEvent.m
//  DiaryOfAll
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "DiaryEvent.h"

@implementation DiaryEvent
@synthesize writter;
@synthesize text; 
-(id) initWithDict : (NSDictionary*) dict
{
    self = [super init];
    if(self){
       // writter = [[dict objectForKey:@"WRITTER"] mutableCopy];
        text    = [[dict objectForKey:@"TEXT"] mutableCopy] ;
        NSLog(@"%@-%@-%@",dict,writter,text);
    }
    return self;
}
-(NSString*) description
{
    return [NSString stringWithFormat:@"EVENT : %@ == %@",writter,text];
}
@end
