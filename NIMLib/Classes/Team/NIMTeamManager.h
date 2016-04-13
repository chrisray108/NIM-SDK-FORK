//
//  NIMTeamManager.h
//  NIMLib
//
//  Created by amao on 2/28/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMManager.h"
#import "NIMTeamManagerProtocol.h"

@class NIMTeamNotificationContent;
@class NIMTeamCallback;
@class NIMTeamMemberManager;

@interface NIMTeamManager : NIMManager
{
    NIMTeamMemberManager        *_memberManager;
    NIMTeamCallback             *_callbacks;
}

#pragma mark - 公有接口

- (NSArray *)allMyTeams;

- (NIMTeam *)teamById:(NSString *)teamId;

- (BOOL)isMyTeam:(NSString *)teamId;

- (void)createTeam:(NIMCreateTeamOption *)option
             users:(NSArray *)users
        completion:(NIMTeamCreateHandler)block;

- (void)dismissTeam:(NSString*)teamId
         completion:(NIMTeamHandler)block;

- (void)quitTeam:(NSString *)teamId
      completion:(NIMTeamHandler)block;

- (void)addUsers:(NSArray  *)users
          toTeam:(NSString *)teamId
      postscript:(NSString *)postscript
      completion:(NIMTeamMemberHandler)block;

- (void)kickUsers:(NSArray *)users
         fromTeam:(NSString *)teamId
       completion:(NIMTeamHandler)block;

- (void)updateTeamName:(NSString *)teamName
                teamId:(NSString *)teamId
            completion:(NIMTeamHandler)block;

- (void)updateTeamJoinMode:(NIMTeamJoinMode)joinMode
                    teamId:(NSString *)teamId
                completion:(NIMTeamHandler)block;

- (void)updateTeamIntro:(NSString *)intro
                 teamId:(NSString *)teamId
             completion:(NIMTeamHandler)block;

- (void)updateTeamAnnouncement:(NSString *)announcement
                        teamId:(NSString *)teamId
                    completion:(NIMTeamHandler)block;

- (void)updateTeamCustomInfo:(NSString *)info
                      teamId:(NSString *)teamId
                  completion:(NIMTeamHandler)block;

- (void)updateTeamInfos:(NSDictionary *)values
                 teamId:(NSString *)teamId
             completion:(NIMTeamHandler)block;

- (void)applyToTeam:(NSString *)teamId
            message:(NSString *)message
         completion:(NIMTeamApplyHandler)block;

- (void)passApplyToTeam:(NSString *)teamId
                 userId:(NSString *)userId
             completion:(NIMTeamApplyHandler)block;

- (void)rejectApplyToTeam:(NSString *)teamId
                   userId:(NSString *)userId
             rejectReason:(NSString*)rejectReason
               completion:(NIMTeamHandler)block;

- (void)updateUserNick:(NSString *)userId
               newNick:(NSString *)newNick
                inTeam:(NSString *)teamId
            completion:(NIMTeamHandler)block;

- (void)addManagersToTeam:(NSString *)teamId
                    users:(NSArray  *)users
               completion:(NIMTeamHandler)block;

- (void)removeManagersFromTeam:(NSString *)teamId
                         users:(NSArray  *)users
                    completion:(NIMTeamHandler)block;

- (void)transferManagerWithTeam:(NSString *)teamId
                     newOwnerId:(NSString *)newOwnerId
                        isLeave:(BOOL)isLeave
                     completion:(NIMTeamHandler)block;

- (void)acceptInviteWithTeam:(NSString*)teamId
                   invitorId:(NSString*)invitorId
                  completion:(NIMTeamHandler)block;

- (void)rejectInviteWithTeam:(NSString*)teamId
                   invitorId:(NSString*)invitorId
                rejectReason:(NSString*)rejectReason
                  completion:(NIMTeamHandler)block;

- (void)updateNotifyState:(BOOL)notify
                   inTeam:(NSString *)teamId
               completion:(NIMTeamHandler)block;

- (BOOL)notifyForNewMsg:(NSString *)teamId;

- (void)fetchTeamMembers:(NSString *)teamId
        alwaysFromServer:(BOOL)fromServer
              completion:(NIMTeamMemberHandler)block;

- (void)fetchTeamInfo:(NSString *)teamId
           completion:(NIMTeamFetchInfoHandler)block;

- (NIMTeamMember *)teamMember:(NSString *)userId
                       inTeam:(NSString *)teamId;

#pragma mark - 私有接口
- (void)onGetNotification:(NIMTeamNotificationContent *)aNotification
                  forTeam:(NSString *)teamId;


@end

namespace nimbiz
{
    struct IAsynCallbackParam;
    void    CallbackTeamAction(struct IAsynCallbackParam *actionParam);         //群操作
    void    CallbackTlistChanged(struct IAsynCallbackParam *tlistParam);        //群成员变化
    void    CallbackTInfoChanged(struct IAsynCallbackParam *tinfoParam);        //群信息变化
}



