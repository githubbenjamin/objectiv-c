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
    
    return 0;
}

-(int) parseMainBlock:(NSString *)ep withLocalVars:(NSMutableDictionary*) l_vars{

    
    //
    NSArray* logical_lines = [ep componentsSeparatedByString: @";"];
    for (NSString* ll in logical_lines) {
        
        
    }
    
    return 0;
}

-(int)parseLogicalLine:(NSString *)express withLocalVars:(NSMutableDictionary *)localVars{
    NSMutableArray* operaterSymbols = [NSMutableArray new];
    NSMutableArray* valueVars = [NSMutableArray new];
    
    NSSet* oss1 = [[NSSet alloc]initWithObjects:@"(",@")", nil];
    NSSet* oss2 = [[NSSet alloc]initWithObjects:@"+",@"-",@"*",@"/" ,nil];
    NSSet* oss3 = [[NSSet alloc]initWithObjects:@"==",@">",@"<",@">=",@"<=", nil];
    NSSet* oss4 = [[NSSet alloc]initWithObjects:@"=", nil];
    
    if (![self islegalQuotationMarksForExp:express SeprateOperateTo:operaterSymbols ValueVarTo:valueVars]) {
        NSLog(@"not legal for logical line");
        return -1;
    }
    
    
    
    //
    
//    if () {
//        
//    }
    
    return 0;
}

-(int)process:(NSMutableArray*)operateSymbols valueAndVar:(NSMutableArray*)valueVars localVars:(NSMutableDictionary*)localVars{
    
    
    return 0;
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
    NSSet* operateSet = [NSSet setWithObjects:@"(",@")",@"+",@"-",@"*",@"/",@"==",@">",@"<",@">=",@"<=",@"=", nil];
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
    
-(BOOL) isVarFormat:(NSString*) vf{
//    if () {
//        
//    }
    return YES;
}

-(void)test{
    NSMutableArray* operates = [NSMutableArray new];
    NSMutableArray* valueVars = [NSMutableArray new];
    BOOL rst = [self islegalQuotationMarksForExp:@"abc + \"uuu9\" + efg + \"abc\"" SeprateOperateTo:operates ValueVarTo:valueVars];
    NSLog(@"result:%@, operates:%@ valueVars:%@", rst?@"YES":@"NO", operates, valueVars);
    
}
@end


