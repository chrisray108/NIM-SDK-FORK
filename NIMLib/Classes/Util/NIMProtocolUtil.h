//
//  NIMProtocolUtil.h
//  NIMLib
//
//  Created by amao on 3/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <list>
#import "document.h"

@interface NIMProtocolUtil : NSObject
+ (std::list<nimbiz::UTF8String>)arrayToStringList:(NSArray *)array;

+ (NSArray *)stringListToArray:(const std::list<nimbiz::UTF8String>&)strList;

+ (NSArray *)stringVectorToArray:(const std::vector<nimbiz::UTF8String>&)strVector;

+ (nimbiz::Property)dictToProperty:(NSDictionary *)dict;

+ (nimbiz::UTF8String)stringByJsonDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictByJsonString:(const nimbiz::UTF8String &)jsonString;

+ (NSData *)jsonData:(NSDictionary *)dict;

+ (NSDictionary *)dictByJsonData:(NSData *)data;
@end
