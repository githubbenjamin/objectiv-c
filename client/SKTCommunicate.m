//
//  OTFCommunicater.m
//  OTFClient
//
//  Created by gdlocal on 12/4/15.
//  Copyright (c) 2015 gdlocal. All rights reserved.
//

#import "OTFCommunicater.h"

@implementation OTFCommunicater
{
    
}

-(id)init{
    self = [super init];
    if (self) {
//        [self initCommunication];
        connectCount = 0;
        port = -9999;
        ip = @"";
    }
    return self;
}

- (void) initCommunication{
//    ip = @"127.0.0.1";
//    port = 2941;
    if (connectCount != 0 || port == -9999 || [ip isEqualTo:@""]) {
        NSLog(@"init communication fail.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"INITFAIL" object:nil];
//        [self close];
        return;
    }
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ip, port, &readStream, &writeStream);
    
    _inputStream = (__bridge_transfer NSInputStream *) readStream;
    _outputStream = (__bridge_transfer NSOutputStream *) writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
    
    connectCount++;
    
}
-(int) sendMessage:(NSString*)msg{
//    UInt buff[] = [msg ]
//    [_inputStream open];
//    [_outputStream open];
//    [self initCommunication];
    if ([_outputStream hasSpaceAvailable]){
        NSLog(@"has space available.");
        
        [_outputStream write:[[msg dataUsingEncoding:NSUTF8StringEncoding] bytes] maxLength: msg.length];
//        [_outputStream close];
    }
    
    return 0;
}

-(NSString*) receiveMessage{
    return 0;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"NSStreamEventOpenCompleted");
            break;
            
        case NSStreamEventHasBytesAvailable:
                NSLog(@"NSStreamEventHasBytesAvailable");
            if (aStream == _inputStream) {
                NSMutableData * input = [[NSMutableData alloc]init];
                long len ;
                uint8_t buffer[2048];
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        [input appendBytes:buffer length:len];
                    }
                }
                _receiveMessage = [[NSString alloc]initWithData:input encoding:NSUTF8StringEncoding];
                NSLog(@"receive message: %@", _receiveMessage);
                NSDictionary* userInformation = [[NSDictionary alloc]initWithObjectsAndKeys: _receiveMessage, NOTIFICATION_USER_INFO_MESSAGE_KEY, MSG_READ, NOTIFICATION_USER_INFO_MESSAGE_TYPE_KEY, nil];
                NSNotification* notification = [NSNotification notificationWithName: NOTIFICATION_SEND_RECEIVE_MESSAGE_TYPE object:nil userInfo:userInformation];
                [[NSNotificationCenter defaultCenter]postNotification: notification];
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"NSStreamEventErrorOccurred, error[%@]", [aStream streamError]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSStreamEventErrorOccurred" object:nil];
            [self close];
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");
            [self close];
            break;
    }
}

- (int)setPort:(int) socketPort{
    if (socketPort <= 0) {
        return -1;
    }
    port = socketPort;
    return 0;
}
- (int)setIP:(NSString*) internetProtocal{
    if (!internetProtocal || [internetProtocal isEqualToString:@""]) {
        return -1;
    }
    NSError* error = NULL;
    NSString* formatString = @"[1-2]?\\d?\\d(.[1-2]\\d?\\d)[3]";
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:formatString options:NSRegularExpressionCaseInsensitive error: &error];
    NSTextCheckingResult* result = [regex firstMatchInString:internetProtocal options:0 range:NSMakeRange(0, [internetProtocal length])];
    NSLog(@"re result: %@", result);
    
    ip = [NSString stringWithString:internetProtocal];
    return 0;
}
- (void)close{
    connectCount--;
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream setDelegate:nil];
    
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
}
@end
