//
//  OTFAppDelegate.m
//  OTFClient
//
//  Created by gdlocal on 12/1/14.
//  Copyright (c) 2014 gdlocal. All rights reserved.
//

#import "OTFAppDelegate.h"
#import "OTFTextButtonViewController.h"
#import "OTFCommunicater.h"

@implementation OTFAppDelegate

static NSMutableArray * componentViews = nil;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self initUIComponent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationOfSendingMessage:) name:NOTIFICATION_SEND_RECEIVE_MESSAGE_TYPE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationOfError:) name:@"NSStreamEventErrorOccurred" object:nil];
    
    _communicater = [[OTFCommunicater alloc]init];
    
    [self.logTextFild addObserver:self forKeyPath:@"bounds" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionInitial) context:nil];
    
//    _scrollView
//    [_msgScrollView insertText:@"long long ago, a boy "];
//    [_textField setStringValue:@"a very long long long string that longer than the text field width. again, it's really long enough a new line to show all of it."];
    //
//    [_msgScrollView setHasVerticalScroller:NO];
//    [_msgScrollView setHasHorizontalScroller:NO];
    
//    [_msgScrollView scrollPoint:NSMakePoint([_msgScrollView contentView].bounds.origin.x, _msgScrollView.frame.size.height - 10)];
//    [_msgScrollView setAutoresizesSubviews:YES];
//    if ([_msgScrollView contentView]) {
//        
//    }
    
    [[_msgScrollView contentView] setBoundsSize:NSMakeSize(200, _textField.bounds.size.height)];
    NSTimer* timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autoCheckAndScroll) userInfo:nil repeats:YES];
//    [timer fire];
}

- (void)autoCheckAndScroll{
    
    //    NSLog(@"the event: %lu", [theEvent type]);
//    NSRect visibleRect = [[_msgScrollView contentView] documentVisibleRect];
//    NSLog(@"Visible rect:%@", NSStringFromRect(visibleRect));
//    NSLog(@"text length:%f", [_textField.stringValue length]*6.32);
//    NSLog(@"content view width:%f, self width:%f", _textField.bounds.size.width, _msgScrollView.bounds.size.width + 1) ;
    if ([_textField.stringValue length]*6.32 > _msgScrollView.bounds.size.width) {
        NSLog(@"auto scroll YES.");
        NSRect theBounds = [_msgScrollView bounds];
        theBounds.size.width += 20;
        [_msgScrollView scrollPoint:NSMakePoint(theBounds.size.width, theBounds.size.height)];
//        [_msgScrollView scrollLineDown:self];
//        NSLog(@"scroller Insets:%@", [_msgScrollView scrollerInsets]);
//        return YES;
    }else{
        //        NSLog(@"auto scroll NO.");
        //        return NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)observedObject change:(NSDictionary *)change context:(void *)context {
    NSLog(@"asdf, %@", _logTextFild.className);
//    if () {
//        
//    }
    if ([[observedObject className]isEqualToString:@"asdf"]) {
        
    }
}

-(void)initUIComponent{
    if (!componentViews) {
        componentViews = [NSMutableArray new];
    }
    
    NSPoint frameOrigin = NSMakePoint(10, 200);
    
    for (int i = 0; i < 4; i++) {
        OTFTextButtonViewController* no1Cmpt = [OTFTextButtonViewController newTestButtonComponentView];
        [no1Cmpt.view setFrameOrigin:frameOrigin];
        [[self.window contentView]addSubview: no1Cmpt.view];
        [componentViews addObject:no1Cmpt];
        frameOrigin.y += 40;
    }
    NSPoint frameOrigin2 = NSMakePoint(350, 200);
    for (int i = 0; i < 4; i++) {
        OTFTextButtonViewController* no1Cmpt = [OTFTextButtonViewController newTestButtonComponentView];
        [no1Cmpt.view setFrameOrigin:frameOrigin2];
        [[self.window contentView]addSubview: no1Cmpt.view];
        [componentViews addObject:no1Cmpt];
        frameOrigin2.y += 40;
    }
    
    //
    if ([componentViews count] > 5){
        [componentViews[4] setMessage:@"Check_status,@"];
        [componentViews[3] setMessage:@"Send_msg:1,@"];
        [componentViews[2] setMessage:@"F39123456:1,@"];
        [componentViews[1] setMessage:@"Ack,@"];
        [componentViews[0] setMessage:@"F39123456:.01:.02:.03:.04:.05:.06:.07:.08:.09:.10:.11:.12:.13:.14:.15:.16:.17:.18:.19:.20:.21:.22:.23:.24:.25:.26:.27:.28:.29:.30:.31:.32:.33:.34:.35:.36:.37:.38:.39:.40:.41:.42:.43:.44:.45:.46:.47,@"];
    }
    
    
    //
    [_logTextFild setEditable:NO];
    [_logTextFild setString:@"string"];
    [_ipTextField setStringValue:@"127.0.0.1"];
    [_portTextField setStringValue:@"2941"];
}

-(void)receiveNotificationOfSendingMessage:(NSNotification*)noti{
    NSDictionary* userInfo = [noti userInfo];
//    for (id key in userInfo) {
//        NSLog(@"key:%@, value:%@", key, userInfo[key]);
//    }
    NSLog(@"send msg: [%@]", [userInfo objectForKey: NOTIFICATION_USER_INFO_MESSAGE_KEY]);
    [self checkToBottom];
    if (MSG_SEND == (int)[userInfo objectForKey:NOTIFICATION_USER_INFO_MESSAGE_TYPE_KEY]) {
        NSString* msg2send = [userInfo objectForKey: NOTIFICATION_USER_INFO_MESSAGE_KEY];
        [_logTextFild setString: [NSString stringWithFormat:@"%@\nsend     >> %@", _logTextFild.string, msg2send]];
        [_logTextFild.string stringByAppendingString:msg2send];
        [_communicater sendMessage:[userInfo objectForKey:NOTIFICATION_USER_INFO_MESSAGE_KEY]];
        
    }else if (MSG_READ == (int)[userInfo objectForKey:NOTIFICATION_USER_INFO_MESSAGE_TYPE_KEY]){
        NSString* msg2receive = [userInfo objectForKey: NOTIFICATION_USER_INFO_MESSAGE_KEY];
        if (![msg2receive isEqualToString:@""]) {
            [_logTextFild setString: [NSString stringWithFormat:@"%@\nreceive << %@", _logTextFild.string, msg2receive]];
        }
        
    }
    
//    NSLog(@"window frame size: %ld,%ld", (long)self.window.frame.size.width, (long)self.window.frame.size.height);
}

-(void)receiveNotificationOfError:(NSNotification*)noti{
    [_ipTextField setBackgroundColor:[NSColor redColor]];
}

- (IBAction)connect:(id)sender {
    //
    
    NSLog(@"log length: %lu", (unsigned long)_logTextFild.string.length);
    if (_logTextFild.string.length > 4400) {
        [_logTextFild setString:@""];
//        [_scrollView.documentView scrollPoint:NSMakePoint(currentScrollPosition.x,currentScrollPosition.y+40-10)];
    }
    
    NSLog(@"ip : %@, port: %@", _ipTextField.stringValue, _portTextField.stringValue);
    
    int result_ip = [_communicater setIP: _ipTextField.stringValue];
    
//    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//    NSLog(@"port number: %@", [f numberFromString: _portTextField.stringValue]);
    int result_port = [_communicater setPort:_portTextField.intValue];
    
    if (result_ip != 0 || result_port != 0) {
        NSAlert *alertView = [NSAlert alertWithMessageText:@"" defaultButton:@"Ok" alternateButton:@"" otherButton:nil informativeTextWithFormat:@"connecting information error, please check."];
        NSInteger result = [alertView runModal];
        NSLog(@"alert result: %ld", (long)result);
        return;
        
    }
    [_communicater initCommunication];
    [_ipTextField setBackgroundColor:[NSColor greenColor]];
}

- (IBAction)autConnect:(id)sender {
    NSRect oldRec = _scrollView.bounds;
    NSLog(@"(%f,%f),(%f,%f)", oldRec.origin.x, oldRec.origin.y, oldRec.size.width, oldRec.size.height);
//    oldRec.size.height +=20;
//    oldRec.origin.x += 20;
    NSLog(@"new (%f,%f),(%f,%f)", oldRec.origin.x, oldRec.origin.y, oldRec.size.width, oldRec.size.height);
    BOOL r = [_scrollView scrollRectToVisible:oldRec];
    r?NSLog(@"yes"):NSLog(@"no");
    
//    _logTextFild.bounds = NSMakeRect(0, 0, 667, 96);
    
//    if ((_logTextFild.frame.size.height > [_scrollView frame].size.height)) {
//        NSLog(@"scroller show.");
//    }
//    
//    NSLog(@"scrollview y: %f", [_scrollView contentView].bounds.origin.y);
////    NSLog(@"r: %d,%d", [_scrollView hasHorizontalRuler], [_scrollView hasVerticalRuler]);
//    NSLog(@"logfild y: %f,%f. %f,%f", _logTextFild.bounds.origin.x, _logTextFild.bounds.origin.x, _logTextFild.bounds.size.width, _logTextFild.bounds.size.height);
}

- (void)checkToBottom{
//    if ((_logTextFild.frame.size.height > [_scrollView frame].size.height)) {
//        NSLog(@"scroller show.");
//        if ([_scrollView contentView].bounds.origin.y + 98 > _logTextFild.frame.size.height) {
//            [_scrollView.contentView scrollPoint:NSMakePoint([_scrollView contentView].bounds.origin.x, _logTextFild.frame.size.height - 96)];
//            NSLog(@"mv");
//        }
//        
//    }
    
//    [_scrollView scrollRectToVisible:NSMakeRect(10, 10, 100, 100)];
}
@end
