//
//  Utils.m
//  JSONCreatorPlus
//
//  Created by andylee1988 on 13-4-10.
//  Copyright (c) 2013年 andylee1988. All rights reserved.
//

#import "Utils.h"



@implementation Utils



+ (JsonValueType)jsonType:(id)obj {
    if([[obj className] isEqualToString:@"NSTaggedPointerString"]||[[obj className] isEqualToString:@"__NSCFString"] || [[obj className] isEqualToString:@"__NSCFConstantString"]) {
        return kJsonValueTypeString;
    }
    else if([[obj className] isEqualToString:@"__NSCFNumber"]) {
        return kJsonValueTypeNumber;
    }
    else if([[obj className] isEqualToString:@"__NSCFBoolean"]) {
        return kJsonValueTypeBool;
    }
    else if([[obj className] isEqualToString:@"__NSDictionaryI"]||[[obj className] isEqualToString:@"__NSCFDictionary"]) {
        return kJsonValueTypeDictionary;
    }
    else if([[obj className] isEqualToString:@"__NSArrayI"]||[[obj className] isEqualToString:@"__NSCFArray"]) {
        return kJsonValueTypeArray;
    }
    return -1;
}

+ (NSString *)typeName:(JsonValueType)type {
    switch (type) {
        case kJsonValueTypeString:
            return @"NSString";
            break;
        case kJsonValueTypeNumber:
            return @"NSNumber";
            break;
        case kJsonValueTypeBool:
            return @"BOOL";
            break;
        case kJsonValueTypeArray:
//            return @"NSArray";
//            break;
        case kJsonValueTypeDictionary:
//            return @"NSDictionary";
            return @"";
            break;
            
        default:
            break;
    }
}


//表示该数组内有且只有字典 并且 结构一致。
+ (BOOL)isDictionaryArray:(NSArray *)aArray {
    if(aArray.count <=0 ) {
        return NO;
    }
    for(id item in aArray) {
        NSLog(@"%@",[item className]);
        if([self jsonType:item] != kJsonValueTypeDictionary) {
            return NO;
        }
    }
    
    NSMutableSet *keys = [NSMutableSet set];
    for(NSString *key in [[aArray objectAtIndex:0] allKeys]) {
        [keys addObject:key];
    }
    
    
    for(id item in aArray)
    {
        NSMutableSet *newKeys = [NSMutableSet set];
        for(NSString *key in [item allKeys])
        {
            [newKeys addObject:key];
        }
        
        if([keys isEqualToSet:newKeys] == NO)
        {
            return NO;
        }
    }
    return YES;
}

+ (NSString *)uppercaseFirstChar:(NSString *)str {
    return [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] uppercaseString],[str substringWithRange:NSMakeRange(1, str.length-1)]];
}

+ (NSString *)lowercaseFirstChar:(NSString *)str {
    return [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] lowercaseString],[str substringWithRange:NSMakeRange(1, str.length-1)]];
}




@end
