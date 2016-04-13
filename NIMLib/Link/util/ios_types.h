//
//  ios_types.h
//  NIMLib
//
//  Created by amao on 4/27/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

//一些在NIMSDK头文件中定义的常量,但是协议层需要使用,就通过这种方式做转换
namespace nimbiz {
    


int32_t     GetSessionP2PType();

int32_t     GetSessionTeamType();

uint32_t    GetTeamMemberOwnerType();

uint32_t    GetTeamMemberNormalType();

uint8_t     GetMultiLoginInitType();


int32_t     GetFriendOperationTypeAdd();

int32_t     GetFriendOperationTypeVerify();

}