//
//  NIMDelegateCenter.m
//  NIMLib
//
//  Created by amao on 8/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMDelegateCenter.h"
#import "NIMMulticastDelegate.h"
#import "NIMDispatch.h"




@interface NIMDelegateCenter ()
@property (nonatomic,strong)    NSDictionary *delegates;
@end

@implementation NIMDelegateCenter
+ (instancetype)sharedCenter
{
    static NIMDelegateCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMDelegateCenter alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _delegates = @{@(NIMDelegateTypeLogin)          : [[NIMMulticastDelegate alloc] init],
                       @(NIMDelegateTypeChat)           : [[NIMMulticastDelegate alloc] init],
                       @(NIMDelegateTypeConversation)   : [[NIMMulticastDelegate alloc] init],
                       @(NIMDelegateTypeTeam)           : [[NIMMulticastDelegate alloc] init],
                       @(NIMDelegateTypeNotification)   : [[NIMMulticastDelegate alloc] init],
                       @(NIMDelegateTypeNetCall)        : [[NIMMulticastDelegate alloc] init],
                       @(NIMDelegateTypeRTS)            : [[NIMMulticastDelegate alloc] init],
                       @(NIMDelegateTypeUser)           : [[NIMMulticastDelegate alloc] init],
                       @(NIMDelegateTypeChatroom)       : [[NIMMulticastDelegate alloc] init],
                       };
    }
    return self;
}

- (void)addDelegate:(id)delegate
            forType:(NIMDelegateType)type
{
    nim_main_sync_safe(^{
        [_delegates[@(type)] addDelegate:delegate];
    });
}

- (void)removeDelegate:(id)delegate
               forType:(NIMDelegateType)type
{
    nim_main_sync_safe(^{
        [_delegates[@(type)] removeDelegate:delegate];
    });
}

- (id)delegateForType:(NIMDelegateType)type
{
    NIMMTAssert();
    return _delegates[@(type)];
}


#pragma mark - 读取接口
+ (id<NIMLoginManagerDelegate>)loginDelegate
{
    return (id<NIMLoginManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeLogin]);
}

+ (id<NIMChatManagerDelegate>)chatDelegate
{
    return (id<NIMChatManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeChat]);
}

+ (id<NIMConversationManagerDelegate>)conversationDelegate
{
    return (id<NIMConversationManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeConversation]);
}

+ (id<NIMTeamManagerDelegate>)teamDelegate
{
    return (id<NIMTeamManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeTeam]);
}


+ (id<NIMSystemNotificationManagerDelegate>)notificationDelegate
{
    return (id<NIMSystemNotificationManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeNotification]);
}


+ (id<NIMNetCallManagerDelegate>)netCallDelegate
{
    return (id<NIMNetCallManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeNetCall]);
}


+ (id<NIMRTSManagerDelegate>)rtsDelegate
{
    return (id<NIMRTSManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeRTS]);
}

+ (id<NIMUserManagerDelegate>)userDelegate
{
    return (id<NIMUserManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeUser]);
}

+ (id<NIMChatroomManagerDelegate>)chatroomDelegate
{
    return (id<NIMChatroomManagerDelegate>)([[NIMDelegateCenter sharedCenter] delegateForType:NIMDelegateTypeChatroom]);
}
@end
