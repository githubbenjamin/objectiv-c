//
//  RTInfoHelper.m
//  OpenTF
//
//  Created by benjamin on 11/1/17.
//  Copyright © 2017 Diag. All rights reserved.
//

#import "RTInfoHelper.h"
#import "DDLog.h"

static RTInfoHelper *sharedInstance;

@implementation RTInfoHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t RTInfoHelperOnceToken;
    dispatch_once(&RTInfoHelperOnceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    if (sharedInstance != nil)
    {
        return nil;
    }
    
    if ((self = [super init]))
    {
        // A default asl client is provided for the main thread,
        // but background threads need to create their own client.
        
        //client = asl_open(NULL, "com.apple.console", 0);
        infoFreshQueue = dispatch_queue_create("info_fresh_queue", NULL);
        mLock = [NSCondition new];
        isRunning = false;
        _defaultScriptPath = @"SystemExtend/RunTimeInfo/infoScript.sh";
    }
    return self;
}

-(void) initMessagesFromScript:(NSString *) scriptPath{
    if (![scriptPath hasPrefix:@"/"]) {
        scriptPath = [NSString stringWithFormat:@"%@%@", [self currentPath], scriptPath];
    }
    
    dispatch_block_t block = ^{ @autoreleasepool {
        NSString* scriptContent=NULL;
        
        if (curScriptPath&& ![curScriptPath isEqualToString:scriptPath]) {
            scriptContent = curScriptContent;
        }else{
            NSError* rFileError;
            scriptContent = [[NSString alloc]initWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:&rFileError];
            if (rFileError) {
                DDLogCError(@"read script fail. %@", rFileError.localizedDescription);
            }else{
                curScriptContent = [scriptContent copy];
            }
        }
        if (!scriptContent) {
            dispatch_source_cancel(freshingTimer);
            freshingTimer = NULL;
        }
        [mLock lock];
        _messages = [self exeShellCMDs: scriptContent];
        [mLock unlock];

    }};
    [self freshInfo: block];
}

-(void) initMessagesFromDefaultScript{
    if (!_defaultScriptPath) {
        _defaultScriptPath = @"SystemExtend/RunTimeInfo/infoScript.sh";
    }
    [self initMessagesFromScript:_defaultScriptPath];
}

-(NSString*) getMessages{
    NSString* appendValues = @"";
    if (_kvStorage&&_kvStorage.count>0) {
        appendValues = [[_kvStorage allValues] componentsJoinedByString:@"\n"] ;
    }
    [mLock lock];
    NSString* rst = [NSString stringWithFormat:@"%@\n%@", _messages, appendValues];
    [mLock unlock];
    return rst;
}

//-(void) addMessages:(NSString*) msg{
//    
//}

-(void)freshInfo:(dispatch_block_t) d_block{
    if (freshingTimer)
    {
        dispatch_source_cancel(freshingTimer);
        freshingTimer = NULL;
    }
    
    freshingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, infoFreshQueue);
    
    dispatch_source_set_event_handler(freshingTimer, ^{ @autoreleasepool {
        d_block();
        if (!isRunning) {
            dispatch_source_cancel(freshingTimer);
            freshingTimer = NULL;
        }
        
    }});
    dispatch_source_set_cancel_handler(freshingTimer, ^{
        DDLogCInfo(@"timersource cancel handle block");
    });
    //uint64_t delay = (uint64_t)([logFileRollingDate timeIntervalSinceNow] * NSEC_PER_SEC);
    //dispatch_time_t fireTime = dispatch_time(DISPATCH_TIME_NOW, delay);
    isRunning = true;
    dispatch_source_set_timer(freshingTimer, DISPATCH_TIME_NOW, /*DISPATCH_TIME_FOREVER*/1ull * NSEC_PER_SEC, 1.0);
    dispatch_resume(freshingTimer);
}

-(NSString*)exeShellCMDs:(NSString*)cmdFullStr{
    //    NSArray* cmdArray = [cmdFullStr componentsSeparatedByString:@" "];
    
    NSTask *task;
    task = [[NSTask alloc] init];
    
    [task setLaunchPath: @"/bin/bash"];//run the fdr binary by shell.
    //    [task setLaunchPath: [cmdArray objectAtIndex:0]];//run the fdr binary directly.
    
    NSArray* arguments;
    //DDLogCDebug(@"cmd: %@", cmdFullStr);
    cmdFullStr = [NSString stringWithFormat:@"cd \"%@\";%@", [self currentPath], cmdFullStr];
    arguments = [NSArray arrayWithObjects: @"-c", cmdFullStr, nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
    
    [task terminate];
    //resultString = [NSString stringWithString: string];
    //isFinish = YES;
    return string;
}

-(NSString*)currentPath{
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *lastComponent = [bundlePath lastPathComponent];
    NSRange range = [bundlePath rangeOfString:lastComponent];
    NSString *curPath = [bundlePath substringToIndex:range.location];
    return curPath;
}

@end
