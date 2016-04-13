//
//  NIMAppTokenManager.m
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMAppTokenManager.h"
#import "user_protocol.h"
#import "NIMConversationManager.h"
#import "NIMApnsManagerProtocol.h"
#import "NIMDelegateCenter.h"

@implementation NIMAppTokenManager

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sendToken
{
    NSString *apnsToken = [[NIMAppTokenStore store] apnsToken];
    if ([apnsToken length] && [self.apnsCerName length])
    {
        nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
        if (service)
        {
            service->Invoke_UpdateToken();
            NIMLogApp(@"send apns token and cername %@ %@",apnsToken,self.apnsCerName);
        }
    }
}

- (void)sendBadge:(BOOL)background
{
    uint32_t badge = 0;
    if (_badgeHandler)
    {
        badge = (uint32_t)_badgeHandler();
    }
    else
    {
        badge =(uint32_t)[[NIMConversationManager sharedManager] allUnreadCount];
    }

    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service)
    {
        service->Invoke_UpdateAppInfo(background, badge);
    }

}


- (void)didEnterBackground:(NSNotification *)aNotification
{
    [self sendBadge:YES];
}

- (void)willEnterForeground:(NSNotification *)aNotification
{
    [self sendBadge:NO];
}

@end


@implementation NIMAppTokenStore

+ (instancetype)store
{
    static NIMAppTokenStore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMAppTokenStore alloc] init];
    });
    return instance;
}

@end
