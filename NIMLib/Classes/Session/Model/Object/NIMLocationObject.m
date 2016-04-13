//
//  NIMLocationMessageBody.m
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMLocationObject_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NIMMessageDownloadParam.h"

@implementation NIMLocationObject

@synthesize message = _message;

- (instancetype)initWithLatitude:(double)latitude
                       longitude:(double)longitude
                           title:(NSString *)title{
    self = [self init];
    if (self) {
        _latitude  = latitude;
        _longitude = longitude;
        _title     = [title copy];
    }
    return self;
}


- (NIMMessageType)type{
    return NIMMessageTypeLocation;
}

- (NSString*)encodeContent{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    if (_title.length) {
        [dict setObject:_title forKey:NIMMessageObjTagAddress];
    }
    [dict setObject:@(_latitude) forKey:NIMMessageObjTagLatitude];
    [dict setObject:@(_longitude) forKey:NIMMessageObjTagLongitude];
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (data)
    {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else
    {
        NIMLogErr(@"encode object failed %@",dict);
        return nil;
    }
}


- (void)decodeWithContent:(NSString*)content
{
    NSData * data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            _title        = [dict nim_jsonString:NIMMessageObjTagAddress];
            _latitude     = [dict nim_jsonDouble:NIMMessageObjTagLatitude];
            _longitude    = [dict nim_jsonDouble:NIMMessageObjTagLongitude];
        }
        else
        {
            NIMLogErr(@"decode object content failed %@",content);
        }
    }
    else
    {
        NIMLogErr(@"decode object content failed %@",content);
    }
}

@end
