//
//  NIMChatroomStateEmitter.m
//  NIMLib
//
//  Created by amao on 3/11/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMChatroomStateEmitter.h"
#import "NIMDelegateCenter.h"
#import "NIMChatroomManagerProtocol.h"
#import "NIMLoginHelper.h"

@interface NIMChatroomStateEmitter ()
@property (nonatomic,copy)      NSString    *roomId;
@property (nonatomic,assign)    NIMChatroomConnectionState state;
@end


@implementation NIMChatroomStateEmitter
+ (instancetype)emitterByRoomId:(NSString *)roomId
{
    NIMChatroomStateEmitter *instance = [[NIMChatroomStateEmitter alloc] init];
    instance.roomId = roomId;
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _state = -1;
    }
    return self;
}

- (void)commit:(NIMChatroomState)state
         error:(NSError *)error
{
    if (state == NIMChatroomStateInit)
    {
        return;
    }
    
    NIMChatroomConnectionState cachedState = _state;
    switch(state)
    {
        case NIMChatroomStateConnecting:
        case NIMChatroomStateConnected:
        case NIMChatroomStateLogining:
            _state = NIMChatroomConnectionStateEntering;
            break;
        case NIMChatroomStateConnectFailed:
            _state = NIMChatroomConnectionStateEnterFailed;
            break;
        case NIMChatroomStateLoginFailed:
        {
            NSInteger code = [error code];
            _state = [NIMLoginHelper isNoretryCode:code] ?
            NIMChatroomConnectionStateFatalError : NIMChatroomConnectionStateEnterFailed;
        }
            break;
        case NIMChatroomStateLogined:
            _state = NIMChatroomConnectionStateEnterOK;
            break;
        case NIMChatroomStateDisconnected:
            _state = NIMChatroomConnectionStateLoseConnection;
            break;
        default:
            NIMAssert()
            break;
    }
    if (cachedState != _state)
    {
        NIMChatroomConnectionState callbackState = _state;
        
        //这个地方每次都在下个runloop发起，这样使得上层不会在一个Runloop里面收到好几个不一样的回调
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMDelegateCenter chatroomDelegate] chatroom:_roomId
                                    connectionStateChanged:callbackState];
        });
    }

    
    
}
@end
