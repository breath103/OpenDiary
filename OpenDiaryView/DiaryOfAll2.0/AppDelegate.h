//
//  AppDelegate.h
//  DiaryOfAll2.0
//
//  Created by 이상현 on 12. 9. 23..
//  Copyright 상현 이 2012년. All rights reserved.
//

#import "cocos2d.h"

@interface DiaryOfAll2_0AppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
