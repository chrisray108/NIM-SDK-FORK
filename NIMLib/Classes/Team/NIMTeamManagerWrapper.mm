//
//  NIMTeamManagerWrapper.m
//  NIMLib
//
//  Created by chris on 15/8/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMTeamManagerWrapper.h"
#import "NIMTeamManager.h"
#import "NIMMacros.h"
#import "NIMGlobalDefs.h"
#import "NIMDelegateCenter.h"
#import "NIMDispatch.h"

@implementation NIMTeamManagerWrapper

+ (instancetype)sharedWrapper
{
    static NIMTeamManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMTeamManagerWrapper alloc] init];
    });
    return instance;
}

- (NSArray *)allMyTeams{
    return [[NIMTeamManager sharedManager] allMyTeams];
}

- (NIMTeam *)teamById:(NSString *)teamId{
    return [[NIMTeamManager sharedManager] teamById:teamId];
}

- (BOOL)isMyTeam:(NSString *)teamId
{
    return [[NIMTeamManager sharedManager] isMyTeam:teamId];
}


- (void)createTeam:(NIMCreateTeamOption *)option
             users:(NSArray *)users
        completion:(NIMTeamCreateHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
    
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager createTeam:option users:users completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,nil);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
}

- (void)dismissTeam:(NSString*)teamId
         completion:(NIMTeamHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager dismissTeam:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
        
    };
    
    
    nim_main_async_safe(mainBlock);
}


- (void)quitTeam:(NSString *)teamId
      completion:(NIMTeamHandler)block
{
    NIMAPITrace();

    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager quitTeam:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
    
}

- (void)addUsers:(NSArray  *)users
          toTeam:(NSString *)teamId
      postscript:(NSString *)postscript
      completion:(NIMTeamMemberHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager addUsers:users toTeam:teamId postscript:postscript completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,nil);
            }
        }
        
    };
    
    nim_main_async_safe(mainBlock);
}

- (void)kickUsers:(NSArray *)users
         fromTeam:(NSString *)teamId
       completion:(NIMTeamHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager kickUsers:users fromTeam:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
    };

    nim_main_async_safe(mainBlock);

}

- (void)updateTeamName:(NSString *)teamName
                teamId:(NSString *)teamId
            completion:(NIMTeamHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
    
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager updateTeamName:teamName teamId:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
        
    };
    
    nim_main_async_safe(mainBlock);
    
    
}

- (void)updateTeamJoinMode:(NIMTeamJoinMode)joinMode
                    teamId:(NSString *)teamId
                completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager updateTeamJoinMode:joinMode teamId:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);

}

- (void)updateTeamIntro:(NSString *)intro
                 teamId:(NSString *)teamId
             completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
    
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager updateTeamIntro:intro teamId:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
        
    };
    
    
    nim_main_async_safe(mainBlock);
}


- (void)updateTeamAnnouncement:(NSString *)announcement
                        teamId:(NSString *)teamId
                    completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager updateTeamAnnouncement:announcement teamId:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
}

- (void)updateTeamCustomInfo:(NSString *)info
                      teamId:(NSString *)teamId
                  completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager updateTeamCustomInfo:info teamId:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
        
    };
    
    nim_main_async_safe(mainBlock);
}


- (void)updateTeamInfos:(NSDictionary *)values
                 teamId:(NSString *)teamId
             completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager updateTeamInfos:values teamId:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
    };
    
    
    nim_main_async_safe(mainBlock);
}


- (void)applyToTeam:(NSString *)teamId
            message:(NSString *)message
         completion:(NIMTeamApplyHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager applyToTeam:teamId message:message completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,NIMTeamApplyStatusInvalid);

            }
        }
        
    };
    
    nim_main_async_safe(mainBlock);
}

- (void)passApplyToTeam:(NSString *)teamId
                 userId:(NSString *)userId
             completion:(NIMTeamApplyHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager passApplyToTeam:teamId userId:userId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,NIMTeamApplyStatusInvalid);
            }
        }
        
    };
    
    
    
    nim_main_async_safe(mainBlock);
}

- (void)rejectApplyToTeam:(NSString *)teamId
                   userId:(NSString *)userId
             rejectReason:(NSString*)rejectReason
               completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager rejectApplyToTeam:teamId userId:userId rejectReason:rejectReason completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
        
    };

    
    nim_main_async_safe(mainBlock);
}

- (void)updateUserNick:(NSString *)userId
               newNick:(NSString *)newNick
                inTeam:(NSString *)teamId
            completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager updateUserNick:userId newNick:newNick inTeam:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
        
    };
    
    
    
    nim_main_async_safe(mainBlock);
}

- (void)addManagersToTeam:(NSString *)teamId
                    users:(NSArray  *)users
               completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager addManagersToTeam:teamId users:users completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
        
    };
    
    
    
    nim_main_async_safe(mainBlock);
}

- (void)removeManagersFromTeam:(NSString *)teamId
                         users:(NSArray  *)users
                    completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager removeManagersFromTeam:teamId users:users completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
    };
    
    
    
    nim_main_async_safe(mainBlock);
}

- (void)transferManagerWithTeam:(NSString *)teamId
                     newOwnerId:(NSString *)newOwnerId
                        isLeave:(BOOL)isLeave
                     completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager transferManagerWithTeam:teamId newOwnerId:newOwnerId isLeave:isLeave completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
}

- (void)acceptInviteWithTeam:(NSString*)teamId
                   invitorId:(NSString*)invitorId
                  completion:(NIMTeamHandler)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager acceptInviteWithTeam:teamId invitorId:invitorId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }

    };
    
    nim_main_async_safe(mainBlock);
}

- (void)rejectInviteWithTeam:(NSString*)teamId
                   invitorId:(NSString*)invitorId
                rejectReason:(NSString*)rejectReason
                  completion:(NIMTeamHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager rejectInviteWithTeam:teamId invitorId:invitorId rejectReason:rejectReason completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
}


- (void)updateNotifyState:(BOOL)notify
                   inTeam:(NSString *)teamId
               completion:(NIMTeamHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager updateNotifyState:notify inTeam:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
        }

    };
    
    nim_main_async_safe(mainBlock);
}

- (BOOL)notifyForNewMsg:(NSString *)teamId
{
    NIMTeamManager *manager = [NIMTeamManager sharedManager];
    return manager ? [manager notifyForNewMsg:teamId] : YES;
}


- (void)fetchTeamMembers:(NSString *)teamId
              completion:(NIMTeamMemberHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager fetchTeamMembers:teamId
                            alwaysFromServer:NO
                                  completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,nil);
            }
        }

    };
    
    nim_main_async_safe(mainBlock);
}

- (void)fetchTeamMembersFromServer:(NSString *)teamId
                        completion:(NIMTeamMemberHandler)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager fetchTeamMembers:teamId
                            alwaysFromServer:YES
                                  completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,nil);
            }
        }

    };
    
    
    nim_main_async_safe(mainBlock);
}


- (void)fetchTeamInfo:(NSString *)teamId
           completion:(NIMTeamFetchInfoHandler)block{
    
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMTeamManager *manager = [NIMTeamManager sharedManager];
        if (manager) {
            return [manager fetchTeamInfo:teamId completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,nil);
            }
        }
    };
    
    
    
    nim_main_async_safe(mainBlock);
}


- (NIMTeamMember *)teamMember:(NSString *)userId
                       inTeam:(NSString *)teamId{
    return [[NIMTeamManager sharedManager] teamMember:userId inTeam:teamId];
}


- (void)addDelegate:(id<NIMTeamManagerDelegate>)delegate{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeTeam];
}

- (void)removeDelegate:(id<NIMTeamManagerDelegate>)delegate{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeTeam];
}


@end
