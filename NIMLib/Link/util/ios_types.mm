//
//  ios_types.m
//  NIMLib
//
//  Created by amao on 4/27/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "ios_types.h"
#import "NIMSDKHeaders.h"
#import "NIMClientManager.h"

namespace nimbiz {

int32_t     GetSessionP2PType()
{
    return NIMSessionTypeP2P;
}


int32_t     GetSessionTeamType()
{
    return NIMSessionTypeTeam;
}


uint32_t    GetTeamMemberOwnerType()
{
    return (uint32_t)NIMTeamMemberTypeOwner;
}

uint32_t    GetTeamMemberNormalType()
{
    return (uint32_t)NIMTeamMemberTypeNormal;
}

uint8_t     GetMultiLoginInitType()
{
    return (uint8_t)NIMMultiLoginTypeInit;
}


int32_t     GetFriendOperationTypeAdd()
{
    return (int32_t)NIMUserOperationAdd;
}

int32_t     GetFriendOperationTypeVerify()
{
    return (int32_t)NIMUserOperationVerify;
}

}