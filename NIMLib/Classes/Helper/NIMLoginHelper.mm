//
//  NIMLoginHelper.m
//  NIMLib
//
//  Created by amao on 1/4/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMLoginHelper.h"
#import "NIMLoginOperation.h"
#import "auth_protocol.h"
#import "chatroom_protocol.h"
#import "NIMLoginManager.h"
#import "NIMSDK_Private.h"
#import "NIMSDKConfig_Private.h"
#import "ios_util.h"
#import "NIMChatroom_Private.h"
#import "NIMProtocolUtil.h"
#import "NIMNetworkConfig.h"

@implementation NIMLoginHelper

+ (nimbiz::Property)loginTags:(NIMLoginOperation *)operation
{
    NIMSDK *sdk = [NIMSDK sharedSDK];
    NIMSDKConfig *config = [NIMSDKConfig sharedConfig];
    
    nimbiz::Property tags;
    tags.put_string(nimbiz::NIMAuthTagAppAccount, UTF8(operation.account));
    tags.put_string(nimbiz::NIMAuthTagLoginToken, UTF8(operation.accountToken));
    tags.put_uint32(nimbiz::NIMAuthTagLoginMode, (int32_t)operation.loginMode);
    tags.put_uint32(nimbiz::NIMAuthTagClientType, nimbiz::NIMClientTypeIOS);
    tags.put_string(nimbiz::NIMAuthTagOS, UTF8([self getSystemDescription]));
    tags.put_uint32(nimbiz::NIMAuthTagSDKVersion, (uint32_t)[config sdkVersion]);
    tags.put_uint32(nimbiz::NIMAuthTagProtocolVersion, (uint32_t)[config protocolVersion]);
    tags.put_uint32(nimbiz::NIMAuthTagBackground, [self backgroundState]);
    tags.put_string(nimbiz::NIMAuthTagDeviceID, nimbiz::GetDeviceID());
    tags.put_string(nimbiz::NIMAuthTagAppKey, UTF8([sdk appKey]));
    tags.put_string(nimbiz::NIMAuthTagAppBundleID, UTF8([[NSBundle mainBundle] bundleIdentifier]));
    tags.put_string(nimbiz::NIMAuthTagClientSession, UTF8([sdk localSessionId]));
    tags.put_uint32(nimbiz::NIMAuthTagNetworkCode, [self networkCode]);
    
    NSString *token = [sdk apnsToken];
    NSString *cerName = [sdk apnsCerName];
    if ([token length] && [cerName length])
    {
        tags.put_string(nimbiz::NIMAuthTagPushToken, UTF8(token));
        tags.put_string(nimbiz::NIMAuthTagCerName, UTF8(cerName));
    }
    return tags;
}

+ (nimbiz::Property)chatroomTags:(NIMLoginOperation *)operation
            request:(NIMChatroomEnterRequest *)request
{
    NIMSDK *sdk = [NIMSDK sharedSDK];
    
    nimbiz::Property tags;
    tags.put_string(nimbiz::NIMChatroomLoginTagAppKey, UTF8([sdk appKey]));
    tags.put_string(nimbiz::NIMChatroomLoginTagAppAccount, UTF8(operation.account));
    tags.put_string(nimbiz::NIMChatroomLoginTagDeviceId, nimbiz::GetDeviceID());
    tags.put_string(nimbiz::NIMChatroomLoginTagIMConsid, [self imConnectionId]);
    tags.put_string(nimbiz::NIMChatroomLoginTagRoomId, UTF8(request.roomId));
    tags.put_string(nimbiz::NIMChatroomLoginTagNick, UTF8(request.roomNickname));
    tags.put_string(nimbiz::NIMChatroomLoginTagAvatar, UTF8(request.roomAvatar));
    tags.put_string(nimbiz::NIMChatroomLoginTagRoomExt, [NIMProtocolUtil stringByJsonDictionary:request.roomExt]);
    tags.put_string(nimbiz::NIMChatroomLoginTagNotifyExt, [NIMProtocolUtil stringByJsonDictionary:request.roomNotifyExt]);
    tags.put_string(nimbiz::NIMChatroomLoginTagClientSession, UTF8([sdk localSessionId]));
    
    return tags;
}

+ (BOOL)isNoretryCode:(NSInteger)code
{
    return code == nimbiz::NIMResUidPassError ||
           code == nimbiz::NIMResExist;
}

#pragma mark - LoginHelper misc
+ (NSString *)getSystemDescription
{
    return [NSString stringWithFormat:@"(%@) (%@) (%@) (%@)",
            [[UIDevice currentDevice] name],
            [[UIDevice currentDevice] model],
            [[UIDevice currentDevice] systemName],
            [[UIDevice currentDevice] systemVersion]];
}

+ (uint32_t)backgroundState
{
    return (uint32_t)([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground ? 1 : 0);
}

+ (nimbiz::UTF8String)imConnectionId
{
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    return core ? core->GetConId() : "";
}

+ (int32_t)networkCode
{
    int32_t code = -1;
    NIMNetworkType type = [[NIMNetworkConfig sharedConfig] currentNetworkType];
    switch (type) {
        case NIMNetworkType2G:
            code = 1;
            break;
        case NIMNetworkType3G:
            code = 2;
            break;
        case NIMNetworkType4G:
            code = 3;
            break;
        case NIMNetworkTypeWifi:
            code = 4;
            break;
        default:
            break;
    }
    return code;
}
@end
