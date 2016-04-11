//
//  JSONWindowController.m
//  JSONCreatorPlus
//
//  Created by andylee1988 on 13-4-10.
//  Copyright (c) 2013年 andylee1988. All rights reserved.
//

#import "JSONWindowController.h"

#define kPrefixString       @"str"
#define kPrefixNumber       @"num"
#define kPrefixBool         @"b"
#define kPrefixArray        @"array"
#define kPrefixDictionary   @"dictionary"
#define kPrefixMutableArray @"mArray"


@interface JSONWindowController ()

@end

@implementation JSONWindowController
@synthesize jsonContentTextView;
@synthesize classNameTextField;
@synthesize jsonURLTextField;
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    
}

- (IBAction)useTestURLAction:(id)sender {
    jsonURLTextField.stringValue = @"http://api4app.sinaapp.com/test2.php?category=default";
}

- (IBAction)getJSONWithURLAction:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *strURL = [jsonURLTextField.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        NSURL *url = [NSURL URLWithString:strURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil
                                                         error:nil];
        if (data) {
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(jsonDic) {
                dispatch_async(dispatch_get_main_queue(),^(void){
                    jsonContentTextView.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                });
            } else {
                jsonContentTextView.string = @"无效的JSON数据";
            }
        } else {
            jsonContentTextView.string = @"无效的数据";
        }
    });
}

- (IBAction)generateClassAction:(id)sender {
    
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[jsonContentTextView.string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
//    NSDictionary *jsonDic = [jsonContentTextView.string objectFromJSONString];
    if (jsonDic) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        panel.canChooseDirectories = YES;
        panel.canCreateDirectories = YES;
        [panel setPrompt:@"Save"];
        panel.canChooseFiles = NO;
        [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
            if(result == 0){
                return;
            }
            
            strPath = [panel.URL path];
            [self generateClass:classNameTextField.stringValue forDic:jsonDic];
            
            jsonContentTextView.string = [NSString stringWithFormat:@"Create .h.m(ARC) files successfully, and the directory is: %@",strPath];
            
        }];
    }
    else {
        jsonContentTextView.string = @"JSON is invalid";
    }
}

-(void)generateClass:(NSString*)strName forDic:(NSDictionary *)jsonDic {
    //准备模板
    NSMutableString *mStrTemplateH =[[NSMutableString alloc]
                                     initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"JSONTemplateH" ofType:@"lcm"]
                                     encoding:NSUTF8StringEncoding
                                     error:nil];
    NSMutableString *mStrTemplateM =[[NSMutableString alloc]
                                     initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"JSONTemplateM" ofType:@"lcm"]
                                     encoding:NSUTF8StringEncoding
                                     error:nil];
    
    //.h
    //name
    //property
    
    NSMutableString *mStrProterty = [NSMutableString string];
    NSMutableString *mStrImport = [NSMutableString string];
    
    for (NSString *strKey in jsonDic.allKeys) {
        
        JsonValueType jsonValueType = [Utils jsonType:[jsonDic objectForKey:strKey]];
        switch (jsonValueType) {
            case kJsonValueTypeString:
                [mStrProterty appendFormat:@"@property (nonatomic,strong) %@ *%@%@;\n",[Utils typeName:jsonValueType],kPrefixString,[Utils uppercaseFirstChar:strKey]];
                break;
            case kJsonValueTypeNumber:
                [mStrProterty appendFormat:@"@property (nonatomic,strong) %@ *%@%@;\n",[Utils typeName:jsonValueType],kPrefixNumber,[Utils uppercaseFirstChar:strKey]];
                break;
            case kJsonValueTypeArray:
                
                if ([Utils isDictionaryArray:[jsonDic objectForKey:strKey]]) {
                    [mStrProterty appendFormat:@"@property (nonatomic,strong) NSMutableArray *%@%@;\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey]];
                    [mStrImport appendFormat:@"#import \"%@EntityVO.h\"",[Utils uppercaseFirstChar:strKey]];
                    [self generateClass:[NSString stringWithFormat:@"%@EntityVO",[Utils uppercaseFirstChar:strKey]]
                                 forDic:[[jsonDic objectForKey:strKey]objectAtIndex:0]];
                } else {
                    [mStrProterty appendFormat:@"@property (nonatomic,strong) NSMutableArray *%@%@;\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey]];
                }
                break;
            case kJsonValueTypeDictionary:
                [mStrProterty appendFormat:@"@property (nonatomic,strong) %@EntityVO *%@EntityVO;\n",[Utils uppercaseFirstChar:strKey],[Utils lowercaseFirstChar:strKey]];
                [mStrImport appendFormat:@"#import \"%@EntityVO.h\"\n",[Utils uppercaseFirstChar:strKey]];
                [self generateClass:[NSString stringWithFormat:@"%@EntityVO",[Utils uppercaseFirstChar:strKey]]
                             forDic:[jsonDic objectForKey:strKey]];
                break;
            case kJsonValueTypeBool:
                [mStrProterty appendFormat:@"@property (nonatomic,assign) %@ %@%@;\n",[Utils typeName:jsonValueType],kPrefixBool,[Utils uppercaseFirstChar:strKey]];
                break;
                
            default:
                break;
        }
    }
    [mStrTemplateH replaceOccurrencesOfString:@"#name#"
                                   withString:strName
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, mStrTemplateH.length)];
    [mStrTemplateH replaceOccurrencesOfString:@"#import#"
                                   withString:mStrImport
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, mStrTemplateH.length)];
    [mStrTemplateH replaceOccurrencesOfString:@"#property#"
                                   withString:mStrProterty
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, mStrTemplateH.length)];
    
    //.m
    //NSCoding
    //name
    [mStrTemplateM replaceOccurrencesOfString:@"#name#"
                                   withString:strName
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, mStrTemplateM.length)];
    
    
    NSMutableString *config = [NSMutableString string];
    NSMutableString *encode = [NSMutableString string];
    NSMutableString *decode = [NSMutableString string];
    NSMutableString *description = [NSMutableString string];
    NSMutableString *toDic = [NSMutableString string];
    NSDictionary *dicList =  @{
                               @"config":config,
                               @"encode":encode,
                               @"decode":decode,
                               @"description":description,
                               @"toDic":toDic
                               };
    
    
    for(NSString *strKey in [jsonDic allKeys])
    {
        JsonValueType jsonValueType = [Utils jsonType:[jsonDic objectForKey:strKey]];
        switch (jsonValueType) {
            case kJsonValueTypeString:
                [config appendFormat:@"self.%@%@  = [aDicJson objectForKey:@\"%@\"];\n ",kPrefixString,[Utils uppercaseFirstChar:strKey],strKey];
                [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"lcm_%@\"];\n",kPrefixString,[Utils uppercaseFirstChar:strKey],strKey];
                [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"lcm_%@\"];\n ",kPrefixString,[Utils uppercaseFirstChar:strKey],strKey];
                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",kPrefixString,[Utils uppercaseFirstChar:strKey],kPrefixString,[Utils uppercaseFirstChar:strKey]];

                [toDic appendFormat:@"[mDic setObject:self.%@%@?self.%@%@:@\"\" forKey:@\"%@\"];\n",kPrefixString,[Utils uppercaseFirstChar:strKey],kPrefixString,[Utils uppercaseFirstChar:strKey],strKey];
                
                break;
            case kJsonValueTypeNumber:
                [config appendFormat:@"self.%@%@  = [aDicJson objectForKey:@\"%@\"];\n ",kPrefixNumber,[Utils uppercaseFirstChar:strKey],strKey];
                [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"lcm_%@\"];\n",kPrefixNumber,[Utils uppercaseFirstChar:strKey],strKey];
                [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"lcm_%@\"];\n ",kPrefixNumber,[Utils uppercaseFirstChar:strKey],strKey];
                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",kPrefixNumber,[Utils uppercaseFirstChar:strKey],kPrefixNumber,[Utils uppercaseFirstChar:strKey]];
                
                
                [toDic appendFormat:@"[mDic setObject:self.%@%@?self.%@%@:[NSNumber numberWithInt:0] forKey:@\"%@\"];\n",kPrefixNumber,[Utils uppercaseFirstChar:strKey],kPrefixNumber,[Utils uppercaseFirstChar:strKey],strKey];
                
                break;
            case kJsonValueTypeArray:
            {
                if([Utils isDictionaryArray:[jsonDic objectForKey:strKey]])
                {
                    [config appendFormat:@"self.%@%@ = [NSMutableArray array];\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey]];
                    [config appendFormat:@"if ([[aDicJson objectForKey:@\"%@\"] isKindOfClass:[NSArray class]]) {\nfor(NSDictionary *item in [aDicJson objectForKey:@\"%@\"])\n",strKey,strKey];
                    [config appendString:@"{\n"];
                    [config appendFormat:@"[self.%@%@ addObject:[[%@EntityVO alloc] initWithJson:item]];\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],[Utils uppercaseFirstChar:strKey]];
                    [config appendString:@"}\n}\n"];
                    [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"lcm_%@\"];\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],strKey];
                    [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"lcm_%@\"];\n ",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],strKey];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],kPrefixMutableArray,[Utils uppercaseFirstChar:strKey]];
                    [toDic appendFormat:@"NSMutableArray *mA%@ = [NSMutableArray array];\n",[Utils uppercaseFirstChar:strKey]];
                    [toDic appendFormat:@"for(%@EntityVO *vo in self.%@%@){\n[mA%@ addObject:[vo dictionary]];\n}\n",[Utils uppercaseFirstChar:strKey],kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],[Utils uppercaseFirstChar:strKey]];
                    [toDic appendFormat:@"[mDic setObject:mA%@ forKey:@\"%@\"];",[Utils uppercaseFirstChar:strKey],strKey];

                    
                } else {
                    [config appendFormat:@"self.%@%@ = [NSMutableArray array];\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey]];
                    [config appendFormat:@"if ([[aDicJson objectForKey:@\"%@\"] isKindOfClass:[NSArray class]]) {\nfor(id item in [aDicJson objectForKey:@\"%@\"])\n",strKey,strKey];
                    [config appendString:@"{\n"];
                    
                    
                    [config appendFormat:@"[self.%@%@ addObject:item];\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey]];
                    
                    [config appendString:@"}\n}\n"];
                    
                    [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"lcm_%@\"];\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],strKey];
                    [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"lcm_%@\"];\n ",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],strKey];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],kPrefixMutableArray,[Utils uppercaseFirstChar:strKey]];
                    
                    [toDic appendFormat:@"NSMutableArray *mA%@ = [NSMutableArray array];\n",[Utils uppercaseFirstChar:strKey]];
                    [toDic appendFormat:@"for(NSString *str in self.%@%@){\n[mA%@ addObject:[vo dictionary]];\n}\n",kPrefixMutableArray,[Utils uppercaseFirstChar:strKey],[Utils uppercaseFirstChar:strKey]];
                    [toDic appendFormat:@"[mDic setObject:mA%@ forKey:@\"%@\"];",strKey,[Utils uppercaseFirstChar:strKey]];
                }
            }
                break;
            case kJsonValueTypeDictionary:
                [config appendFormat:@"self.%@EntityVO  = [[%@EntityVO alloc] initWithJson:[aDicJson objectForKey:@\"%@\"]];\n ",[Utils lowercaseFirstChar:strKey],[Utils uppercaseFirstChar:strKey],strKey];
                [encode appendFormat:@"[aCoder encodeObject:self.%@EntityVO forKey:@\"lcm_%@\"];\n",[Utils lowercaseFirstChar:strKey],strKey];
                [decode appendFormat:@"self.%@EntityVO = [aDecoder decodeObjectForKey:@\"lcm_%@\"];\n ",[Utils lowercaseFirstChar:strKey],strKey];
                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@EntityVO : %%@\\n\",self.%@EntityVO];\n",[Utils lowercaseFirstChar:strKey],[Utils lowercaseFirstChar:strKey]];
                
                [toDic appendFormat:@"[mDic setObject:[self.%@EntityVO dictionary] forKey:@\"%@\"];\n",[Utils lowercaseFirstChar:strKey],strKey];
                break;
            case kJsonValueTypeBool:
                [config appendFormat:@"self.%@%@ = [[aDicJson objectForKey:@\"%@\"]boolValue];\n ",kPrefixBool,[Utils uppercaseFirstChar:strKey],strKey];
                [encode appendFormat:@"[aCoder encodeBool:self.%@%@ forKey:@\"lcm_%@\"];\n",kPrefixBool,[Utils uppercaseFirstChar:strKey],strKey];
                [decode appendFormat:@"self.%@%@ = [aDecoder decodeBoolForKey:@\"lcm_%@\"];\n",kPrefixBool,[Utils uppercaseFirstChar:strKey],strKey];
                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@?@\"yes\":@\"no\"];\n",kPrefixBool,[Utils uppercaseFirstChar:strKey],kPrefixBool,[Utils uppercaseFirstChar:strKey]];
                [toDic appendFormat:@"[mDic setObject:[NSNumber numberWithBool:self.%@%@] forKey:@\"%@\"];\n",kPrefixBool,[Utils uppercaseFirstChar:strKey],strKey];
                break;
            default:
                break;
        }
    }
    
    //修改模板
    for(NSString *strKey in [dicList allKeys])
    {
        [mStrTemplateM replaceOccurrencesOfString:[NSString stringWithFormat:@"#%@#",strKey]
                                       withString:[dicList objectForKey:strKey]
                                          options:NSCaseInsensitiveSearch
                                            range:NSMakeRange(0, mStrTemplateM.length)];
    }
    
    
    //写文件
    
    [mStrTemplateH writeToFile:[NSString stringWithFormat:@"%@/%@.h",strPath,strName]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
    
    [mStrTemplateM writeToFile:[NSString stringWithFormat:@"%@/%@.m",strPath,strName]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
}


@end



































