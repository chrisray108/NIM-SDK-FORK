//
//  NIMTestCustomObject.m
//  NIMLib
//
//  Created by amao on 12/28/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMTestCustomObject.h"

@implementation NIMTestEmptyAttachment
- (NSString *)encodeAttachment
{
    NSDictionary *dict =  @{@"type" : @(1)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    return dataString;
}


@end

@implementation NIMTestCustomObject
- (id<NIMCustomAttachment>)decodeAttachment:(NSString *)content
{
    id<NIMCustomAttachment>object = nil;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data)
    {
        id dict = [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            NSInteger type = [[dict objectForKey:@"type"] integerValue];
            switch (type) {
                case 1:
                    object = [[NIMTestEmptyAttachment alloc] init];
                    break;
                    
                default:

                    break;
            }
        }
    }
    return object;
}
@end
