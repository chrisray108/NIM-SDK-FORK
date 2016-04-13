//
//  NIMChatroomToken.m
//  NIMLib
//
//  Created by amao on 12/15/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroomToken.h"
#import "NIMChatroomManager.h"

@implementation NIMChatroomAddress

- (NSString *)description
{
    return [NSString stringWithFormat:@"ip %@ port %zd",_ip,_port];
}

@end

@interface NIMChatroomToken ()
@property (nonatomic,copy)      NSString *roomId;
@property (nonatomic,strong)    NSArray *addresses;
@property (nonatomic,assign)    NSInteger index;
@property (nonatomic,assign)    NSInteger errorTimes;
@end

@implementation NIMChatroomToken


+ (instancetype)tokenBy:(NSArray *)addresses
                 roomId:(NSString *)roomId
{
    NIMChatroomToken *instance = [[NIMChatroomToken alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *address in addresses)
    {
        NSArray *sep = [address componentsSeparatedByString:@":"];
        if ([sep count] == 2)
        {
            NIMChatroomAddress *item = [[NIMChatroomAddress alloc] init];
            item.ip = [sep firstObject];
            item.port = [[sep lastObject] integerValue];
            [items addObject:item];
        }
    }
    instance.addresses = items;
    instance.roomId = roomId;
    return instance;
    
}


- (void)reportHostError:(BOOL)fatal
{
    if (fatal)
    {
        _index++;
        _errorTimes = 0;
    }
    else
    {
        _errorTimes++;
        if (_errorTimes > 3)
        {
            _index++;
            _errorTimes = 0;
        }
    }
    if (_index >= [_addresses count])
    {
        [self refresh];
        _index = 0;
    }
}

- (NIMChatroomAddress *)address
{
    if (_index > 0 && _index < [_addresses count])
    {
        return [_addresses objectAtIndex:_index];
    }
    else
    {
        _index = 0;
        return [_addresses firstObject];
    }
}

- (NSString *)description
{
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendFormat:@"TOKEN room %@ ",_roomId];
    [description appendString:@"[ "];
    for (NIMChatroomAddress *address in _addresses)
    {
        [description appendFormat:@"%@ ",address];
    }
    [description appendFormat:@"index %zd",_index];
    [description appendString:@" ]"];
    return [description copy];
}

- (void)refresh
{
    NIMLogApp(@"should refresh chatroom token %@",self);
    __weak typeof(self) weakSelf = self;
    [[NIMChatroomManager sharedManager] requestToken:_roomId
                                          completion:^(NSError *error, NIMChatroomToken *token) {
                                              if (error == nil && token)
                                              {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                  [strongSelf update:token];
                                                  NIMLogApp(@"update token %@",token);
                                              }
                                          }];
}

- (void)update:(NIMChatroomToken *)token
{
    _index = 0;
    _errorTimes = 0;
    _addresses = token.addresses;
}
@end
