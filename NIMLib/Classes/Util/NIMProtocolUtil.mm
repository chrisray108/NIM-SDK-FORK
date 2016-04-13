//
//  NIMProtocolUtil.m
//  NIMLib
//
//  Created by amao on 3/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMProtocolUtil.h"
#import "NSDictionary+NIMJson.h"
#import "NSObject+NIM.h"

@implementation NIMProtocolUtil
+ (std::list<nimbiz::UTF8String>)arrayToStringList:(NSArray *)array
{
    std::list<nimbiz::UTF8String> strList;
    if ([array isKindOfClass:[NSArray class]])
    {
        for (id obj in array)
        {
            if ([obj isKindOfClass:[NSString class]])
            {
                strList.push_back(UTF8(obj));
            }
        }
    }
    return strList;
}

+ (NSArray *)stringListToArray:(const std::list<nimbiz::UTF8String> &)strList
{
    NSMutableArray *array = [NSMutableArray array];
    for (auto it = strList.begin(); it != strList.end(); it++)
    {
        [array addObject:NSUTF8(*it)];
    }
    return array;
}

+ (NSArray *)stringVectorToArray:(const std::vector<nimbiz::UTF8String> &)strVector
{
    NSMutableArray *array = [NSMutableArray array];
    for (auto it = strVector.begin(); it != strVector.end(); it++)
    {
        [array addObject:NSUTF8(*it)];
    }
    return array;
}

+ (nimbiz::Property)dictToProperty:(NSDictionary *)dict
{
    nimbiz::Property info;
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        for (NSString *key in dict.allKeys)
        {
            NSString *value = [dict nim_jsonString:key];
            if (value)
            {
                info.put_string((int32_t)[key integerValue], UTF8(value));
            }
        }
    }
    
    return info;
}

+ (nimbiz::UTF8String)stringByJsonDictionary:(NSDictionary *)dict
{
    nimbiz::UTF8String result;
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
        if (error) {
            NIMLogErr(@"stringByJsonDictionary failed %@ error %@",dict,error);
        }
        if (data)
        {
            NSString *jsonString = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
            result = UTF8(jsonString);
        }
    }
    return result;
}

+ (NSDictionary *)dictByJsonString:(const nimbiz::UTF8String &)jsonString
{
    NSDictionary *dict = nil;
    NSData *data = [NSUTF8(jsonString) dataUsingEncoding:NSUTF8StringEncoding];
    if (data && [data length])
    {
        NSError *error = nil;
        dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:0
                                                 error:&error];
        if (error) {
            NIMLogErr(@"dictByJsonString failed %s error %@",jsonString.c_str(),error);
        }
    }
    return [dict nim_asObject:[NSDictionary class]];
}


+ (NSData *)jsonData:(NSDictionary *)dict
{
    NSData *data = nil;
    if([dict isKindOfClass:[NSDictionary class]])
    {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:dict
                                               options:0
                                                 error:&error];
        if (error) {
            NIMLogErr(@"jsonData failed %@ error %@",dict,error);
        }
    }
    return data;
}

+ (NSDictionary *)dictByJsonData:(NSData *)data
{
    NSDictionary *dict = nil;
    if ([data isKindOfClass:[NSData class]])
    {
        NSError *error = nil;
        dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:0
                                                 error:&error];
        if (error) {
            NIMLogErr(@"dictByJsonData failed %@ error %@",data,error);
        }
    }
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}

@end
