//
//  NIMChatroomMsgRecvHandler.m
//  NIMLib
//
//  Created by amao on 12/16/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroomMsgRecvHandler.h"
#import "NIMDelegateCenter.h"
#import "NIMSDKConfig_Private.h"
#import "NIMDispatch.h"

#define NIMMinClearMessageIdsCount          (500)
#define NIMMinFireNotificationDuration      (0.3)



@interface NIMChatroomMsgRecvHandler ()
@property (nonatomic,strong)    NSMutableDictionary *messageIds;
@property (nonatomic,strong)    NSMutableArray      *messageIdsSet;
@property (nonatomic,strong)    NSMutableArray      *cachedMessages;
@property (nonatomic,assign)    CFAbsoluteTime      lastFiredTime;
@end


@implementation NIMChatroomMsgRecvHandler
- (instancetype)init
{
    if (self = [super init])
    {
        _messageIds = [[NSMutableDictionary alloc] init];
        _messageIdsSet = [[NSMutableArray alloc] init];
        _cachedMessages = [[NSMutableArray array] init];
    }
    return self;
}

- (void)dealloc
{
    nim_task_sync_safe(^{
        _messageIds = nil;
        _messageIdsSet = nil;
        _cachedMessages = nil;
    });
}

- (void)onRecvMsg:(NIMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(NIMGetTaskQueue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf feedMessage:message];
    });
}

- (void)feedMessage:(NIMMessage *)message
{
    NSString *messageId = [message messageId];
    if (messageId && [_messageIds objectForKey:messageId] == nil )
    {
        _messageIds[messageId] = [NSNull null];
        [_messageIdsSet addObject:messageId];
        [_cachedMessages addObject:message];
        
        
        if ([_messageIdsSet count] > NIMMinClearMessageIdsCount)
        {
            NIMLogApp(@"clear chatroom message id cache size %zd",[_messageIdsSet count]);
            
            NSRange range = NSMakeRange(0, NIMMinClearMessageIdsCount / 2);
            NSArray *oldIds = [_messageIdsSet subarrayWithRange:range];
            [_messageIdsSet removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
            [_messageIds removeObjectsForKeys:oldIds];
        }
        
        //只有第一条消息才发起通知
        if ([_cachedMessages count] == 1)
        {
            if (CFAbsoluteTimeGetCurrent() - _lastFiredTime > NIMMinFireNotificationDuration)
            {
                [self notifyUI];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NIMMinFireNotificationDuration * NSEC_PER_SEC)), NIMGetTaskQueue(), ^{
                    [self notifyUI];
                });
            }
        }
    }
}

- (void)notifyUI
{
    _lastFiredTime = CFAbsoluteTimeGetCurrent();
    NSArray *messages = [_cachedMessages copy];
    [_cachedMessages removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NIMDelegateCenter chatDelegate] onRecvMessages:messages];
    });
}


@end
