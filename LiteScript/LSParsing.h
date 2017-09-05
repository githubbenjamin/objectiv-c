//
//  LSParsing.h
//  LiteScript
//
//  Created by benjamin on 9/4/17.
//  Copyright © 2017 benjamin. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LSParsing : NSObject

@property (readwrite) NSMutableDictionary* ls_status;
@property (readwrite) NSArray* ls_taken;
@property (readwrite) NSArray* ls_value_type;

@property (readonly) NSSet* operater01;
@property (readonly) NSSet* operater02;

-(int) run_ls_script:(NSString*) fileName;

-(void) test;
@end
