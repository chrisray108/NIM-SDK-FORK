//
//  NIMDelegateCenter.h
//  NIMLib
//
//  Created by amao on 8/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLoginManagerProtocol.h"
#import "NIMChatManagerProtocol.h"
#import "NIMConversationManagerProtocol.h"
#import "NIMTeamManagerProtocol.h"
#import "NIMSystemNotificationManagerProtocol.h"
#import "NIMNetCallManagerProtocol.h"
#import "NIMRTSManagerProtocol.h"
#import "NIMUserManagerProtocol.h"
#import "NIMChatroomManagerProtocol.h"


typedef NS_ENUM(NSInteger, NIMDelegateType)
{
    NIMDelegateTypeLogin,
    NIMDelegateTypeChat,
    NIMDelegateTypeConversation,
    NIMDelegateTypeTeam,
    NIMDelegateTypeNotification,
    NIMDelegateTypeNetCall,
    NIMDelegateTypeRTS,
    NIMDelegateTypeUser,
    NIMDelegateTypeChatroom,
};


@interface NIMDelegateCenter : NSObject
+ (instancetype)sharedCenter;

- (void)addDelegate:(id)delegate
            forType:(NIMDelegateType)type;

- (void)removeDelegate:(id)delegate
               forType:(NIMDelegateType)type;

+ (id<NIMLoginManagerDelegate>)loginDelegate;
+ (id<NIMChatManagerDelegate>)chatDelegate;
+ (id<NIMConversationManagerDelegate>)conversationDelegate;
+ (id<NIMTeamManagerDelegate>)teamDelegate;
+ (id<NIMSystemNotificationManagerDelegate>)notificationDelegate;
+ (id<NIMNetCallManagerDelegate>)netCallDelegate;
+ (id<NIMRTSManagerDelegate>)rtsDelegate;
+ (id<NIMUserManagerDelegate>)userDelegate;
+ (id<NIMChatroomManagerDelegate>)chatroomDelegate;
@end
