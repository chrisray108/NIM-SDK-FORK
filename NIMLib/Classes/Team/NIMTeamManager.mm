//
//  NIMTeamManager.m
//  NIMLib
//
//  Created by amao on 2/28/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMTeamManager.h"
#import "NIMTeam_Private.h"
#import "team_protocol.h"
#import "NIMGlobalDefs.h"
#import "NIMProtocolUtil.h"
#import "NIMTeam_Private.h"
#import "NIMNotificationObject_Private.h"
#import "NIMLoginManager.h"
#import "NIMTeamManagerProtocol.h"
#import "NIMCoreCenter.h"
#import "NIMTeamMember_Private.h"
#import "NIMTeamCallback.h"
#import "NIMSDK.h"
#import "NIMDispatch.h"
#import "NIMDelegateCenter.h"
#import "NIMTeamMemberManager.h"
#import "NIMTeamCallback.h"
#import "NIMTeamManager_Private.h"
#import "NIMCreateTeamOptionValidator.h"
#import "NIMTeamInfoValidator.h"


@interface NIMTeamManager ()
@end

@implementation NIMTeamManager

- (instancetype)init
{
    if (self = [super init])
    {
        _callbacks = [[NIMTeamCallback alloc] init];
        _memberManager = [[NIMTeamMemberManager alloc] init];
    }
    return self;
}

#pragma mark - 对外接口
- (NSArray *)allMyTeams
{
    NSMutableArray *array = [NSMutableArray array];
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        std::list<nimbiz::Property> teams;
        service->GetTeams(teams);
        for (auto it = teams.begin(); it != teams.end(); it++)
        {
            NIMTeam *team = [[NIMTeam alloc] initWithProperty:*it];
            [array addObject:team];
        }
    }
    return array;
}


- (NIMTeam *)teamById:(NSString *)teamId
{
    NIMTeam *team = nil;
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        nimbiz::Property info;
        service->GetTeamById(UTF8(teamId), info);
        if (info.props.size())
        {
            team = [[NIMTeam alloc] initWithProperty:info];
        }
    }
    return team;
}

- (BOOL)isMyTeam:(NSString *)teamId{
    BOOL res = NO;
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        nimbiz::Property info;
        res = service->IsMyTeam(UTF8(teamId));
    }
    return res;
}

- (void)createTeam:(NIMCreateTeamOption *)option
             users:(NSArray *)users
        completion:(NIMTeamCreateHandler)block
{
    std::list<nimbiz::UTF8String> teamUsers = [NIMProtocolUtil arrayToStringList:users];

    if (![[NIMCreateTeamOptionValidator validator:option] isValid] ||
        teamUsers.size() == 0)
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        nimbiz::Property info;
        if ([option.name length])
        {
            info.put_string(nimbiz::NIMTeamTagName, UTF8(option.name));
        }
        
        info.put_uint32(nimbiz::NIMTeamTagType, (uint32_t)option.type);
        
        if (option.intro)
        {
            info.put_string(nimbiz::NIMTeamTagIntro, UTF8(option.intro));
        }
        if (option.announcement)
        {
            info.put_string(nimbiz::NIMTeamTagAnnouncement, UTF8(option.announcement));
        }
        if (option.clientCustomInfo)
        {
            info.put_string(nimbiz::NIMTeamTagClientCustom,UTF8(option.clientCustomInfo));
        }
        
        
        NIMTeamJoinMode mode = option.joinMode;
        if (option.type == NIMTeamTypeNormal)
        {
            mode = NIMTeamJoinModeNoAuth;
        }
        info.put_uint32(nimbiz::NIMTeamTagJoinMode, (uint32_t)mode);
        
        
        
        nimbiz::UTF8String postscript = UTF8(option.postscript);
        NSInteger taskID = (NSInteger)(service->Invoke_CreateTeam(info,postscript,teamUsers));
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (void)dismissTeam:(NSString*)teamId
         completion:(NIMTeamHandler)block{
    nimbiz::UTF8String utf8teamId = UTF8(teamId);
    if (utf8teamId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_DismissTeam(utf8teamId));
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (void)quitTeam:(NSString *)teamId
      completion:(NIMTeamHandler)block
{
    nimbiz::UTF8String utf8TeamId = UTF8(teamId);
    if (utf8TeamId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_TeamLeave(utf8TeamId));
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (void)addUsers:(NSArray  *)users
          toTeam:(NSString *)teamId
      postscript:(NSString *)postscript
      completion:(NIMTeamMemberHandler)block
{
    std::list<nimbiz::UTF8String> teamUsers = [NIMProtocolUtil arrayToStringList:users];
    nimbiz::UTF8String utf8Name = UTF8(teamId);
    nimbiz::UTF8String utf8Postscript = UTF8(postscript);
    
    if (utf8Name.empty() || teamUsers.size() == 0)
    {;
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_TeamInvite(utf8Name,utf8Postscript,teamUsers));
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (void)kickUsers:(NSArray *)users
         fromTeam:(NSString *)teamId
      completion:(NIMTeamHandler)block
{
    std::list<nimbiz::UTF8String> teamUsers = [NIMProtocolUtil arrayToStringList:users];
    nimbiz::UTF8String teamName = UTF8(teamId);
    if (teamName.empty() || teamUsers.size() == 0)
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_TeamKick(teamName, teamUsers));
        [_callbacks setBlock:block forTask:taskID];
    }

}

- (void)updateTeamName:(NSString*)teamName
                teamId:(NSString*)teamId
            completion:(NIMTeamHandler)block{
    
    [self updateTeamInfos:@{@(NIMTeamUpdateTagName) : teamName ? : [NSNull null]}
                   teamId:teamId
               completion:block];
}


- (void)updateTeamJoinMode:(NIMTeamJoinMode)joinMode
                    teamId:(NSString*)teamId
                completion:(NIMTeamHandler)block{
    if (joinMode > NIMTeamJoinModeRejectAll || joinMode < NIMTeamJoinModeNoAuth)
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    [self updateTeamInfos:@{@(NIMTeamUpdateTagJoinMode) : [NSString stringWithFormat:@"%zd",joinMode]}
                   teamId:teamId
               completion:block];
}

- (void)updateTeamIntro:(NSString*)intro
                 teamId:(NSString*)teamId
             completion:(NIMTeamHandler)block{
    
    [self updateTeamInfos:@{@(NIMTeamUpdateTagIntro) : intro ? : [NSNull null]}
                   teamId:teamId
               completion:block];
}

- (void)updateTeamAnnouncement:(NSString*)announcement
                        teamId:(NSString*)teamId
                    completion:(NIMTeamHandler)block{
    
    [self updateTeamInfos:@{@(NIMTeamUpdateTagAnouncement) : announcement ? : [NSNull null]}
                   teamId:teamId
               completion:block];
}

- (void)updateTeamCustomInfo:(NSString *)info
                      teamId:(NSString *)teamId
                  completion:(NIMTeamHandler)block
{
    [self updateTeamInfos:@{@(NIMTeamUpdateTagClientCustom) : info ? : [NSNull null]}
                   teamId:teamId
               completion:block];
}

- (void)updateTeamInfos:(NSDictionary *)values
                 teamId:(NSString *)teamId
             completion:(NIMTeamHandler)block
{
    BOOL valid = [teamId isKindOfClass:[NSString class]] &&
    [teamId length] &&
    [NIMTeamInfoValidator validator:values].isValid;
    if (!valid) {
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        nimbiz::Property property;
        property.put_string(nimbiz::NIMTeamTagID, UTF8(teamId));
        
        static NSArray *keys = @[@(NIMTeamUpdateTagName),@(NIMTeamUpdateTagIntro),@(NIMTeamUpdateTagAnouncement),
                                 @(NIMTeamUpdateTagJoinMode),@(NIMTeamUpdateTagClientCustom)];
        
        for (NSNumber *key in values.allKeys) {
            if ([keys containsObject:key]) {
                property.put_string((int32_t)[key integerValue], UTF8(values[key]));
            }
        }
        NSInteger taskID = (NSInteger)(service->Invoke_UpdateTeamInfo(property));
        [_callbacks setBlock:block forTask:taskID];
    }
    
}


- (void)applyToTeam:(NSString *)teamId
            message:(NSString *)message
         completion:(NIMTeamApplyHandler)block{
    nimbiz::UTF8String utf8TeamId  = UTF8(teamId);
    nimbiz::UTF8String utf8Message = UTF8(message);
    if (utf8TeamId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),NIMTeamApplyStatusInvalid);
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_TeamApply(utf8TeamId, utf8Message));
        [_callbacks setBlock:block forTask:taskID];
    }

}


- (void)passApplyToTeam:(NSString *)teamId
                 userId:(NSString *)userId
             completion:(NIMTeamApplyHandler)block{
    nimbiz::UTF8String utf8TeamId  = UTF8(teamId);
    nimbiz::UTF8String utf8UserId  = UTF8(userId);
    if (utf8TeamId.empty() || utf8UserId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),NIMTeamApplyStatusInvalid);
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_TeamApplyPass(utf8TeamId, utf8UserId));
        [_callbacks setBlock:block forTask:taskID];
    }
}


- (void)rejectApplyToTeam:(NSString *)teamId
                   userId:(NSString *)userId
             rejectReason:(NSString *)rejectReason
               completion:(NIMTeamHandler)block{
    nimbiz::UTF8String utf8TeamId  = UTF8(teamId);
    nimbiz::UTF8String utf8UserId  = UTF8(userId);
    nimbiz::UTF8String utf8RjectReason = UTF8(rejectReason);
    
    if (utf8TeamId.empty() || utf8UserId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_TeamApplyReject(utf8TeamId, utf8UserId,utf8RjectReason));
        [_callbacks setBlock:block forTask:taskID];
    }

}

- (void)updateUserNick:(NSString *)userId
               newNick:(NSString *)newNick
                inTeam:(NSString *)teamId
            completion:(NIMTeamHandler)block{
    nimbiz::UTF8String utf8TeamId  = UTF8(teamId);
    nimbiz::UTF8String utf8UserId  = UTF8(userId);
    nimbiz::UTF8String utf8NewNick = UTF8(newNick);
    
    if (utf8TeamId.empty() || utf8UserId.empty() || utf8NewNick.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = 0;
        nimbiz::Property tlist;
        tlist.put_string(nimbiz::NIMTeamMemberTagTID, utf8TeamId);
        tlist.put_string(nimbiz::NIMTeamMemberTagNick, utf8NewNick);
        if ([userId isEqualToString:[NIMCoreCenter sharedCenter].currentUserID]) {
            taskID = (NSInteger)(service->Invoke_UpdateMyTlist(tlist));
        }else{
            tlist.put_string(nimbiz::NIMTeamMemberTagAccountID, utf8UserId);
            taskID = (NSInteger)(service->Invoke_UpdateOtherTList(tlist));
        }
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (void)addManagersToTeam:(NSString *)teamId
                    users:(NSArray  *)users
               completion:(NIMTeamHandler)block{
    
    nimbiz::UTF8String utf8TeamId  = UTF8(teamId);
    std::list<nimbiz::UTF8String> teamUsers = [NIMProtocolUtil arrayToStringList:users];
    
    if (utf8TeamId.empty() || teamUsers.size() == 0)
    {
        if (block)
        {
             block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_AddManager(utf8TeamId, teamUsers));
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (void)removeManagersFromTeam:(NSString *)teamId
                         users:(NSArray  *)users
                    completion:(NIMTeamHandler)block{
    
    nimbiz::UTF8String utf8TeamId  = UTF8(teamId);
    std::list<nimbiz::UTF8String> teamUsers = [NIMProtocolUtil arrayToStringList:users];
    
    if (utf8TeamId.empty() || teamUsers.size() == 0)
    {
        if (block)
        {
             block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_RemoveManager(utf8TeamId, teamUsers));
        [_callbacks setBlock:block forTask:taskID];
    }
}


- (void)transferManagerWithTeam:(NSString *)teamId
                     newOwnerId:(NSString *)newOwnerId
                        isLeave:(BOOL)isLeave
                     completion:(NIMTeamHandler)block{
    
    nimbiz::UTF8String utf8TeamId      = UTF8(teamId);
    nimbiz::UTF8String utf8NewOwnerId  = UTF8(newOwnerId);

    if (utf8TeamId.empty() || utf8NewOwnerId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_TransferOwner(utf8TeamId, utf8NewOwnerId, isLeave));
        [_callbacks setBlock:block forTask:taskID];
    }

}


- (void)acceptInviteWithTeam:(NSString*)teamId
                   invitorId:(NSString*)invitorId
                  completion:(NIMTeamHandler)block{
    nimbiz::UTF8String utf8TeamId      = UTF8(teamId);
    nimbiz::UTF8String utf8InvitorId   = UTF8(invitorId);
    if (utf8TeamId.empty() || utf8InvitorId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_AcceptInvite(utf8TeamId, utf8InvitorId));
        [_callbacks setBlock:block forTask:taskID];
    }

}


- (void)rejectInviteWithTeam:(NSString*)teamId
                   invitorId:(NSString*)invitorId
                rejectReason:(NSString*)rejectReason
                  completion:(NIMTeamHandler)block{
    
    nimbiz::UTF8String utf8TeamId       = UTF8(teamId);
    nimbiz::UTF8String utf8InvitorId    = UTF8(invitorId);
    nimbiz::UTF8String utf8RejectReason = UTF8(rejectReason);
    if (utf8TeamId.empty() || utf8InvitorId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_RejectInvite(utf8TeamId, utf8InvitorId,utf8RejectReason));
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (void)updateNotifyState:(BOOL)notify
                   inTeam:(NSString *)teamId
               completion:(NIMTeamHandler)block
{
    nimbiz::UTF8String utf8TeamId       = UTF8(teamId);
    if (utf8TeamId.empty()) {
        if (block)
        {
             block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        uint32_t bits = service->GetTeamUserBits(utf8TeamId);
        bits = notify ? bits & ~nimbiz::NIMTListBitsCloseNotify : bits | nimbiz::NIMTListBitsCloseNotify;
        
        nimbiz::Property info;
        info.put_string(nimbiz::NIMTeamMemberTagTID, utf8TeamId);
        info.put_uint32(nimbiz::NIMTeamMemberTagBits, bits);
        
        NSInteger taskID = (NSInteger)(service->Invoke_UpdateMyTlist(info));
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (BOOL)notifyForNewMsg:(NSString *)teamId
{
    BOOL notify = YES;
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger bits = (NSInteger)service->GetTeamUserBits(UTF8(teamId));
        notify = (bits & nimbiz::NIMTListBitsCloseNotify) == 0;
    }
    return notify;

}



- (void)fetchTeamMembers:(NSString *)teamId
        alwaysFromServer:(BOOL)fromServer
              completion:(NIMTeamMemberHandler)block
{
    nimbiz::UTF8String utf8TeamId = UTF8(teamId);
    if (utf8TeamId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    
    NIMTeamMemberHandler handler = ^(NSError *error,NSArray *members)
    {
        if (error)
        {
            if (block)
            {
                block(error,members);
            }
        }
        else
        {
            [self requestMissedMemberInfos:teamId
                                completion:^(NSError *requestError) {
                                    if (block) {
                                        block(requestError,requestError ? nil : members);
                                    }
                                }];
        }
    };
    
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        if (service->IsTeamOutOfData(utf8TeamId) || fromServer)
        {
            nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
            if (service)
            {
                NSInteger taskID = (NSInteger)(service->Invoke_RefreshTeamMembers(utf8TeamId));
                [_callbacks setBlock:handler
                             forTask:taskID];
            }
        }
        else
        {
            std::list<nimbiz::Property> users;
            service->GetLocalTeamUsers(utf8TeamId, users);
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (auto it = users.begin(); it != users.end(); it++)
            {
                NIMTeamMember *member = [[NIMTeamMember alloc] initWithProperty:*it];
                [array addObject:member];
            }
            
            handler(nil,array);
        }
    }
}


- (void)fetchTeamInfo:(NSString *)teamId
           completion:(NIMTeamFetchInfoHandler)block
{
    nimbiz::UTF8String utf8TeamId = UTF8(teamId);
    if (utf8TeamId.empty())
    {
        if (block)
        {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        NSInteger taskID = (NSInteger)(service->Invoke_GetTeamInfo(utf8TeamId));
        [_callbacks setBlock:block forTask:taskID];
    }
}

- (NIMTeamMember *)teamMember:(NSString *)userId
                       inTeam:(NSString *)teamId
{
    NIMTeamMember *member = nil;
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        nimbiz::Property userInfo;
        nimbiz::Property teamInfo;
        service->GetTeamUser(UTF8(teamId), UTF8(userId), userInfo);
        service->GetTeamById(UTF8(teamId), teamInfo);
        if (userInfo.props.size() &&
            userInfo.get_uint32(nimbiz::NIMTeamMemberTagValidFlag) != 0 &&
            teamInfo.get_uint32(nimbiz::NIMTeamTagValidFlag) != 0)
        {
            member = [[NIMTeamMember alloc] initWithProperty:userInfo];
        }
    }
    return member;
}




#pragma mark - 回调
- (void)onTeamTaskCallback:(nimbiz::CBTeamParam *)param
{
    [_callbacks raiseCallabck:param];
}

- (void)onTeamTlistChangedCallback:(NSString *)teamId
{
    NIMTeam *team = [self teamById:teamId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NIMDelegateCenter teamDelegate] onTeamMemberChanged:team];
    });
}

- (void)onTeamInfoChanged:(NSString *)teamId
                     type:(NSInteger)type
{
    NIMTeam *team = [self teamById:teamId];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type) {
            case nimbiz::NIMTeamChangedAdd:
                [[NIMDelegateCenter teamDelegate] onTeamAdded:team];
                break;
            case nimbiz::NIMTeamChangedUpdate:
                [[NIMDelegateCenter teamDelegate] onTeamUpdated:team];
                break;
            case nimbiz::NIMTeamChangedRemove:
                [[NIMDelegateCenter teamDelegate] onTeamRemoved:team];
                break;
            default:
                break;
        }
    });
}

#pragma mark - 群消息通知
- (void)onGetNotification:(NIMTeamNotificationContent *)aNotification
                  forTeam:(NSString *)teamId
{
    NIMTeamOperationType type = aNotification.operationType;
    NSString *currentAccount = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    BOOL isSource = [aNotification.sourceID isEqualToString:currentAccount];
    BOOL isTarget = [aNotification.targetIDs containsObject:currentAccount];
    NIMTeam *team = [self teamById:teamId];
    switch (type) {
        case NIMTeamOperationTypeInvite:
            if (isSource || isTarget)
            {
                [[NIMDelegateCenter teamDelegate] onTeamAdded:team];
            }
            break;
        case NIMTeamOperationTypeKick:
            {
                if(isTarget)
                {
                    [[NIMDelegateCenter teamDelegate] onTeamRemoved:team];
                }
            }
            break;
        case NIMTeamOperationTypeLeave:
            {
                if(isSource)
                {
                    [[NIMDelegateCenter teamDelegate] onTeamRemoved:team];
                }
            }
            break;
        case NIMTeamOperationTypeUpdate:
            {
                [[NIMDelegateCenter teamDelegate] onTeamUpdated:team];
            }
            break;
        case NIMTeamOperationTypeDismiss:
            {
                [[NIMDelegateCenter teamDelegate] onTeamRemoved:team];
            }
            break;
        case NIMTeamOperationTypeApplyPass:
        case NIMTeamOperationTypeAcceptInvitation:
        case NIMTeamOperationTypeAddManager:
        case NIMTeamOperationTypeTransferOwner:
        case NIMTeamOperationTypeRemoveManager:
            break;
        default:
            break;
    }
}



@end


namespace nimbiz
{
#pragma mark - Callback
void    CallbackTeamAction(struct IAsynCallbackParam *actionParam)
{
    @autoreleasepool
    {
        CBTeamParam *param = (CBTeamParam *)actionParam;
        [[NIMTeamManager sharedManager] onTeamTaskCallback:param];
    }
    
}


void    CallbackTlistChanged(struct IAsynCallbackParam *tlsitChangedparam)
{
    @autoreleasepool
    {
        CBTlistChangedParam *param = (CBTlistChangedParam *)tlsitChangedparam;
        nimbiz::UTF8String tid = param->tid_;
        [[NIMTeamManager sharedManager] onTeamTlistChangedCallback:NSUTF8(tid)];
    }
}

void    CallbackTInfoChanged(struct IAsynCallbackParam *tinfoParam)
{
    @autoreleasepool
    {
        CBTInfoChangedParam *param = (CBTInfoChangedParam *)tinfoParam;
        nimbiz::UTF8String tid = param->tid_;
        NSInteger type = (NSInteger)param->type_;
        [[NIMTeamManager sharedManager] onTeamInfoChanged:NSUTF8(tid)
                                                     type:type];
    }
}
}
