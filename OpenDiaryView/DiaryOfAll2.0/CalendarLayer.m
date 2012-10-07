//
//  CalendarLayer.m
//  DiaryOfAll_MAC
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "CalendarLayer.h"
#import "SBJSON.h"
#import "DiaryDate.h"
#import "DiaryEvent.h"
#import "MainScene.h"
#import "CCSprite+autoscale.h"


float minOpacity = 0.1f;

ccColor3B defaultFontColor = {255,255,255};
 

static int monthsDayArray[12] = {31,29,31,30,31,30,31,31,30,31,30,31};
@implementation CalendarLayer
@synthesize outputStream;
@synthesize inputStream;
@synthesize motionStreak;
-(id) init{
    self = [super init];
    if(self){
        self.anchorPoint = ccp(0,0);
        
        dayGrid   = [[GridTemplate alloc] initWithParent : self
                                                CellSize : ccs(34,46)
                                                gridSize : ccs(0,0)
                                                  margin : ccs(4,4)
                                                  offset : ccs(80,110)];
        monthGrid = [[GridTemplate alloc] initWithParent : self
                                                CellSize : ccs(130, 120)
                                                gridSize : ccs(0,0)
                                                  margin : ccs(0, -20)
                                                  offset : ccs(180,80)];
        
        
        feelingbar  = [[CCTextureCache sharedTextureCache] addImage: @"feelingbar.jpeg"];
        int feelingbarLength = feelingbar.contentSizeInPixels.width * feelingbar.contentSizeInPixels.height;
        feelingbarData = (ccColor4B*)malloc(feelingbarLength * sizeof(ccColor4B));
        [feelingbar keepData : feelingbarData
                      length : feelingbarLength];
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"daycell.png"];
        [self addChild:batchNode];
        
        [self connectToServer];
        [self scheduleUpdateWithPriority:0];
        
    }
    return self;
}
-(void) initCalendarViews{
    CCLabelTTF* yearLabel = [CCLabelTTF labelWithString : @"TWENTY-TWELVE"
                                               fontName : @"Impact"
                                               fontSize : 48];
    yearLabel.position = ccp (670,self.contentSize.height - 30);
    yearLabel.color    = defaultFontColor;//ccc3(37,96,159);
    yearLabel.anchorPoint = ccp(0,1);
    [self addChild:yearLabel];
    for(int i = 0;i<12;i++){
        CCLabelTTF* monthLabel = [CCLabelTTF labelWithString : [NSString stringWithFormat:@"%02d",i+1]
                                                    fontName : @"Impact"
                                                    fontSize : 48];
        monthLabel.color = defaultFontColor;//ccc3(37,96,159);
        monthLabel.anchorPoint = ccp(0.5,0.5);
        monthLabel.position = [self invY:ccp( dayGrid.offset.width - 35,
                                i*(dayGrid.totalCellSize.height) + dayGrid.offset.height  + 22)];
        monthLabels[i] = monthLabel;
        [self addChild:monthLabel];
        for(int j=0;j<monthsDayArray[i];j++){
            DayView* dateView = [DayView spriteWithFile:@"daycell.png"];
            [dateView initComponents];
            [dateView resizeTo:dayGrid.cellSize];
            dateView.position = [dayGrid positionWithIndex:ccp(j,i) ForNode:dateView];
        
            [self addChild:dateView];
            
            dayViews[i][j] = dateView;
        }
    }
    
    for(int i = 0;i<7;i++){
        static NSString* weekDayName[7] = {
            @"Sun",
            @"Mon",
            @"Tue",
            @"Wed",
            @"Thu",
            @"Fri",
            @"Sat"
        };
        CCLabelTTF* weekDayLabel = [CCLabelTTF labelWithString : weekDayName[i]
                                                      fontName : @"Impact"
                                                      fontSize : 48];
        weekDayLabel.color = defaultFontColor;//ccc3(37,96,159);
        weekDayLabel.anchorPoint = ccp(0.5,0.5);
        weekDayLabel.position = [self invY:ccp( i * monthGrid.totalCellSize.width + 100 + 145,
                                                80 + 50 )];
        
        weekDayLabel.opacity = 0;
        [self addChild:weekDayLabel];
        weekDayLabels[i] = weekDayLabel;
    }
    
    layerState = CALENDAR_STATE_YEAR_VIEW;
}
-(ccColor4B) colorWithFeeling : (double) feeling{
    
    int index = feelingbar.contentSizeInPixels.width * (1-feeling);
    ccColor4B color;
    memcpy(&color, &feelingbarData[index],sizeof(color));
    color.a = 255;
    
    return color;
}
-(ccColor3B) colorWithDict : (NSDictionary*) dict{
    return ccc3([[dict objectForKey:@"r"] doubleValue],
                [[dict objectForKey:@"g"] doubleValue],
                [[dict objectForKey:@"b"] doubleValue]);
}
/*
-(ccColor4B) colorWithFeeling : (double) feeling{
    return ccc4(255 * feeling, 255* feeling, 255* feeling, 255);
}
 */
-(void) draw{
    [super draw];
}
-(void) connectToServer{
    [self initCalendarViews];
    NSOutputStream* oStream;
    NSInputStream*  iStream;
    
    
 //   NSHost *host = [NSHost hostWithAddress: @"127.0.0.1"];//@"203.253.20.217"];
    NSHost *host = [NSHost hostWithAddress: @"64.23.73.155"];
    
    [NSStream getStreamsToHost:host
                          port:7777
                   inputStream:&iStream
                  outputStream:&oStream];
    
    outputStream = oStream;
    inputStream  = iStream;
    
    inputStream.delegate  = self;
    outputStream.delegate = self;
    [inputStream scheduleInRunLoop : [NSRunLoop currentRunLoop]
                           forMode : NSDefaultRunLoopMode];
    [inputStream open]; //데이터를 읽어오는 스트림 개방
    
    [outputStream scheduleInRunLoop : [NSRunLoop currentRunLoop]
                            forMode : NSDefaultRunLoopMode];
    [outputStream open]; // 데이터를 쓰는 스트림 개방
    
    NSError *streamError;
    streamError = [inputStream streamError];
    streamError = [outputStream streamError];
    
    NSStreamStatus streamStatus;
    streamStatus = [inputStream streamStatus];
    streamStatus = [outputStream streamStatus];
    
}
- (NSDateComponents*) dateStringToComponents : (NSString*) str{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* targetDate = [formatter dateFromString:str];
    NSDateComponents* targetDateComponets = [[NSCalendar currentCalendar]components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit
                                             fromDate:targetDate];
    return targetDateComponets;
}
-(void) showMonthLabels
{
    for(int i = 0;i<12;i++)
    {
        [monthLabels[i] stopAllActions];
        [monthLabels[i] runAction:[CCFadeIn actionWithDuration:1.0f]];
    }
}
-(void) hideMonthLabels
{
    for(int i = 0;i<12;i++)
    {
        [monthLabels[i] stopAllActions];
        [monthLabels[i] runAction:[CCFadeOut actionWithDuration:1.0f]];
    }
}
-(void) showWeekDayLabels
{
    for(int i = 0;i<7;i++)
    {
        [weekDayLabels[i] stopAllActions];
        [weekDayLabels[i] runAction:[CCFadeIn actionWithDuration:1.0f]];
    }
}
-(void) hideWeekDayLabels
{
    for(int i = 0;i<7;i++)
    {
        [weekDayLabels[i] stopAllActions];
        [weekDayLabels[i] runAction:[CCFadeOut actionWithDuration:1.0f]];
    }
}

-(void) showMonthTitle : (int) month
{
    
}
-(void) hideMonthTitle{
}
-(void) initDayViewInfoWithDateString : (NSString*) dateString
                                 Dict : (NSDictionary*) dayDict {
    //뷰에 보여질 애니메이션 관련된 것들
    NSDateComponents* componets = [self dateStringToComponents:dateString];;
    double feeling = [[dayDict objectForKey:@"FEELING"] doubleValue];
    ccColor4B toColor = [self colorWithFeeling:feeling];
    DayView* dayView = dayViews[componets.month - 1][componets.day -1] ;
    dayView.color = ccc3(toColor.r, toColor.g, toColor.b);
    [dayView setInfoWithDateString : dateString
                              dict : dayDict];
}


- (void) _animateMonthToYearView : (int) month {
    int i = month - 1;
    float duration = 1.5f;
    for(int j=0;j<monthsDayArray[i];j++){
        DayView* dayView = dayViews[i][j];
        id moveA = [CCEaseExponentialOut actionWithAction:[CCMoveTo  actionWithDuration:duration
                                                                               position:[dayGrid positionWithIndex:ccp(j,i) ForNode:dayView]]];
        CGSize targetScale = [dayViews[i][j] scaleWithSize:dayGrid.totalCellSize];
        id sizeA = [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:duration
                                                                                 scaleX:targetScale.width
                                                                                 scaleY:targetScale.height]];
        id fadeA = [CCEaseExponentialOut actionWithAction:[CCFadeTo  actionWithDuration:duration opacity:minOpacity * 255]];
        [dayView stopAllActions];
        [dayView runAction:[CCSpawn actions:moveA,sizeA,fadeA,nil]];
        [dayView hideEventCount];
    }
}
- (void) _animateAllViewToDefault {
    float duration = 1.5f;
    for(int i = 0;i<12;i++){
        for(int j=0;j<monthsDayArray[i];j++){
            DayView* dayView = dayViews[i][j];
            id moveA = [CCEaseExponentialOut actionWithAction:[CCMoveTo  actionWithDuration:duration
                                                position:[dayGrid positionWithIndex:ccp(j,i)
                                                                            ForNode:dayView]]];
            
            CGSize targetScale = [dayViews[i][j] scaleWithSize:dayGrid.totalCellSize];
            id sizeA = [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:duration
                                                                                     scaleX:targetScale.width
                                                                                     scaleY:targetScale.height]];
            id fadeA = [CCEaseExponentialOut actionWithAction:[CCFadeIn  actionWithDuration:duration ]];
            [dayView stopAllActions];
            [dayView runAction:[CCSpawn actions:moveA,sizeA,fadeA,nil]];
            [dayView hideEventCount];
        }
    }
    [self hideWeekDayLabels];
    [self showMonthLabels];
    layerState = CALENDAR_STATE_YEAR_VIEW;
}
- (void) _animateMonthToMonthView : (int) month {
    int i = month-1;
    float duration = 1.5f;
    
    int startDayOffset = (int)dayViews[i][0].weekDay - 1;//달의 첫날이 무슨요일인지 계산하여 달뷰를 몇칸 민다.
    for(int j=0;j<monthsDayArray[i];j++){
        float scaleX = monthGrid.cellSize.width  / dayViews[i][j].contentSize.width;
        float scaleY = monthGrid.cellSize.height / dayViews[i][j].contentSize.height;
    
        int dayIndex = j+startDayOffset;
        CGPoint newPoint = [monthGrid positionWithIndex : ccp(dayIndex % 7,7 - dayIndex / 7)
                                                ForNode : dayViews[i][j]];
        id moveA = [CCEaseExponentialOut actionWithAction:[CCMoveTo  actionWithDuration:duration
                                                                position:[self invY:newPoint]]];
        id sizeA = [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:duration
                                                                                 scaleX:scaleX
                                                                                 scaleY:scaleY]];
        id fadeA = [CCEaseExponentialOut actionWithAction:[CCFadeIn  actionWithDuration:duration]];
        [dayViews[i][j] stopAllActions];
        [dayViews[i][j] runAction:[CCSpawn actions:moveA,sizeA,fadeA,nil]];
        [dayViews[i][j] showEventCount];
        dayViews[i][j].zOrder++;
    }
}
- (void)showMonthScene : (int) month{
    if(layerState == CALENDAR_STATE_YEAR_VIEW){
        for(int i = 0;i<12;i++){
            if( i+1 != month){
                for(int j=0;j<monthsDayArray[i];j++){
                    [dayViews[i][j] runAction:[CCFadeTo actionWithDuration:1.0f opacity:minOpacity * 255]];
                }
            }
        }
        [self _animateMonthToMonthView:month];
        [self hideMonthLabels];
        [self showWeekDayLabels];
        layerState = CALENDAR_STATE_MONTH_VIEW;
    }
    else if(layerState == CALENDAR_STATE_MONTH_VIEW)
    {
        if(selectedMonth != month)
        {
            [self _animateMonthToYearView:selectedMonth];
            [self _animateMonthToMonthView:month];
        }
    }
    selectedMonth = month;
}
-(void) showDay : (DayView*) view{
    MainScene* mainScene = (MainScene*) self.parent;
    [mainScene.dayLayer showDay:view];
}
BOOL isNeedToProcessNetworkDatas = false;
-(CGPoint) dictToPoint : (NSDictionary*) dict{
    CGPoint point = CGPointMake([[dict valueForKey:@"x"] doubleValue],
                                [[dict valueForKey:@"y"] doubleValue]);
    return point;
}
-(void) update:(ccTime)delta
{
    if(isNeedToProcessNetworkDatas)
    {
        isNeedToProcessNetworkDatas = false;
        //read data
        uint8_t buffer[20000] = {0,};
        long len;
        while ([inputStream hasBytesAvailable])
        {
            len = [inputStream read:buffer maxLength:sizeof(buffer)];
            if (len > 0){
                NSString* rawString = [[NSString alloc] initWithBytes : buffer
                                                               length : len
                                                             encoding : NSUTF8StringEncoding];
                
                
                if(lastString){
                    rawString = [NSString stringWithFormat:@"%@%@",lastString,rawString];
                    lastString = NULL;
                }
                
                NSArray* packetSegemets = [rawString componentsSeparatedByString:@"\r\n"];
                for(NSString* output in packetSegemets)
                {
                    if(output && output.length >= 1)
                    {
                        SBJSON* parser = [SBJSON new];
                        NSDictionary* resultDict = [parser objectWithString:output];
                        if(resultDict)
                        {
                            NSString* resultType = [resultDict objectForKey:@"type"];
                            NSDictionary* dataDict = [resultDict objectForKey:@"data"];
                            if([resultType compare:@"feelingUpdate"] == NSOrderedSame){
                                NSDateComponents* componets = [self dateStringToComponents:[dataDict objectForKey:@"TARGET_DATE"]];
                                double feeling    = [[dataDict objectForKey:@"FEELING"] doubleValue];
                                double avgFeeling = [[dataDict objectForKey:@"AVG_FEELING"] doubleValue];
                                
                                ccColor4B firstColor = [self colorWithFeeling:feeling];
                                ccColor4B avgColor   = [self colorWithFeeling:avgFeeling];
                                id a1 = [CCTintTo actionWithDuration:0.5
                                                                 red:firstColor.r
                                                               green:firstColor.g
                                                                blue:firstColor.b];
                                id a2 = [CCTintTo actionWithDuration:2.0
                                                                 red:avgColor.r
                                                               green:avgColor.g
                                                                blue:avgColor.b];
                                
                                [dayViews[componets.month-1][componets.day-1]
                                                runAction:[CCSequence actions:a1,a2, nil]];
                            }
                            else if([resultType compare:@"controllStart"] == NSOrderedSame){
                                
                            }
                            else if([resultType compare:@"controllEnd"] == NSOrderedSame){
                                if(layerState == CALENDAR_STATE_MONTH_VIEW){
                                    [self _animateAllViewToDefault];
                                    NSDateComponents* today =
                                    [[NSCalendar currentCalendar]components:NSDayCalendarUnit |
                                                                            NSMonthCalendarUnit |
                                                                            NSYearCalendarUnit
                                                        fromDate:[NSDate date]];
                                    [self showDay:dayViews[today.month - 1][today.day - 1]];
                                }
                            }
                            else if([resultType compare:@"drawStart"] == NSOrderedSame){
                                NSLog(@"%@",@"NewDrawStarted!!!!");
                               
                                CGRect rect;
                                rect.origin = ccp(self.contentSize.width/2,self.contentSize.height/2);
                                rect.size   = CGSizeMake( [[dataDict objectForKey:@"width" ] doubleValue],
                                                          [[dataDict objectForKey:@"height"] doubleValue]);
                                polyLine = [[CCPolyLine alloc] initWithFrame:rect];
                                polyLine.scale = 700 / polyLine.contentSize.height;
                                polyLine.currentLine.color = [self colorWithDict:[dataDict objectForKey:@"color"]];
                                polyLine.currentLine.lineWidth = [[dataDict objectForKey:@"lineWidth"] doubleValue];
                                
                                NSLog(@"%@",dataDict);
                                
                                paintBackground.textureRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
                                paintBackground.scale = polyLine.scale;
                                [paintBackground stopAllActions];
                                [paintBackground runAction:[CCFadeTo actionWithDuration:0.3 opacity:255 * 0.7f]];
                                
                                MainScene* mainScene = (MainScene*) self.parent;
                                [mainScene.dayLayer startPainting:polyLine];
                            }   
                            else if([resultType compare:@"drawLine"] == NSOrderedSame){
                                [polyLine addPointToCurrentLine:[self dictToPoint:[dataDict valueForKey:@"position"]]];
                                polyLine.currentLine.color = [self colorWithDict:[dataDict objectForKey:@"color"]];
                                polyLine.currentLine.lineWidth = [[dataDict objectForKey:@"lineWidth"] doubleValue];
                                NSLog(@"%f",polyLine.currentLine.lineWidth);
                            }
                            else if([resultType compare:@"drawLineEnd"] == NSOrderedSame){
                                [polyLine createNewLine];
                            }
                            else if([resultType compare:@"drawEnd"] == NSOrderedSame){
                                NSLog(@"%@",@"DrawEND!!!!");
                                MainScene* mainScene = (MainScene*) self.parent;
                                [mainScene.dayLayer endPainting];
                                
                                [paintBackground stopAllActions];
                                [paintBackground runAction:[CCFadeOut actionWithDuration:0.4]];
                            }
                            
                            else if([resultType compare:@"patternKeyChanged"] == NSOrderedSame){
                                NSMutableArray* pattern = [dataDict objectForKey:@"PATTERN"];
                                MainScene* mainScene = (MainScene*) self.parent;
                                [mainScene.dayLayer.patternLockSprite showPattern:pattern];
                            }
                            else if([resultType compare:@"newEvent"] == NSOrderedSame){
                                NSDateComponents* components = [self dateStringToComponents:[dataDict objectForKey:@"TARGET_DATE"]];
                                DayView*    dayView  = dayViews[components.month-1][components.day-1];
                                DiaryEvent* newEvent = [[DiaryEvent alloc] initWithDict:dataDict];
                                [dayView.events addObject:newEvent];
                                
                                MainScene* mainScene = (MainScene*) self.parent;
                                if(mainScene.dayLayer.currentDayView == dayView)
                                    //이미 선택되어서 dayLayer에서 보고 있는 날에 추가 이벤트가 달린 경우
                                {
                                    [mainScene.dayLayer showDay:dayView];
                                }
                            }
                            else if([resultType compare:@"showDate"] == NSOrderedSame){
                                int month = [[dataDict objectForKey:@"MONTH"] intValue];
                                int day   = [[dataDict objectForKey:@"DAY"] intValue];
                                
                                DayView* dayView = dayViews[month-1][day-1];
                                MainScene* mainScene = (MainScene*) self.parent;
                                [mainScene.dayLayer showDay:dayView];
                                [self showMonthScene:month];
                            }
                            else if([resultType compare:@"allCalendar"] == NSOrderedSame){
                                //[[CCDirector sharedDirector] setDisplayFPS:NO];
                                
                                for(NSString* day in [dataDict allKeys]){
                                    NSDictionary* dayDict = [dataDict objectForKey:day];
                                    [self initDayViewInfoWithDateString:day
                                                                   Dict:dayDict];
                                }
                                NSDateComponents* today =
                                [[NSCalendar currentCalendar]components:NSDayCalendarUnit |
                                 NSMonthCalendarUnit |
                                 NSYearCalendarUnit
                                                               fromDate:[NSDate date]];
                                [self showDay:dayViews[today.month - 1][today.day - 1]];
                                
                                
                                paintBackground = [CCSprite spriteWithFile:@"back.png" ];
                                paintBackground.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
                                paintBackground.anchorPoint = ccp(0.5,0.5);
                                paintBackground.opacity = 0;
                                [self addChild:paintBackground];
                            }
                            else{
                                NSLog(@"not catched message : %@\n%@",resultType,resultDict);
                            }
                        }
                        else
                        {
                            //데이터가 짤린경우
                            lastString = [output copy];
                            NSLog(@"not Jsoned message : %@",output);
                        }
                    }
                }
            }
        }
    }
}
- (void) stream : (NSStream *)theStream
    handleEvent : (NSStreamEvent)streamEvent
{
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream){
                isNeedToProcessNetworkDatas = true;
            }
            break;
        case NSStreamEventNone : break;
        case NSStreamEventOpenCompleted  : break;
        case NSStreamEventErrorOccurred  :
            NSLog(@"%@",@"Connection Error");
            break;
        case NSStreamEventEndEncountered :
            NSLog(@"%@",@"Connection End");
            break;
        default:
            NSLog(@"%@ %ld",theStream,streamEvent);
            break;
    }
}
@end
