//
//  NIMUserInfoManager.m
//  NIMLib
//
//  Created by amao on 12/7/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMUserInfoManager.h"
#import "NIMDispatch.h"
#import "user_protocol.h"
#import "NIMUserManager.h"
#import "NIMSystemNotification_Priviate.h"
#import "NIMCustomSystemNotification_Private.h"

@interface NIMUserInfoManager ()
@property (nonatomic,assign)    BOOL                    inRequest;
@property (nonatomic,strong)    NSMutableArray     *requestUserIds;
@end

@implementation NIMUserInfoManager
- (instancetype)init
{
    if (self = [super init])
    {
        _requestUserIds = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)checkUserInfo:(NSArray *)userIds
{
    if ([userIds count])
    {
        __weak typeof(self) weakSelf = self;
        dispatch_async(NIMGetTaskQueue(), ^{
            NSArray *requestUserIds = [weakSelf userIdWithoutInfo:userIds];
            if ([requestUserIds count])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf requestUserIds:requestUserIds];
                });
            }
        });
    }
}

- (NSArray *)userIdWithoutInfo:(NSArray *)userIds
{
    NSMutableArray *result = [NSMutableArray array];
    nimbiz::IUserService *service = (nimbiz::IUserService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service)
    {
        for (NSString *userId in userIds)
        {
            if (!service->UserInfoExists(UTF8(userId)))
            {
                [result addObject:userId];
            }
        }
    }
    return result;
}

- (void)requestUserIds:(NSArray *)userIds
{
    for (NSString *userId in userIds)
    {
        if (![_requestUserIds containsObject:userId])
        {
            [_requestUserIds addObject:userId];
            NIMLogApp(@"should request info for userid %@",userId);
        }
    }
    [self request];
}

- (void)request
{
    static NSUInteger MaxBatchReuqestCount = 10;
    if (_inRequest || [_requestUserIds count] == 0) {
        return;
    }
    _inRequest = YES;
    NSArray *userIds = [_requestUserIds count] > MaxBatchReuqestCount ?
    [_requestUserIds subarrayWithRange:NSMakeRange(0, MaxBatchReuqestCount)] : [_requestUserIds copy];
    
    NIMLogApp(@"request user ids %@",userIds);
    __weak typeof(self) weakSelf = self;
    [[NIMUserManager sharedManager] fetchUserInfos:userIds
                                        completion:^(NSArray *users, NSError *error) {
                                            NIMLogApp(@"request user ids %@ error %@",userIds,error);
                                            [weakSelf afterReuquest:userIds];
                                            
                                        }];
}

- (void)afterReuquest:(NSArray *)userIds
{
    _inRequest = NO;
    [_requestUserIds removeObjectsInArray:userIds];
    [self request];
    
}

#pragma mark - public api
- (void)checkSystemNotification:(NIMSystemNotification *)notification
{
    NSString *sourceId = [notification sourceID];
    if ([sourceId isKindOfClass:[NSString class]])
    {
        [self checkUserInfo:@[sourceId]];
    }
}


- (void)checkCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    NSString *senderId = [notification sender];
    if ([senderId isKindOfClass:[NSString class]])
    {
        [self checkUserInfo:@[senderId]];
    }
}
@end
