//
//  NIMFetchMsgCallback.h
//  NIMLib
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMCallbackManager.h"
#import "NIMConversationManagerProtocol.h"

@interface NIMFetchMsgCallback : NSObject<NIMCallback>
@property (nonatomic,strong)    NIMSession *session;
@property (nonatomic,copy)      NIMFetchMessageHistoryBlock fetchBlock;
@property (nonatomic,assign)    BOOL sync;
@end
