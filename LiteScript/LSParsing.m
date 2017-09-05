//
//  LSParsing.m
//  LiteScript
//
//  Created by benjamin on 9/4/17.
//  Copyright © 2017 benjamin. All rights reserved.
//

#import "LSParsing.h"

@implementation LSParsing

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ls_taken = [[NSArray alloc ]initWithObjects:@"and", @"break", @"do", @"else", @"elseif",@"end", @"false", @"for", @"function", @"if",                             @"in", @"local", @"nil", @"not", @"or", @"repeat",@"return", @"then", @"true", @"until", @"while",@"//", @"..", @"...", @"==", @">=", @"<=", @"~=",@"<<", @">>", @"::", @"<eof>",@"<number>", @"<integer>", @"<name>", @"<string>", nil];
        _ls_value_type = [NSArray arrayWithObjects:@"number",@"string",@"boolean",@"var",@"func", nil];
        _operater01 = [[NSSet alloc]initWithObjects:@"+", @"-",@"*",@"/",@">", @"<",@"=", nil];
        _operater02 = [[NSSet alloc]initWithObjects:@"+", @"-",@"*",@"/", nil];
    }
    return self;
}

-(int) run_ls_script:(NSString*) fileName{
    
    return 1;
}

-(id) valueOfVar:(NSString*) name WithLocalStatus:(NSMutableDictionary*)local_status{
    id value = [local_status objectForKey:name];
    if (!value && [local_status objectForKey:@"*"]) {
        value = [self valueOfVar:name WithLocalStatus:[local_status objectForKey:@"*"]];
    }
    if (value) {
        return value;
    }else{
        [NSException raise:@"pares var fail" format:@"no define for [%@]",name];
    }
    
    return 0;
}

-(id) valueOfFunc:(NSString*) funcName ParaName:(NSArray*)pn Para:(NSArray*)para{
    NSString* rawCode = [_ls_status objectForKey:funcName];
    if (!rawCode) {
        NSLog(@"invoke func [%@] fail", funcName);
        return NULL;
    }
    NSMutableDictionary* local_status = [NSMutableDictionary dictionaryWithObjects:para forKeys:pn];
    [local_status setObject:_ls_status forKey:@"*"]; // supper environment status
    id rst_block = [self valueOfBlock:rawCode withLocalStatus:local_status];
    return rst_block;
    //return 0;
}

-(int) registerFunc:(void*)func ForName:(NSString*)name ToStatus:(NSMutableDictionary*)_status{
    NSValue* value = [NSValue valueWithPointer:func];
    
    [_status setObject:value forKey:name];
    return 0;
}

-(id) valueOfBlock:(NSString*) rawCode withLocalStatus:(NSMutableDictionary*)local_status{
    // assign var, list, dic, set value, proecess if, process for while
    
    
    return 0;
}

-(id) valueOfExpression2:(NSString*)exp{
    // process () * / + - > < >= <= != == || &&
    // get value by index from list dic
    // round brackets,parentheses () ; curly brackets  {} ; square brackets []
    // quotes "
    // operand: a b "a"
    // operator: + - * /
    
    NSInteger op01_start = -1;
    NSInteger op01_end = -1;
    NSInteger op02_start = -1;
    NSInteger o_start = -1;
    
    NSInteger rb_start = -1; // round brackets start mark
    NSInteger rb_nesting = 0;
    NSInteger sb_start = -1; // square brackets start mark
    NSInteger qt_start = -1; // quotes start mark
    NSInteger qt_nesting = 0;
    NSInteger opd_start = -1; // operands start mark
    
    NSMutableArray* opds = [NSMutableArray new];  // operands
    NSMutableArray* opts = [NSMutableArray new];  // operators
    
    NSInteger cur_index = -1;
    while (cur_index < exp.length) {
        cur_index++;
        NSString* curChar = [exp substringWithRange:NSMakeRange(cur_index, 1)];
        
        if ([curChar isEqualToString:@"("]) {
            if (qt_start>=0 || sb_start>=0 || opd_start>=0) {
                continue;
            }
            if (rb_start>=0) {
                rb_nesting++;
            }else{
                rb_start = cur_index;
            }
            
        }
        if ([curChar isEqualToString:@")"]) {
            if (qt_start>=0 || sb_start>=0 || opd_start>=0) {
                continue;
            }
            if (rb_start==-1) {
                [NSException raise:@"pares expression fail" format:@"invalid at index [%ld]", cur_index];
            }else{
                if (rb_nesting==0) {
                    [opds addObject:[exp substringWithRange:NSMakeRange(rb_start, cur_index-rb_start)]];
                    rb_start = -1;
                }else{
                    rb_nesting--;
                }
                
            }
        }
        
        if ([curChar isEqualToString:@"\\"] && qt_start>=0) {
            if (cur_index+1<exp.length) {
                cur_index++;
                continue;
            }else{
                [NSException raise:@"pares expression fail" format:@"invalid at index [%ld]", cur_index];
            }
        }
        if ([curChar isEqualToString:@"\""]) {
            if (rb_nesting>=0 || sb_start>=0 || opd_start>=0) {
                continue;
            }else if (qt_start<0){
                qt_start = cur_index;
            }else{
                [opds addObject:[exp substringWithRange:NSMakeRange(qt_start, cur_index-qt_start)]];
                qt_start = -1;
            }
        }
        
        
        
        if ([_operater01 containsObject:curChar]) {
            if (rb_nesting>=0 || sb_start>=0 || qt_start>=0) {
                continue;
            }
            if (cur_index+1<exp.length || [[exp substringWithRange:NSMakeRange(cur_index+1, 1)] isEqualToString:@"="]) {
                [opts addObject: [exp substringWithRange:NSMakeRange(cur_index, 2)]];
                if (opd_start>=0) {
                    
                }
                cur_index++;
                continue;
            }
        }
        
        
        
    }
    
    
    
    return 0;
}

-(id) valueOfExpression:(NSString*)exp WithLocalStatus:(NSMutableDictionary*) lc_status{
    // process () * / + - > < >= <= != == || &&
    // get value by index from list dic
    // round brackets,parentheses () ; curly brackets  {} ; square brackets []
    // quotes "
    // operand: a b "a"
    // operator: + - * /
    
    
    NSInteger op01_start = -1;
    NSInteger op01_end = -1;
    NSInteger op02_start = -1;
    NSInteger o_start = -1;
    
    NSInteger rb_start = -1; // round brackets start mark
    NSInteger rb_nesting = 0;
    NSInteger sb_start = -1; // square brackets start mark
    NSInteger qt_start = -1; // quotes start mark
    NSInteger qt_nesting = 0;
    NSInteger opd_start = -1; // operands start mark
    
    NSMutableArray* opds = [NSMutableArray new];  // operands
    NSMutableArray* opts = [NSMutableArray new];  // operators
    
    NSInteger cur_index = -1;
    while (cur_index < exp.length-1 || cur_index==-1) {
        cur_index++;
        NSString* curChar = [exp substringWithRange:NSMakeRange(cur_index, 1)];
        
//        if ([curChar isEqualToString:@" "]) {
//            
//        }
        
        if ([curChar isEqualToString:@"("]) {
            if (qt_start>=0 || sb_start>=0 || opd_start>=0) {
//                continue;
            }else
            if (rb_start>=0) {
                rb_nesting++;
                continue;
            }else{
                rb_start = cur_index;
                continue;
            }
            
        }
        if ([curChar isEqualToString:@")"]) {
            if (qt_start>=0 || sb_start>=0 || opd_start>=0) {
//                continue;
            }
            if (rb_start==-1) {
                [NSException raise:@"parse expression fail" format:@"invalid at index [%ld]", cur_index];
            }else{
                if (rb_nesting==0) {
                    [opds addObject:[exp substringWithRange:NSMakeRange(rb_start, cur_index-rb_start+1)]];
                    rb_start = -1;
                }else{
                    rb_nesting--;
                }
                continue;
            }
        }
        
        if ([curChar isEqualToString:@"\\"] && qt_start>=0) {
            if (cur_index+1<exp.length) {
                cur_index++;
                continue;
            }else{
                [NSException raise:@"parse expression fail" format:@"invalid at index [%ld]", cur_index];
            }
        }
        if ([curChar isEqualToString:@"\""]) {
            if (rb_start>=0 || sb_start>=0 || opd_start>=0) {
//                continue;
            }else if (qt_start<0){
                qt_start = cur_index;
                continue;
            }else{
                [opds addObject:[exp substringWithRange:NSMakeRange(qt_start, cur_index-qt_start+1)]];
                qt_start = -1;
                continue;
            }
            
        }
        
        if ([_operater01 containsObject:curChar]) {
            if (rb_start>=0 || sb_start>=0 || qt_start>=0) {
//                continue;
            }else{
                if (opd_start>=0) {
                    [opds addObject:[exp substringWithRange:NSMakeRange(opd_start, cur_index-opd_start)]];
                    opd_start = -1;
                }
                if (cur_index+1<exp.length && [[exp substringWithRange:NSMakeRange(cur_index+1, 1)] isEqualToString:@"="]) {
                    [opts addObject: [exp substringWithRange:NSMakeRange(cur_index, 2)]];
                    cur_index++;
                }else{
                    [opts addObject: curChar];
                }
                continue;
            }
            
        }
        
        if ([curChar isEqualToString:@"["]) {
            if (rb_start>=0 || sb_start>=0 || qt_start>=0) {
//                continue;
            }else{
                if (cur_index+1>=exp.length) {
                    [NSException raise:@"parse expression fail" format:@"invalid at index [%ld]", cur_index];
                }
                NSInteger nx_ind = [self nextChar:@"]" FromStr: [exp substringFromIndex:cur_index+1] ];
                [opds addObject: [exp substringWithRange:NSMakeRange(opd_start, cur_index-opd_start+nx_ind+2)]];
                cur_index = cur_index + nx_ind + 1;
                opd_start = -1;
                continue;
            }
            
        }
        
        if ([curChar isEqualToString:@"("]) {
            if (rb_start>=0 || sb_start>=0 || qt_start>=0) {
//                continue;
            }else{
            
                if ((cur_index+1)>=exp.length) {
                    [NSException raise:@"parse expression fail" format:@"invalid at index [%ld]", cur_index];
                }
                NSInteger nx_ind = [self nextChar:@")" FromStr: [exp substringFromIndex:cur_index+1] ];
                [opds addObject: [exp substringWithRange:NSMakeRange(opd_start, cur_index-opd_start+nx_ind+2)]];
                cur_index = cur_index + nx_ind + 1;
                opd_start = -1;
                continue;
            
            }
        }
        
        if (![curChar isEqualToString:@" "]&&rb_start<0 && sb_start<0 && qt_start<0 && opd_start<0) {
            opd_start = cur_index;
        }
    }
    
    // end of seprate operands and operators
    NSLog(@"opd: %@\nopt: %@", opds, opts);
    if (opts.count==0&&opds.count==1) {
        NSString* e = opds.firstObject;
        if ([e hasPrefix:@"("] && [e hasSuffix:@")"]){
            return [self valueOfExpression:[e substringWithRange:NSMakeRange(1, e.length-2)] WithLocalStatus:lc_status];
        }
        
    }
    
    
    /*
     seven type of operands
     1. 2345
     2. "..."
     4. (...)
     5. var01
     6. func01(...)
     7. list01[...]
     */
    NSSet* opt001S = [[NSSet alloc]initWithObjects:@"*",@"/",@"%", nil];
    NSSet* opt002S = [[NSSet alloc]initWithObjects:@"+",@"-", nil];
    NSSet* opt003S = [[NSSet alloc]initWithObjects:@">",@"<",@"=",@">=",@"<=",@"==", nil];
    if (opds.count != opts.count+1) {
        [NSException raise:@"parse expression fail" format:@""];
        return nil;
    }
    while (true) {
        // find * / %
        int dc = 0;
        for (NSInteger i=0; i<opts.count; i++) {
            if ([opt001S containsObject: opts[i]]){
                NSString* tmp_value = [self numberValueOfOperator:opts[i] ForNum:opds[i] AndNum:opds[i+1] WithLocalStatus:lc_status];
                [opts removeObjectAtIndex:i];
                [opds removeObjectAtIndex:i];
                [opds replaceObjectAtIndex:i withObject:tmp_value];
                dc=1;
                break;
            }
        }
        if (dc==0) {
            break;
        }
    }
    while (true) {
        // find * / %
        int dc = 0;
        for (NSInteger i=0; i<opts.count; i++) {
            if ([opt002S containsObject: opts[i]]){
                NSString* tmp_value = [self numberValueOfOperator:opts[i] ForNum:opds[i] AndNum:opds[i+1] WithLocalStatus:lc_status];
                [opts removeObjectAtIndex:i];
                [opds removeObjectAtIndex:i];
                [opds replaceObjectAtIndex:i withObject:tmp_value];
                dc=1;
                break;
            }
        }
        if (dc==0) {
            break;
        }
    }
    while (true) {
        // find * / %
        int dc = 0;
        for (NSInteger i=0; i<opts.count; i++) {
            if ([opt001S containsObject: opts[i]]){
                NSString* tmp_value = [self numberValueOfOperator:opts[i] ForNum:opds[i] AndNum:opds[i+1] WithLocalStatus:lc_status];
                [opts removeObjectAtIndex:i];
                [opds removeObjectAtIndex:i];
                [opds replaceObjectAtIndex:i withObject:tmp_value];
                dc=1;
                break;
            }
        }
        if (dc==0) {
            break;
        }
    }
    
    
    return 0;
}



-(id) numberValueOfOperator:(NSString*)o ForNum:(NSString*)num01 AndNum:(NSString*)num02 WithLocalStatus:(NSMutableDictionary*)ls{
    
    
    if (![self isNumber:num01] || ![self isNumber:num02]) {
        [NSException raise:@"parse expression fail" format:@""];
    }
    if ([o isEqualToString:@"*"]) {
        [NSString stringWithFormat:@"%f", num01.floatValue*num02.floatValue];
    }else if ([o isEqualToString:@"/"]){
        [NSString stringWithFormat:@"%f", num01.floatValue/num02.floatValue];
    }else if ([o isEqualToString:@"%"]){
        [NSString stringWithFormat:@"%ld", num01.integerValue%num02.integerValue];
    }else if ([o isEqualToString:@"+"]){
        [NSString stringWithFormat:@"%ld", num01.integerValue+num02.integerValue];
    }else if ([o isEqualToString:@"-"]){
        [NSString stringWithFormat:@"%ld", num01.integerValue-num02.integerValue];
    }
    
    return 0;
}


-(BOOL) isNumber:(NSString*)num{
    return true;
}

-(NSInteger) nextChar:(NSString*)n_char FromStr:(NSString*)bodyStr {
    NSInteger qt_start = -1; // quotes start mark
    
    NSInteger cur_index = -1;
    while (cur_index<bodyStr.length || cur_index == -1) {
        cur_index++;
        NSString* curChar = [bodyStr substringWithRange:NSMakeRange(cur_index, 1)];
        
        if ([curChar isEqualToString:@"\\"] && qt_start>=0) {
            if (cur_index+1<bodyStr.length) {
                cur_index++;
                continue;
            }else{
                [NSException raise:@"pares expression fail" format:@"invalid at index [%ld]", cur_index];
            }
        }
        if ([curChar isEqualToString:@"\""]) {
            if (qt_start<0){
                qt_start = cur_index;
            }else{
                qt_start = -1;
            }
        }
        if (qt_start>=0) {
            continue;
        }
        
        if ([curChar isEqualToString:n_char]) {
            return cur_index;
        }
    }
    
    return -1;
}

-(BOOL) operation_plusWithP1:(NSString*)p1 P2:(NSString*)p2{
    
    return true;
}

-(id) valueOfOper:(NSString*)opd LocalStatus:(NSMutableDictionary*)lv{
    if ([opd hasPrefix:@"\""]&&[opd hasSuffix:@"\""]) {
        return opd;
    }else if (![opd hasPrefix:@"("] && [opd hasSuffix:@")"]) {
        // fucntion
        NSRange rb_r = [opd rangeOfString: @"("];
        NSString* paramStr = [opd substringWithRange:NSMakeRange(rb_r.location, opd.length-rb_r.location-1)];
        return [self valueOfFunc:[opd substringToIndex:rb_r.location] ParaName:NULL Para:[paramStr componentsSeparatedByString:@","]];
    }else if ([opd hasPrefix:@"("] && [opd hasSuffix:@")"]){
        return [self valueOfExpression:[opd substringWithRange:NSMakeRange(1, opd.length-2)] WithLocalStatus:lv];
    }else if ([opd hasSuffix:@"]"]) {
        // fucntion
        NSRange rb_r = [opd rangeOfString: @"["];
        NSString* paramStr = [opd substringWithRange:NSMakeRange(rb_r.location, opd.length-rb_r.location-1)];
        return [self valueOfFunc:[opd substringToIndex:rb_r.location] ParaName:NULL Para:[paramStr componentsSeparatedByString:@","]];
    }
    return NULL;
}

-(void) test{
    NSString* expression = @"\"abc\" +\"def\" + fnc01(2,3) + list01[2]";
    NSMutableDictionary* lv = [NSMutableDictionary new];
    [self valueOfExpression: expression WithLocalStatus:lv];
}

@end
