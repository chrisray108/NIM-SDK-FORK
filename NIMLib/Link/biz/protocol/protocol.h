// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/9/27
//
// Define the protocol id


#ifndef BIZ_PROTOCOL_PROTOCOL_H_
#define BIZ_PROTOCOL_PROTOCOL_H_

#include "base/util/string_util.h"

namespace nimbiz
{

typedef std::basic_string<char> ByteBuffer;
typedef std::basic_string<nbase::UTF8Char> UTF8String;

const uint32_t kCIDSyncOffset = 100;

enum SERVICE_ID
{
    //[0x00 - 0xFF 为网络协议服务]
    SVID_NIM_LINK               = 1,    //连接服务
    SVID_NIM_AUTH               = 2,    //登录
    SVID_NIM_USER               = 3,    //用户
    SVID_NIM_NOTIFY             = 4,    //通知
    SVID_NIM_SYNC               = 5,    //同步
    SVID_NIM_MISC               = 6,    //杂项
    SVID_NIM_SESSION            = 7,    //会话
    SVID_NIM_TEAM               = 8,    //群
    SVID_NIM_NETCALL            = 9,    //网络音视频通话
    SVID_NIM_RTS                = 11,   //实时会话
    SVID_NIM_FRIEND             = 12,   //好友关系
    SVID_NIM_CHATROOM           = 13,   //聊天室
    
    SVID_NODEF                  = 0xFF, // 未使用的网络协议服务
    
};

}





#endif  // BIZ_PROTOCOL_PROTOCOL_H_
