//
//  ExpParse.m
//  ParseExpress
//
//  Created by gdlocal on 12/26/16.
//  Copyright (c) 2016 gdlocal. All rights reserved.
//

#import "ExpParse.h"
#import <objc/runtime.h>
#import "MethodPrint.h"

@interface T_Var : NSObject

@property (readwrite) NSString* name_;
@property (readwrite) id value_;
@property (readwrite) NSNumber* type_;

@end

@implementation T_Var

@synthesize name_;
@synthesize value_;
@synthesize type_;

@end

@interface FunctionStack : NSObject

@end

@implementation FunctionStack

-(void)sayHi
{
    NSLog(@"Hi! from %@",NSStringFromSelector(_cmd));
}

//+(BOOL)resolveInstanceMethod:(SEL)sel {} // system invoke
+(int)registerFunctionName:(SEL)sel WithObject:(Class)class_type Method:(SEL)registerName
{
    //    Class class_type = NSClassFromString(objectName);
    if (!class_type){
        NSLog(@"");
        return -1;
    }
    NSObject* obj = [[class_type alloc] init];
    
    //    SEL methodImplement = @selector(methodName);
    if ( [obj respondsToSelector: registerName]){
        NSLog(@"");
        return  -1;
    }
    
    Method method=class_getInstanceMethod(class_type, @selector(sayHi));
    class_addMethod(self,sel,method_getImplementation(registerName),method_getTypeEncoding(method));
    
    return 0;
}

+(int)registerFunction:(T_Var*)t_var{
    return 0;
}


@end



@implementation ExpParse

//enum e_var_type { e_string = 0, e_number};
@synthesize g_vars;
//@synthesize l_vars;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSSet* oss1 = [[NSSet alloc]initWithObjects:@"(",@")", nil];
        NSSet* oss2 = [[NSSet alloc]initWithObjects:@"+",@"-",@"*",@"/" ,nil];
        NSSet* oss3 = [[NSSet alloc]initWithObjects:@"==",@">",@"<",@">=",@"<=", nil];
        NSSet* oss4 = [[NSSet alloc]initWithObjects:@"=", nil];
        _operateSymbolSets = [[NSSet alloc]initWithObjects:oss1,oss2,oss3,oss4, nil];
        g_vars = [NSMutableDictionary new];
    }
    return self;
}

-(int) parseScriptFile:(NSString *)filePath{
    
    NSMutableDictionary* local_vars_func = [NSMutableDictionary new];
    [local_vars_func setObject:g_vars forKey:@"*"]; // set super level envirenment
#ifdef DEBUG
    NSString* ep = @"var c = a + b;print(c)";
    
    T_Var * fnc01 = [T_Var new];
    fnc01.name_ = @"print";
    fnc01.value_ = @"NSLog"; // use the block
    [FunctionStack registerFunctionName:@selector(print:) WithObject:[MethodPrint class] Method:@selector(print:)];
    fnc01.type_ = [NSNumber numberWithInteger:4];
    [g_vars setObject:fnc01 forKey:fnc01.name_];
    
    T_Var* var01 = [T_Var new];
    [var01 setName_:@"a"];
    [var01 setValue_:[NSNumber numberWithInt:1]];
    [var01 setType_: [NSNumber numberWithInt:1]]; // 0 for string, 1 for number, 2 for bool, , 3 for list, 4 for function
    [g_vars setObject:var01 forKey:var01.name_];
    
    T_Var* var02 = [T_Var new];
    var02.name_ = @"b";
    var02.value_ = [NSNumber numberWithInt:1];
    [local_vars_func setObject:var02 forKey:var02.name_];
    
#endif
    
    int rst_parseMain = [self parseMainBlock:ep withLocalVars:local_vars_func];
    return rst_parseMain;
//    return 0;
}

-(int) parseMainBlock:(NSString *)ep withLocalVars:(NSMutableDictionary*) l_vars{
    
    //
    NSArray* logical_lines = [ep componentsSeparatedByString: @";"];
    for (NSString* ll in logical_lines) {
        NSString* oneLogicalLine = [ll stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        int rst_oll = [self parseLogicalLine: oneLogicalLine withLocalVars: l_vars];
        if (rst_oll!=0) {
            return rst_oll;
        }
    }
    
    return 0;
}

-(int)parseLogicalLine:(NSString *)express withLocalVars:(NSMutableDictionary *)localVars{
    NSMutableArray* operaterSymbols = [NSMutableArray new];
    NSMutableArray* valueVars = [NSMutableArray new];
    
    if (![self islegalQuotationMarksForExp:express SeprateOperateTo:operaterSymbols ValueVarTo:valueVars]) {
        NSLog(@"not legal for logical line");
        return -1;
    }
    
    // process =
    if ([[operaterSymbols firstObject]isEqualToString:@"="]) {
        NSString* firstValueVar = [valueVars firstObject];
        if ([firstValueVar hasPrefix:@"var "]) {
            firstValueVar = [firstValueVar substringFromIndex:4];
            
        }
        
        T_Var* tmp_var = [T_Var new];
        tmp_var.name_ = firstValueVar;
        NSMutableArray* value = [NSMutableArray new];
        [operaterSymbols removeObject:[operaterSymbols firstObject]];
        [valueVars removeObject:[valueVars firstObject]];
        int rst = [self processAndAssignResultTo:value withOperateSymbols:operaterSymbols valueAndVar:valueVars localVars:localVars];
        if (value.count!=1) {
            return -1;
        }
        tmp_var.value_ = [value firstObject];
        [localVars setObject:tmp_var forKey:tmp_var.name_];
        return rst;
    }
    
    // process if
    
    // process for
    
    // process while
    
    return 0;
}

-(int)processAndAssignResultTo:(NSMutableArray*)value
            withOperateSymbols:(NSMutableArray*)operateSymbols
                   valueAndVar:(NSMutableArray*)valueVars
                     localVars:(NSMutableDictionary*)localVars{
    //-(int)process:(NSMutableArray*)operateSymbols valueAndVar:(NSMutableArray*)valueVars localVars:(NSMutableDictionary*)localVars{
    
    
    // process
    //    if (value.count==1 && operateSymbols.count==0) {
    //        return 0;
    //    }
    if (operateSymbols.count == 0) {
        return (int)valueVars.count;
    }
    
    NSString* os = [operateSymbols firstObject];
    // for 4 kink of operate symbol
    
    // "(" ")"
    
    // find the outest ( )
    NSInteger bracket_start = -1;
    NSInteger bracket_end = -1;
    NSInteger nested_count = 0;
    for (int i=0; i<operateSymbols.count; i++) {
        if ([@"(" isEqualToString:os]) {
            if (bracket_start < 0) {
                bracket_start=i;
            }else{
                nested_count++;
            }
            
        }
        if ([@")" isEqualToString:os]) {
            if (bracket_start < 0) {
                NSLog(@"process ( or ) error.");
                return -1;
            }
            if (nested_count==0) {
                bracket_end = i;
            }else{
                nested_count--;
            }
        }
    }
    
    if (bracket_start>=0&&bracket_end>0&&bracket_start<bracket_end) {
        NSMutableArray* value_tmp_p = [NSMutableArray new]; // value temp privali
        NSMutableArray* os_tmp_p = [NSMutableArray new];
        NSMutableArray* vv_tmp_p = [NSMutableArray new];
        
        NSMutableArray* value_tmp_l = [NSMutableArray new]; // value temp left
        NSMutableArray* os_tmp_l = [NSMutableArray new];
        NSMutableArray* vv_tmp_l = [NSMutableArray new];
        
        for (NSInteger i=0; i<operateSymbols.count; i++) {
            if (i>bracket_start && i<bracket_end) {
                [os_tmp_p addObject: operateSymbols[i]];
            }else{
                [os_tmp_l addObject:operateSymbols[i]];
            }
            
        }
        for (NSInteger i=0; i<valueVars.count; i++) {
            if (i>=bracket_start && i<=bracket_end-operateSymbols.count+valueVars.count) {
                [vv_tmp_p addObject:valueVars[i]];
            }else{
                [vv_tmp_l addObject:valueVars[i]];
            }
            
        }
        
        int rst_tmp_p = [self processAndAssignResultTo:value_tmp_p withOperateSymbols:os_tmp_p valueAndVar:vv_tmp_p localVars:localVars];
        if (rst_tmp_p==0) {
            if (value_tmp_p.count!=1) {
                NSLog(@"process result error");
                return -1;
            }
            [vv_tmp_l insertObject:[value_tmp_p firstObject] atIndex:bracket_start];
            int rst_tmp_l = [self processAndAssignResultTo:value_tmp_l withOperateSymbols:os_tmp_l valueAndVar:vv_tmp_l localVars:localVars];
            [value addObject:value_tmp_l];
            return rst_tmp_l;
            
        }else{
            return rst_tmp_p;
        }
    }
    
    if (bracket_start!=-1 || bracket_start!=-1) {
        NSLog(@"brackets error");
        return -1;
    }
    
    
    // no bracket below
    NSInteger index_mdm = -1; // index of multiply divid mode, * / %
    NSSet* mdm_set = [[NSSet alloc]initWithObjects:@"*",@"/",@"%", nil];
    for (NSInteger i=0; i<operateSymbols.count; i++) {
        if ([mdm_set containsObject:operateSymbols[i]]) {
            index_mdm = i;
        }
    }
    
    if (index_mdm >= 0) {
        if (valueVars.count<2) {
            NSLog(@"process error, stack: %@; %@", operateSymbols, valueVars);
            return -1;
        }
        NSString* stringValue = nil;
        NSString* valueVar1 = valueVars[0];
        NSString* valueVar2 = valueVars[1];
        if ([self isVarFormat:valueVar1]) {
            valueVar1 = [NSString stringWithFormat:@"%@", [self valueOfVarByName:valueVar1 inLocalVar:localVars]];
            if (!valueVar1) {
                NSLog(@"no assign var '%@'", valueVar1);
                return -1;
            }
        }
        if ([self isVarFormat:valueVar2]) {
            valueVar2 = [NSString stringWithFormat:@"%@", [self valueOfVarByName:valueVar2 inLocalVar:localVars] ];
            if (!valueVar2) {
                NSLog(@"no assign var '%@'", valueVar2);
                return -1;
            }
        }
        
        if ([@"*" isEqualToString: operateSymbols[index_mdm]] ) {
            
            if ([self isNumberFormat:valueVar1]&&[self isNumberFormat:valueVar2]) {
                if ([self isMatchRegularExpression:@"\\d" forString:valueVar1] && [self isMatchRegularExpression:@"\\d" forString:valueVar2]) {
                    stringValue = [NSString stringWithFormat:@"%ld", [valueVar1 integerValue]*[valueVar2 integerValue]];
                }else{
                    stringValue = [NSString stringWithFormat:@"%f", [valueVar1 floatValue]*[valueVar2 floatValue]];
                }
                
            }
        }else if ([@"/" isEqualToString: operateSymbols[index_mdm]] ) {
            
            if ([self isNumberFormat:valueVar1]&&[self isNumberFormat:valueVar2]) {
                if ([self isMatchRegularExpression:@"\\d" forString:valueVar1] && [self isMatchRegularExpression:@"\\d" forString:valueVar2]) {
                    stringValue = [NSString stringWithFormat:@"%ld", [valueVar1 integerValue]/[valueVar2 integerValue]];
                }else{
                    stringValue = [NSString stringWithFormat:@"%f", [valueVar1 floatValue]/[valueVar2 floatValue]];
                }
                
            }
        }else if ([@"%" isEqualToString: operateSymbols[index_mdm]] ) {
            
            if ([self isNumberFormat:valueVar1]&&[self isNumberFormat:valueVar2]) {
                if ([self isMatchRegularExpression:@"\\d" forString:valueVar1] && [self isMatchRegularExpression:@"\\d" forString:valueVar2]) {
                    stringValue = [NSString stringWithFormat:@"%ld", [valueVar1 integerValue]%[valueVar2 integerValue]];
                    
                }else{
                    return -1;
                }
                
            }
        }
        
        //
        [operateSymbols removeObject:[operateSymbols firstObject]];
        [valueVars removeObject:[valueVars firstObject]];
        [valueVars removeObject:[valueVars firstObject]];
        [valueVars insertObject:stringValue atIndex:0];
        int mdm_rst = [self processAndAssignResultTo:value withOperateSymbols:operateSymbols valueAndVar:valueVars localVars:localVars];
        return mdm_rst;
    }
    
    // + -
    if (operateSymbols.count == 0) {
        NSLog(@"internal error 001");
        return -1;
    }
    if (valueVars.count<2) {
        NSLog(@"process error, stack: %@; %@", operateSymbols, valueVars);
        return -1;
    }
    NSString* valueString = nil;
    NSString* valueVar1 = valueVars[0];
    NSString* valueVar2 = valueVars[1];
    if ([self isVarFormat:valueVar1]) {
        valueVar1 = [NSString stringWithFormat:@"%@", [self valueOfVarByName:valueVar1 inLocalVar:localVars]];
        if (!valueVar1) {
            NSLog(@"no assign var '%@'", valueVar1);
            return -1;
        }
    }
    if ([self isVarFormat:valueVar2]) {
        valueVar2 = [NSString stringWithFormat:@"%@", [self valueOfVarByName:valueVar2 inLocalVar:localVars] ];
        if (!valueVar2) {
            NSLog(@"no assign var '%@'", valueVar2);
            return -1;
        }
    }
    
    if ([operateSymbols[0] isEqualToString:@"+"]) {
        if ([self isNumberFormat:valueVar1] && [self isNumberFormat:valueVar2]) {
            if ([self isMatchRegularExpression:@"\\d+" forString:valueVar1] && [self isMatchRegularExpression:@"\\d+" forString:valueVar2]) {
                valueString = [NSString stringWithFormat:@"%ld", valueVar1.integerValue+valueVar2.integerValue];
            }else{
                valueString = [NSString stringWithFormat:@"%f", valueVar1.floatValue+valueVar2.floatValue];
            }
        }else if([self isStringFormat:valueVar1] && [self isStringFormat:valueVar2]){
            
            valueString = [NSString stringWithFormat:@"\"%@%@\"", [valueVar1 substringWithRange:NSMakeRange(1, valueVar1.length-2)],[valueVar2 substringWithRange:NSMakeRange(1, valueVar2.length-2)] ];
        }else{
            NSLog(@"internal error, stack: %@", valueVar2);
            return -1;
        }
    }else if ([operateSymbols[0] isEqualToString:@"-"]){
        if ([self isNumberFormat:valueVar1] && [self isNumberFormat:valueVar2]) {
            if ([self isMatchRegularExpression:@"\\d+" forString:valueVar1] && [self isMatchRegularExpression:@"\\d+" forString:valueVar2]) {
                valueString = [NSString stringWithFormat:@"%ld", valueVar1.integerValue-valueVar2.integerValue];
            }else{
                valueString = [NSString stringWithFormat:@"%f", valueVar1.floatValue-valueVar2.floatValue];
            }
        }else{
            NSLog(@"internal error, stack: %@", valueVar2);
            return -1;
        }
    }else{
        NSLog(@"internal error, not recognise operate: %@", operateSymbols[0]);
        return -1;
    }
    
    
    [operateSymbols removeObject:[operateSymbols firstObject]];
    [valueVars removeObject:[valueVars firstObject]];
    [valueVars removeObject:[valueVars firstObject]];
    [valueVars insertObject:valueString atIndex:0];
    if (operateSymbols.count>0) {
        int mdm_rst = [self processAndAssignResultTo:value withOperateSymbols:operateSymbols valueAndVar:valueVars localVars:localVars];
        return mdm_rst;
    }else{
        [value insertObject:valueString atIndex:0];
        return 0;
    }
    
    //    return 0;
}


-(id) resultOfExpress:(NSString*)ep withLocalVars:(NSMutableDictionary*)l_vars{
    
    return @"abc";
}

-(id) resultOfExpress2:(NSArray*)ep withLocalVars:(NSMutableDictionary*)l_vars{
    NSMutableArray* operaterSymbols = [NSMutableArray new];
    NSMutableArray* valueVars = [NSMutableArray new];
    
    
    return @"abc";
}


-(BOOL) islegalQuotationMarksForExp:(NSString* )ep
                   SeprateOperateTo:(NSMutableArray*) operates
                         ValueVarTo:(NSMutableArray*) valVars{
    
    //    NSMutableCharacterSet* operateCharSet = [NSMutableCharacterSet new];
    //    [operateCharSet addCharactersInString:@"+-*/"];
    //
    //    NSRange abc = [ep rangeOfCharacterFromSet:operateCharSet];
    //
    //    NSLog(@"range:%lu,%lu, %@", (unsigned long)abc.location, (unsigned long)abc.length, [ep substringWithRange:abc]);
    
    // do some check
    if (operates==nil || [operates count] >0 || valVars==nil || [valVars count]>0) {
        NSLog(@"parameter error");
        return NO;
    }
    
    /*
     1. ()
     2. + - * /
     3. > < >=, <=
     4. =
     */
    NSSet* operateSet = [NSSet setWithObjects:@"(",@")",@"+",@"-",@"*",@"/",@"%",@"==",@">",@"<",@">=",@"<=",@"=", nil];
    NSSet* operateSet2 = [NSSet setWithObjects:@"==",@">",@"<",@">=",@"<=",@"=", nil];
    //    NSMutableArray* operates = [NSMutableArray new];
    
    /*
     0 string
     1 number
     3 bool
     4 func
     */
    //    NSMutableArray* valVars = [NSMutableArray new];
    
    NSInteger quotate_start = -1;
    NSInteger var_start = -1;
    NSInteger var_end = -1;
    
    for (int i=0; i<ep.length; i++) {
        NSString* cur_char = [ep substringWithRange:NSMakeRange(i, 1)];
        
        if ([cur_char isEqualToString:@" "]) {
            
            continue;
        }
        //
        if ([cur_char isEqualToString:@"\""]) {
            if (quotate_start >= 0) {
                [valVars addObject: [ep substringWithRange:NSMakeRange(quotate_start, i-quotate_start+1)]];
                quotate_start = -1;
                
            }else{
                quotate_start = i;
                
            }
            continue;
        }
        if (quotate_start >= 0) {
            continue;
        }
        
        // for operate mark
        if ([operateSet containsObject:cur_char]) {
            if ([operateSet2 containsObject:cur_char] && i+1<ep.length &&
                [[ep substringWithRange:NSMakeRange(i+1, 1)]isEqualToString:@"="])
            {
                // operate mark contain two char, eg: "==" "<="
                [operates addObject:[ep substringWithRange:NSMakeRange(i, 2)]];
                i++;
                //                continue;
            }else{
                // single char in operate mark
                [operates addObject:cur_char];
            }
            if (var_start>=0) {
                var_end = i;
                
            }
            
        }else if (quotate_start < 0 && var_start < 0){
            // cur is var
            var_start = i;
            
        }
        if (var_start>=0&&i==ep.length-1) {
            var_end=i+1;
        }
        
        if(var_start>=0 && var_end >= 0){
            [valVars addObject: [[ep substringWithRange:NSMakeRange(var_start, var_end-var_start)]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ];
            var_start = -1;
            var_end = -1;
        }
        
        //
    }
    
    if (quotate_start >= 0 || var_start >=0) {
        NSLog(@"quotate mark error, index:%ld",(long)quotate_start);
        return NO;
    }
    //    if ([[operates componentsJoinedByString:@""] length]+ [[valVars componentsJoinedByString:@""] length] != ep.length) {
    //        NSLog(@"internal error");
    //        return NO;
    //    }
    
    return YES;
}

-(id) valueOfVarByName:(NSString*)varName inLocalVar:(NSMutableDictionary*)localVars{
    if ([self isVarFormat:varName]) {
        T_Var* var_temp = [localVars objectForKey:varName];
        if (!var_temp) {
            NSMutableDictionary* sup_vars_tmp = [localVars objectForKey:@"*"];
            if (!sup_vars_tmp) {
                //                NSLog(@"no assign var '%@'", varName);
                return nil;
            }else{
                return [self valueOfVarByName:varName inLocalVar:sup_vars_tmp];
            }
        }else{
            return var_temp.value_;
        }
    }else{
        return nil;
    }
    return @"";
}

-(BOOL) isVarFormat:(NSString*) vf{
    //    if () {
    //
    //    }
    return [self isMatchRegularExpression:@"^[^0-9]\\w*$" forString:vf];
}

-(BOOL)isStringFormat:(NSString*) string{
    // strim
    if ([string hasPrefix:@"\""] || [string hasSuffix:@"\""]) {
        return YES;
    }else{
        return NO;
    }
    
}

-(BOOL)isNumberFormat:(NSString*) string{
    
    return [self isMatchRegularExpression:@"^\\d+(\\.\\d+)?$" forString:string];
}

-(BOOL)isMatchRegularExpression:(NSString*)re forString:(NSString*)str{
    //    NSString *staString = [NSString stringWithUTF8String:"[self.label setText: @\"hello world\"];"];
    //    NSString *parten = @"(\\s)*(\\[)(\\s)*(self)(\\s)*(.)(\\s)*(label)(\\s)*(setText)(\\s)*(:)(\\s)*(@)(\\s)*(\".*\")(\\s)*(\\])(\\s)*(;)(\\s)*";
    
    NSError* error = NULL;
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:re options:nil error:&error];
    
    NSArray* match = [reg matchesInString:str options:NSMatchingCompleted range:NSMakeRange(0, [str length])];
    
    if (match.count != 0)
    {
        //        for (NSTextCheckingResult *matc in match)
        //        {
        //            NSRange range = [matc range];
        //            NSLog(@"%lu,%lu,%@",(unsigned long)range.location,(unsigned long)range.length,[str substringWithRange:range]);
        //        }
        return YES;
    }
    return NO;
}

-(void)test{
    //    NSMutableArray* operates = [NSMutableArray new];
    //    NSMutableArray* valueVars = [NSMutableArray new];
    //    BOOL rst = [self islegalQuotationMarksForExp:@"abc + \"uuu9\" + efg + \"abc\"" SeprateOperateTo:operates ValueVarTo:valueVars];
    //    NSLog(@"result:%@, operates:%@ valueVars:%@", rst?@"YES":@"NO", operates, valueVars);
    
    NSLog(@"r:%@", [self isNumberFormat:@"213423.23423"]?@"YES":@"NO");
    NSLog(@"r:%@", [self isNumberFormat:@"21342sdf3"]?@"YES":@"NO");
    NSLog(@"r:%@", [self isStringFormat:@"213423.23423"]?@"YES":@"NO");
    NSLog(@"r:%@", [self isVarFormat:@"abc"]?@"YES":@"NO");
    
    [self parseScriptFile:@""];
}
@end


