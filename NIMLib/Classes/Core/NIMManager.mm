//
//  NIMManager.m
//  NIM
//
//  Created by amao on 11/13/13.
//  Copyright (c) 2013 Netease. All rights reserved.
//

#import "NIMManager.h"
#import "yixin_core.h"


#pragma mark - NIMManagerCenterImp
@interface CoreImpl : NSObject
@property (nonatomic,strong)    NSMutableDictionary     *managers;
@end


@implementation CoreImpl

- (id)init
{
    if (self = [super init])
    {
        _managers = [[NSMutableDictionary alloc]init];
    }
    return self;
}



- (instancetype)managerByClass:(Class)managerClass
{
    NSString *className = NSStringFromClass(managerClass);
    id manager = [_managers objectForKey:className];
    if (!manager)
    {
        manager = [[managerClass alloc]init];
        [_managers setObject:manager forKey:className];
    }
    return manager;
}

- (void)callManagerSelector:(SEL)selecotr
{
    NSArray *array = [_managers allValues];
    for (id obj in array)
    {
        if ([obj respondsToSelector:selecotr])
        {
            NIMSuppressPerformSelectorLeakWarning([obj performSelector:selecotr]);
        }
    }
}

@end

#pragma mark - NIMManagerCenter()
@interface NIMManagerCenter ()
@property (nonatomic,strong)    NSRecursiveLock      *coreLock;
@property (nonatomic,strong)    CoreImpl             *core;;
@end

#pragma mark - NIMManager
@implementation NIMManager
+ (instancetype)sharedManager
{
    return [[NIMManagerCenter sharedCenter] managerByClass:[self class]];
}

- (void)start
{
    NIMLogApp(@"NIMManager %@ Started",self);
}
@end




#pragma mark - NIMManagerCneter
@implementation NIMManagerCenter

+ (id)sharedCenter
{
    static NIMManagerCenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMManagerCenter alloc]init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        _coreLock = [[NSRecursiveLock alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callReceiveMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callAppWillTerminate)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
  
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 创建/销毁/获取manager
- (void)createCenter
{
    [_coreLock lock];
    if (_core == nil)
    {
        self.core = [[CoreImpl alloc] init];
    }
    [_coreLock unlock];
}

- (void)destroyCenter
{
    [_coreLock lock];
    self.core = nil;
    [_coreLock unlock];
}


- (instancetype)managerByClass:(Class)managerClass
{
    id instance = nil;
    [_coreLock lock];
    instance = [_core managerByClass:managerClass];
    [_coreLock unlock];
    
    if (instance == nil)
    {
        NSLog(@"You should call login api before calling any im related api");
        NIMLogErr(@"get manager failed %@",managerClass);
    }
    
    return instance;
}

#pragma mark - Call Functions
- (void)callReceiveMemoryWarning
{
    [self callSelector:@selector(onReceiveMemoryWarning)];
}


- (void)callEnterBackground
{
    [self saveDocument];
    [self callSelector:@selector(onEnterBackground)];
}

- (void)callEnterForeground
{
    [self callSelector:@selector(onEnterForeground)];
}

- (void)callAppWillTerminate
{
    [self saveDocument];
    [self callSelector:@selector(onAppWillTerminate)];
    [self destoryCore];
}

- (void)callSelector:(SEL)selector
{
    NIMLogApp(@"manager %s begin",selector);
    [_coreLock lock];
    [_core callManagerSelector:selector];
    [_coreLock unlock];
    NIMLogApp(@"manager %s end",selector);
}

#pragma mark - Core
- (void)saveDocument
{
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    if (core)
    {
        core->FlushDocument();
    }
}

- (void)destoryCore
{
    nimbiz::IYixinCore_Close(0);
}

@end