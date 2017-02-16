//
//  OTFTextButtonViewController.m
//  OTFClient
//
//  Created by gdlocal on 12/4/15.
//  Copyright (c) 2015 gdlocal. All rights reserved.
//

#import "OTFTextButtonViewController.h"
#import "constant.h"


@interface OTFTextButtonViewController ()

@end

@implementation OTFTextButtonViewController

static NSMutableArray * viewList = nil;

+(OTFTextButtonViewController*) newTestButtonComponentView{
    OTFTextButtonViewController* aNewOne = [[OTFTextButtonViewController alloc]init];
    if (!viewList) {
        viewList = [NSMutableArray new];
    }
    [viewList addObject:aNewOne];
    return aNewOne;
}
- (id)init {
    self = [self initWithNibName:@"OTFTextButtonViewController" bundle:nil];
//    if (self) {
//        [self setWindowFrameAutosaveName:@"OTFTextButtonViewController"];
//        
//    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)sendMessage:(id)sender {
    NSString *msg = [NSString stringWithFormat:@"%@", _testField.stringValue];
    if (msg == nil || [msg isEqualToString:@""]) {
        NSLog(@"message is blank");
        return;
    }
    
    NSDictionary* userInformation = [[NSDictionary alloc]initWithObjectsAndKeys: msg, NOTIFICATION_USER_INFO_MESSAGE_KEY, MSG_SEND, NOTIFICATION_USER_INFO_MESSAGE_TYPE_KEY, nil];
    NSNotification* notification = [NSNotification notificationWithName: NOTIFICATION_SEND_RECEIVE_MESSAGE_TYPE object:nil userInfo:userInformation];
    [[NSNotificationCenter defaultCenter]postNotification: notification];
}

-(void)setMessage:(NSString*)msg{
    [_testField setStringValue:msg];
}
@end
