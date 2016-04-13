//
//  NIMDBOperation.h
//  NIMLib
//
//  Created by chris on 15/2/4.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_NIMDispatch_h
#define NIMLib_NIMDispatch_h
#import "NIMDatabase.h"


#define NIM_INLINE static inline



#pragma mark - IO 线程
//公用的IO读写同步线程
static const void * const NIMDispathIOQueueSpecificKey = &NIMDispathIOQueueSpecificKey;
NIM_INLINE dispatch_queue_t NIMDispathIOQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.netease.nim.io", 0);
        dispatch_queue_set_specific(queue, NIMDispathIOQueueSpecificKey, (void *)NIMDispathIOQueueSpecificKey, NULL);
    });
    return queue;
}


NIM_INLINE void nim_io_async(dispatch_block_t block)
{
    dispatch_async(NIMDispathIOQueue(),block);
}


NIM_INLINE void nim_io_sync_safe(dispatch_block_t block)
{
    if (dispatch_get_specific(NIMDispathIOQueueSpecificKey))
    {
        block();
    }
    else
    {
        dispatch_sync(NIMDispathIOQueue(),block);
    }
}

NIM_INLINE void nim_io_trans_async(NIMDatabase *db,dispatch_block_t block)
{
    dispatch_async(NIMDispathIOQueue(), ^() {
        [db beginTransaction];
        block();
        [db commit];
    });
}

NIM_INLINE void nim_io_trans_sync(NIMDatabase *db,dispatch_block_t block)
{
    dispatch_sync(NIMDispathIOQueue(), ^() {
        [db beginTransaction];
        block();
        [db commit];
    });
}


#pragma mark - 任务线程
static const void * const NIMGetTaskQueuepecificKey = &NIMGetTaskQueuepecificKey;
NIM_INLINE dispatch_queue_t NIMGetTaskQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.netease.nim.task", 0);
        dispatch_queue_set_specific(queue, NIMGetTaskQueuepecificKey, (void *)NIMGetTaskQueuepecificKey, NULL);
    });
    return queue;
}


NIM_INLINE void nim_task_sync_safe(dispatch_block_t block)
{
    if (dispatch_get_specific(NIMGetTaskQueuepecificKey))
    {
        block();
    }
    else
    {
        dispatch_sync(NIMGetTaskQueue(),block);
    }
}



#pragma mark - 主线程
NIM_INLINE void nim_main_sync_safe(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

NIM_INLINE void nim_main_async_safe(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


#pragma mark - DEMO主线程断言
NIM_INLINE void NIMMTAssert(){
    if (![NSThread isMainThread])
    {
        static BOOL isDemoApp = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
            isDemoApp = [bundleID isEqualToString:@"com.netease.NIMDemo"] ||
            [bundleID isEqualToString:@"com.netease.NIM.demo"];
        });
        if (isDemoApp)
        {
            assert(0);
        }
    }
}

#endif
