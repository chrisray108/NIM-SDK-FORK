    //
//  NIMTeamNotificationContent.m
//  NIMLib
//
//  Created by amao on 7/23/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMTeamNotificationContent_Private.h"
#import "team_protocol.h"
#import "user_protocol.h"
#import "NIMSDKConfig_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NIMTeamManager.h"
#import "NIMTeamMember_Private.h"
#import "NIMCoreCenter.h"
#import "NIMProtocolUtil.h"

#pragma mark - 群通知
@implementation NIMTeamNotificationContent
- (BOOL)decode:(NSDictionary *)jsonBody
{
    BOOL decodeSuccess = NO;
    _operationType = -1;
    if ([jsonBody objectForKey:@"id"])
    {
        NIMLogApp(@"notify id %@",[jsonBody objectForKey:@"id"]);
        _operationType = [jsonBody nim_jsonInteger:@"id"];
        NSDictionary *dict = [jsonBody nim_jsonDict:@"data"];
        _groupInfo = [dict nim_jsonDict:@"tinfo"];
        _targetIDs = [dict nim_jsonStringArray:@"ids"];
        
        NSString *targetID = [dict nim_jsonString:@"id"];
        if ([_targetIDs count] == 0 && [targetID length])
        {
            _targetIDs = @[targetID];
        }
        
        _infos = [dict nim_jsonArray:@"uinfos"];
        [self parseAttachment];
        
        decodeSuccess = YES;
    }
    else
    {
        NIMLogErr(@"invalid team notification");
        NIMAssert();
    }
    return decodeSuccess;
}

- (NIMNotificationType)notificationType
{
    return NIMNotificationTypeTeam;
}


- (NSString*)sourceID{
    return self.messageObject.message.from;
}

- (void)saveDataAfterReceiving:(BOOL)online
{
    [self saveMemberInfos];
 
    //在线消息需要刷新本地群信息
    if(online)
    {
        [self onTeamChanged];
        [self onTeamMemberChanged];
    }

}

#pragma mark - 收到通知后操作
- (void)saveMemberInfos
{
    if([[NIMSDKConfig sharedConfig] hostUserInfos])
    {
        nimbiz::IUserService *service = (nimbiz::IUserService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_USER);
        if (service)
        {
            for (NSDictionary *dict in _infos)
            {
                if ([dict isKindOfClass:[NSDictionary class]])
                {
                    nimbiz::Property info = [NIMProtocolUtil dictToProperty:dict];
                    service->SaveUserInfoFromServer(info);
                }
            }
        }
    }
}

- (void)onTeamChanged
{
    nimbiz::UTF8String teamId = UTF8(self.messageObject.message.session.sessionId);
    nimbiz::Property info;
    if (_groupInfo)
    {
        info = [NIMProtocolUtil dictToProperty:_groupInfo];
    }
    info.put_string(nimbiz::NIMTeamTagID, teamId);
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        switch (self.operationType) {
            case NIMTeamOperationTypeKick:{
                if (self.targetContainsMe) {
                    info.put_int32(nimbiz::NIMTeamTagMemberValid, 0);
                }
            }
                break;
                
            case NIMTeamOperationTypeDismiss:{
                info.put_int32(nimbiz::NIMTeamTagValidFlag, 0);
                info.put_int32(nimbiz::NIMTeamTagMemberValid, 0);
            }
                break;
                
            case NIMTeamOperationTypeLeave:{
                if (self.sourceIsMe) {
                    info.put_int32(nimbiz::NIMTeamTagMemberValid, 0);
                }
            }
                break;
                
            case NIMTeamOperationTypeInvite:{
                if (self.targetContainsMe) {
                    info.put_int32(nimbiz::NIMTeamTagValidFlag, 1);
                    info.put_int32(nimbiz::NIMTeamTagMemberValid, 1);
                    _shouldRefreshTList = YES;
                }
            }
                break;
                
            case NIMTeamOperationTypeApplyPass:{
                if (self.targetContainsMe) {
                    info.put_int32(nimbiz::NIMTeamTagValidFlag, 1);
                    info.put_int32(nimbiz::NIMTeamTagMemberValid, 1);
                    _shouldRefreshTList = YES;
                }
                break;
            }
            case NIMTeamOperationTypeTransferOwner:{
                nimbiz::UTF8String owner = UTF8([_targetIDs firstObject]);
                if (owner.size())
                {
                    info.put_string(nimbiz::NIMTeamTagOwner, owner);
                }
            }
            case NIMTeamOperationTypeAcceptInvitation:
                if (self.sourceIsMe) {
                    info.put_int32(nimbiz::NIMTeamTagValidFlag, 1);
                    info.put_int32(nimbiz::NIMTeamTagMemberValid, 1);
                    _shouldRefreshTList = YES;
                }
                break;
            default:
                break;
        }
        
        service->SaveTeamInfoFromLocal(info);
    }
}

- (void)onTeamMemberChanged
{
    NSString *teamId = self.messageObject.message.session.sessionId;
    switch (self.operationType)
    {
        case NIMTeamOperationTypeInvite:
        case NIMTeamOperationTypeApplyPass:
            [self updateMembers:_targetIDs
                         inTeam:teamId
                           type:NIMTeamMemberTypeNormal];
            break;
        case NIMTeamOperationTypeKick:
            [self removeMembers:_targetIDs
                       fromTeam:teamId];
            break;
        case NIMTeamOperationTypeLeave:
            [self removeMembers:[self sourceID]
                       fromTeam:teamId];
            break;
        case NIMTeamOperationTypeTransferOwner:
            [self updateMembers:[self sourceID]
                         inTeam:teamId
                           type:NIMTeamMemberTypeNormal];
            [self updateMembers:_targetIDs
                         inTeam:teamId
                           type:NIMTeamMemberTypeOwner];
            break;
        case NIMTeamOperationTypeAddManager:
            [self updateMembers:_targetIDs
                         inTeam:teamId
                           type:NIMTeamMemberTypeManager];
            break;
        case NIMTeamOperationTypeRemoveManager:
            [self updateMembers:_targetIDs
                         inTeam:teamId
                           type:NIMTeamMemberTypeNormal];
            break;
        case NIMTeamOperationTypeAcceptInvitation:
            [self updateMembers:[self sourceID]
                         inTeam:teamId
                           type:NIMTeamMemberTypeNormal];
            
            break;
            
    }
}

#pragma mark - 群成员操作
- (void)removeMembers:(id)member
             fromTeam:(NSString *)teamId
{
    NSArray *users = nil;
    if ([member isKindOfClass:[NSString class]])
    {
        users = @[member];
    }
    else if ([member isKindOfClass:[NSArray class]])
    {
        users = member;
    }
    std::list<nimbiz::UTF8String> userIDs = [NIMProtocolUtil arrayToStringList:users];
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        service->RemoveTeamUsers(UTF8(teamId), userIDs);
    }
}

- (void)updateMembers:(id)member
               inTeam:(NSString *)teamId
                 type:(NIMTeamMemberType)type
{
    NSArray *users = nil;
    if ([member isKindOfClass:[NSString class]])
    {
        users = @[member];
    }
    else if ([member isKindOfClass:[NSArray class]])
    {
        users = member;
    }
    std::list<nimbiz::Property> infos;
    for (NSString *userID in users)
    {
        nimbiz::Property info;
        info.put_string(nimbiz::NIMTeamMemberTagAccountID, UTF8(userID));
        info.put_uint32(nimbiz::NIMTeamMemberTagType, (uint32_t)type);
        info.put_uint32(nimbiz::NIMTeamMemberTagValidFlag, 1);
        infos.push_back(info);
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        //通过群消息通知的群成员变化并不会再走CID_TEAM_NOTIFY_SYNC_TLIST通知。所以这里要抛回调
        service->SaveTeamUsers(UTF8(teamId), infos, true);
    }
}

#pragma mark - misc
- (BOOL)targetContainsMe{
    NSString *currentUserID = [[NIMCoreCenter sharedCenter] currentUserID];
    for (NSString *uid in self.targetIDs) {
        if ([uid isEqualToString:currentUserID] ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)sourceIsMe{
    NSString *currentUserID = [[NIMCoreCenter sharedCenter] currentUserID];
    return [self.sourceID isEqualToString:currentUserID];
}


- (void)parseAttachment
{
    if (_operationType == NIMTeamOperationTypeUpdate)
    {
        if (_groupInfo)
        {
            nimbiz::Property info = [NIMProtocolUtil dictToProperty:_groupInfo];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            static NSArray *keys = @[@(NIMTeamUpdateTagName),@(NIMTeamUpdateTagIntro),@(NIMTeamUpdateTagAnouncement),
                                     @(NIMTeamUpdateTagJoinMode),@(NIMTeamUpdateTagClientCustom),@(NIMTeamUpdateTagServerCustom)];
            
            for (NSNumber *key in keys)
            {
                uint32_t tag = (uint32_t)[key integerValue];
                if (info.has_tag(tag))
                {
                    dict[key] = NSUTF8(info.get_string(tag));
                }
            }
            NIMUpdateTeamInfoAttachment *attachment = [[NIMUpdateTeamInfoAttachment alloc] initWithValues:dict];
            _attachment = attachment;
        }
    }
}
@end


#pragma mark - 群通知附件
@implementation NIMUpdateTeamInfoAttachment

- (instancetype)initWithValues:(NSDictionary *)dict
{
    if (self = [super init]) {
        _values = dict;
    }
    return self;
}

@end
