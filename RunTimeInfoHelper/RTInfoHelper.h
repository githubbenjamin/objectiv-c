//
//  RTInfoHelper.h
//  OpenTF
//
//  Created by benjamin on 11/1/17.
//  Copyright © 2017 Diag. All rights reserved.
//

/*
 * collect message from script.
 * steps:
 * 1. init message with script path
 * 2. get message
 */
#import <Foundation/Foundation.h>

@interface RTInfoHelper : NSObject{
    dispatch_source_t freshingTimer;
    dispatch_queue_t infoFreshQueue;
    
    BOOL isRunning;
    NSCondition* mLock;
    NSString* curScriptPath;
    NSString* curScriptContent;
}

@property (readonly) NSString * messages;
@property (readwrite) NSMutableDictionary* kvStorage;
@property (readonly) NSString* defaultScriptPath;

+ (instancetype)sharedInstance;

-(void) initMessagesFromScript:(NSString *) scriptPath;
-(void) initMessagesFromDefaultScript;
//-(void) addMessages:(NSString*) msg;
-(NSString*) getMessages;

@end
