//
//  NIMChatroomLoginData.m
//  NIMLib
//
//  Created by amao on 12/11/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroomLoginOperation.h"
#import "NIMUtil.h"
#import "NIMChatroom_Private.h"

@interface NIMChatroomLoginOperation ()
@property (nonatomic,strong)    NIMChatroomToken    *chatroomToken;
@end

@implementation NIMChatroomLoginOperation

+ (instancetype)operationByRequest:(NIMChatroomEnterRequest *)request
                             token:(NIMChatroomToken *)token
{
    NIMChatroomLoginOperation *instance = [[NIMChatroomLoginOperation alloc] init];
    instance.chatroomToken = token;
    instance.request = request;
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _linkId         = [NIMUtil uuid];
        _mode      = NIMLoginModeManual;
    }
    return self;
}

- (void)reportHostError:(BOOL)fatal
{
    [_chatroomToken reportHostError:fatal];
}


- (NIMChatroomAddress *)address
{
    return [_chatroomToken address];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n{\nroom_id %@\nlink_id %@\nlogined by user %@\n%@\n}\n",
            _request.roomId,_linkId,_mode == NIMLoginModeAuto ? @"auto" : @"manual",_chatroomToken];
}

- (NSString *)roomId
{
    return _request.roomId;
}
@end
