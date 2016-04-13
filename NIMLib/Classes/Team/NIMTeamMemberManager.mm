//
//  NIMTeamMemberManager.m
//  NIMLib
//
//  Created by amao on 12/3/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMTeamMemberManager.h"
#import "team_protocol.h"
#import "ios_util.h"
#import "NIMProtocolUtil.h"
#import "NIMSDK_Private.h"
#import "NIMSDKConfig_Private.h"

@implementation NIMTeamMemberManager
- (void)fetchMissedMemberInfos:(NSString *)teamId
                    completion:(NIMTeamHandler)handler
{
    NSArray *members = [[NIMSDKConfig sharedConfig] hostUserInfos] ? [self teamMembersWithoutInfo:teamId] : nil;
    if ([members count])
    {
        NIMLogApp(@"request team member infos for %@ count %zd",teamId,[members count]);
        [self fetchUsers:members
              completion:handler];
    }
    else
    {
        if (handler) {
            handler(nil);
        }
    }
}

- (NSArray *)teamMembersWithoutInfo:(NSString *)teamId
{
    NSArray *array = nil;
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        std::list<nimbiz::UTF8String> user_ids;
        if ( service->GetTeamUsersWithoutInfo(UTF8(teamId), user_ids))
        {
            array =  [NIMProtocolUtil stringListToArray:user_ids];
        }
    }
    return array;
}


- (void)fetchUsers:(NSArray *)userIds
        completion:(NIMTeamHandler)handler
{
    static NSInteger NIMMaxFetchUserInfos = 500;
    if ([userIds count] <= NIMMaxFetchUserInfos)
    {
        [[[NIMSDK sharedSDK] userManager] fetchUserInfos:userIds
                                              completion:^(NSArray *users, NSError *error) {
                                                  if (handler) {
                                                      handler(error);
                                                  }
                                                  
                                              }];
    }
    else
    {
        NSArray *currentRequestUsers = [userIds subarrayWithRange:NSMakeRange(0, NIMMaxFetchUserInfos)];
        NSArray *nextRequestUsers = [userIds subarrayWithRange:NSMakeRange(NIMMaxFetchUserInfos, [userIds count] - NIMMaxFetchUserInfos)];
        [[[NIMSDK sharedSDK] userManager] fetchUserInfos:currentRequestUsers
                                              completion:^(NSArray *users, NSError *error) {
                                                  if (error) {
                                                      if (handler) {
                                                          handler(error);
                                                      }
                                                  }
                                                  else
                                                  {
                                                      [self fetchUsers:nextRequestUsers
                                                            completion:handler];
                                                  }
                                              }];
    }
}
@end
