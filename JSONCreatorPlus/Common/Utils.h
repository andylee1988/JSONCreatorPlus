//
//  Utils.h
//  JSONCreatorPlus
//
//  Created by andylee1988 on 13-4-10.
//  Copyright (c) 2013年 andylee1988. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum
{
    kJsonValueTypeString = 0,
    kJsonValueTypeNumber = 1,
    kJsonValueTypeArray  = 2,
    kJsonValueTypeDictionary = 3,
    kJsonValueTypeBool   = 4,
} JsonValueType;

@interface Utils : NSObject {
    
}

+ (JsonValueType)jsonType:(id)obj;
+ (NSString *)typeName:(JsonValueType)type;
+ (BOOL)isDictionaryArray:(NSArray *)aArray;
+ (NSString *)uppercaseFirstChar:(NSString *)str;
+ (NSString *)lowercaseFirstChar:(NSString *)str;

@end
