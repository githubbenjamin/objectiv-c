//
//  AutoScrollView.m
//  OTFClient
//
//  Created by gdlocal on 5/11/16.
//  Copyright (c) 2016 gdlocal. All rights reserved.
//

#import "AutoScrollView.h"

@implementation AutoScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSLog(@"init AutoScrollView.");
    NSTimer* timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autoCheckAndScroll) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)autoCheckAndScroll{
//    NSLog(@"the event: %lu", [theEvent type]);
    NSRect visibleRect = [[self contentView] documentVisibleRect];
    NSLog(@"Visible rect:%@", NSStringFromRect(visibleRect));
    
    NSLog(@"cntent view width:%f, self width:%f", [self contentView].bounds.size.width, self.bounds.size.width + 1) ;

    if ([[self contentView] respondsToSelector:@selector(stringValue)] &&
        
        [[[self contentView] performSelector:@selector(stringValue)] length]*6.32 > self.bounds.size.width ) {
        NSLog(@"auto scroll YES.");
//        NSLog(@"scroller Insets:%@", [self scrollerInsets]);
//        return YES;
    }else{
//        NSLog(@"auto scroll NO.");
//        return NO;
    }
}

- (void)viewWillDraw{
    NSLog(@"viewWillDraw");
}

@end
