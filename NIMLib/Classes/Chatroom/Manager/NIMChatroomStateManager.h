//
//  NIMChatroomStateManager.h
//  NIMLib
//
//  Created by amao on 12/11/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatroomLoginOperation.h"
#import "NIMChatroomManagerProtocol.h"

typedef enum : NSUInteger {
    NIMChatroomStateInit,
    NIMChatroomStateConnecting,
    NIMChatroomStateConnected,
    NIMChatroomStateConnectFailed,
    NIMChatroomStateLogining,
    NIMChatroomStateLogined,
    NIMChatroomStateLoginFailed,
    NIMChatroomStateDisconnected,
} NIMChatroomState;


@interface NIMChatroomStateManager : NSObject
@property (nonatomic,assign)    NIMChatroomState    state;
@property (nonatomic,assign)    NSInteger           exitTaskId;
@property (nonatomic,assign)    NSInteger           closeTaskId;
@property (nonatomic,copy)      NIMChatroomHandler  exitHandler;
@property (nonatomic,copy)      NIMChatroomHandler  closeHandler;
@property (nonatomic,strong)    NIMChatroom  *roomInfo;
@property (nonatomic,strong)    NIMChatroomMember *me;

- (instancetype)init;
- (void)login:(NIMChatroomLoginOperation *)operation;


- (void)chatroomConnect:(NSString *)linkId
                connect:(BOOL)connected;

- (void)chatroomDisconnected:(NSString *)linkId;

- (void)chatroomEnter:(NSInteger)taskId
                error:(NSError *)error
             roomInfo:(NIMChatroom *)room
               meInfo:(NIMChatroomMember *)me;

- (void)chatroomHostError:(BOOL)force;
@end


