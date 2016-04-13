//
//  NIMCallbackManager.m
//  NIMLib
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMCallbackManager.h"
#import "NIMDispatch.h"
#import "bind.h"
#import "callback.h"
#import "NIMGlobalDefs.h"

@implementation NIMCallbackResult
- (instancetype)init
{
    if (self = [super init])
    {
        _error = NIMLocalError(NIMLocalErrorCodeInvalidParam);
    }
    return self;
}
@end

@interface NIMCallbackManager ()
@property (nonatomic,strong)    NSMutableDictionary *callbacks;
@property (nonatomic,strong)    NSRecursiveLock *lock;
@end

@implementation NIMCallbackManager

- (instancetype)init
{
    if (self = [super init])
    {
        _callbacks = [NSMutableDictionary dictionary];
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}


- (void)setCallback:(id<NIMCallback>)object
            forTask:(NSInteger)taskId
{
    [_lock lock];
    if (object)
    {
        if ([_callbacks objectForKey:@(taskId)] == nil)
        {
            [_callbacks setObject:object
                           forKey:@(taskId)];
        }
        else
        {
            NIMAssert();
        }
    }

    [_lock unlock];
}

- (id<NIMCallback>)callback:(NSInteger)taskId
{
    id<NIMCallback> callback = nil;
    [_lock lock];
    callback = [_callbacks objectForKey:@(taskId)];
    [_lock unlock];
    return callback;
}

- (void)removeCallback:(NSInteger)taskId
{
    [_lock lock];
    [_callbacks removeObjectForKey:@(taskId)];
    [_lock unlock];
}

@end


namespace nimbiz
{
    void    CallbackNIM(struct IAsynCallbackParam *result)
    {
        @autoreleasepool
        {
            if (result)
            {
                IAsynTaskCallbackParam *param = dynamic_cast<IAsynTaskCallbackParam *>(result);
                if (param)
                {
                    NSInteger taskId = param->task_id_;
                    id<NIMCallback> callback = [[NIMCallbackManager sharedManager] callback:taskId];
                    if (callback)
                    {
                        NIMCallbackResult *callbackResult = [[NIMCallbackResult alloc] init];
                        if ([callback respondsToSelector:@selector(convertParam:toResult:)])
                        {
                            [callback convertParam:result
                                          toResult:callbackResult];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if ([callback respondsToSelector:@selector(run:)])
                                {
                                    [callback run:callbackResult];
                                }
                            });
                        }
                        [[NIMCallbackManager sharedManager] removeCallback:taskId];
                    }
                }
            }
        }
    }
    
    IAsynCallback GetNIMCallback()
    {
        return nbase::Bind(&CallbackNIM);
    }
    
    
}

