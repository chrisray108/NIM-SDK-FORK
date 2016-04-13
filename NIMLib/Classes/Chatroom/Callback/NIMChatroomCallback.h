//
//  NIMChatroomCallback.h
//  NIMLib
//
//  Created by amao on 12/16/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

namespace nimbiz
{
    struct IAsynCallbackParam;
    void CallbackChatroomSendMsg(struct IAsynCallbackParam *msgParam);
    void CallbackChatroomRecvMsg(struct IAsynCallbackParam *msgParam);
    void CallbackChatroomBeKicked(struct IAsynCallbackParam *kickedParam);
}