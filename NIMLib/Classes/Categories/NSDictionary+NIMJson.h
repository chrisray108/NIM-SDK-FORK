//
//  NSDictionary+NTESJson.h
//  NIM
//
//  Created by amao on 13-7-12.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NIMJson)
- (NSString *)nim_jsonString: (NSString *)key;

- (NSDictionary *)nim_jsonDict: (NSString *)key;
- (NSArray *)nim_jsonArray: (NSString *)key;
- (NSArray *)nim_jsonStringArray: (NSString *)key;


- (BOOL)nim_jsonBool: (NSString *)key;
- (BOOL)nim_jsonBool:(NSString *)key
        defaultValue:(BOOL)value;

- (NSInteger)nim_jsonInteger: (NSString *)key;
- (long long)nim_jsonLongLong: (NSString *)key;
- (unsigned long long)nim_jsonUnsignedLongLong:(NSString *)key;

- (double)nim_jsonDouble: (NSString *)key;
@end
