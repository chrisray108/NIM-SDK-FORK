//
//  NIMTeamManager_Private.m
//  NIMLib
//
//  Created by amao on 12/3/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMTeamManager_Private.h"
#import "team_protocol.h"
#import "NIMTeamMemberManager.h"

@implementation NIMTeamManager (Private)
- (void)requestMissedMemberInfos:(NSString *)teamId
                      completion:(NIMTeamHandler)handler
{
    [_memberManager fetchMissedMemberInfos:teamId
                                completion:handler];
}

- (void)requestTeamMembers:(NSString *)teamId
{
    nimbiz::ITeamService *service = (nimbiz::ITeamService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (service)
    {
        service->Invoke_RefreshTeamMembers(UTF8(teamId));
    }
}
@end
