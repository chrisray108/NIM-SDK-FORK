//
//  NIMClientManager.m
//  NIMLib
//
//  Created by amao on 4/22/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMClientManager.h"
#import "NIMLoginManagerProtocol.h"
#import "NIMLoginClient_Private.h"
#import "NIMDelegateCenter.h"

@interface NIMClientManager ()
@property (nonatomic,strong)    NSMutableArray  *clients;
@end

@implementation NIMClientManager
- (instancetype)init
{
    if (self = [super init])
    {
        _clients = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)currentClients
{
    return [_clients copy];
}

- (void)onClientsChanged:(NSArray *)clients
                    type:(NIMMultiLoginType)type
{
    BOOL changed = YES;
    switch (type) {
        case NIMMultiLoginTypeInit:
        {
            NSInteger count = [_clients count];
            [_clients removeAllObjects];
            [self addClients:clients];
            if (count == 0 && [_clients count] == 0)
            {
                changed = NO;
            }
        }
            break;
        case NIMMultiLoginTypeLogin:
        {
            [self removeClients:clients];   //去掉可能重复的
            [self addClients:clients];
        }
            break;
        case NIMMultiLoginTypeLogout:
        {
            [self removeClients:clients];
        }
            break;
        default:
            NIMAssert();
            break;
    }
    if (changed)
    {
        [[NIMDelegateCenter loginDelegate] onMultiLoginClientsChanged];
    }
}

- (void)removeClientsByDeviceId:(NSArray *)deviceIds
{
    if ([deviceIds count])
    {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSString *deviceId in deviceIds)
        {
            for (NSInteger i = 0; i < [_clients count]; i++)
            {
                NIMLoginClient *client = [_clients objectAtIndex:i];
                if ([deviceId isEqualToString:client.deviceId])
                {
                    [indexSet addIndex:i];
                    break;
                }
            }
        }
        if ([indexSet count])
        {
            [_clients removeObjectsAtIndexes:indexSet];
            [[NIMDelegateCenter loginDelegate] onMultiLoginClientsChanged];
            
        }
    }
}


- (void)onLoginOK
{
    BOOL empty = [_clients count] == 0;
    [_clients removeAllObjects];
    if (!empty)
    {
         [[NIMDelegateCenter loginDelegate] onMultiLoginClientsChanged];
    }
}

- (void)removeClients:(NSArray *)clients
{
    if ([clients count])
    {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NIMLoginClient *client in clients)
        {
            for (NSInteger i = 0; i < [_clients count]; i++)
            {
                NIMLoginClient *inClient = [_clients objectAtIndex:i];
                if (client.deviceId && inClient.deviceId &&
                    [client.deviceId isEqualToString:inClient.deviceId])
                {
                    [indexSet addIndex:i];
                    break;
                }
            }
        }
        if ([indexSet count])
        {
            [_clients removeObjectsAtIndexes:indexSet];
        }
    }
}

- (void)addClients:(NSArray *)clients
{
    if ([clients count])
    {
        [_clients addObjectsFromArray:clients];
    }
}
@end
