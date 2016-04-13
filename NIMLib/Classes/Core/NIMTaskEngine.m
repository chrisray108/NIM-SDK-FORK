//
//  NIMTaskEngine.m
//  NIMLib
//
//  Created by amao on 1/30/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMTaskEngine.h"

@interface NIMTaskEngine ()
{
    BOOL _isCleanTask;
    NSOperationQueue *_taskQueue;
}
@end

@implementation NIMTaskEngine
+ (instancetype)sharedEngine
{
    static NIMTaskEngine *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMTaskEngine alloc]init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _taskQueue = [[NSOperationQueue alloc]init];
        _taskQueue.name = @"nim_task_queue";
        [_taskQueue setMaxConcurrentOperationCount:1];
        

    }
    return self;
}


- (void)runTask:(EngineTask)task
{
    if (_isCleanTask)
    {
        NIMLogWar(@"Task Not Executed Beacuse Of In Cleaning");
        return;
    }
#if DEBUG
    NSArray *array =  [NSThread callStackSymbols];
    [_taskQueue addOperationWithBlock:^{
        NSDate *begin = [NSDate date];
        if (task)
        {
            task();
        }
        NSTimeInterval timeCost = [[NSDate date] timeIntervalSinceDate:begin];
        if (timeCost >= 2.0)
        {
            //如果进入到这个流程,需要考虑当前task是否能够放在taskQueue里面
            NIMLogWar(@"Task‘s Time Cost Is %lf \n ....................\n%@",timeCost,array);
        }
    }];
#else
    [_taskQueue addOperationWithBlock:^{
        if (task)
        {
            task();
        }
    }];
#endif
}


@end
