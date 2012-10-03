//
//  CalendarLayer.h
//  DiaryOfAll_MAC
//
//  Created by 이상현 on 12. 9. 20..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DayView.h"
#import "GridTemplate.h"

enum CalendarLayerState {
    CALENDAR_STATE_YEAR_VIEW,
    CALENDAR_STATE_MONTH_VIEW
};
typedef enum CalendarLayerState CalendarLayerState;

@interface CalendarLayer : CCLayer<NSStreamDelegate>
{
    CCSpriteBatchNode* batchNode;
    DayView* dayViews[12][31];
    CCTexture2D* planeTexture;
    
    CCSprite* monthNameSprite;
    CCTexture2D* monthNameTextures[12];
    
    CCTexture2D* feelingbar;
    ccColor4B* feelingbarData;
   
   // NSMutableArray* monthLabels;
  //  NSMutableArray* weekDayLabels;
    CCLabelTTF* monthLabels[12];
    CCLabelTTF* weekDayLabels[7];
    
    CCSprite* background;
    CalendarLayerState layerState;
    int selectedMonth;
    
    GridTemplate* dayGrid;
    GridTemplate* monthGrid;
}

@property (nonatomic,retain) NSOutputStream* outputStream;
@property (nonatomic,retain) NSInputStream*  inputStream;

@end
