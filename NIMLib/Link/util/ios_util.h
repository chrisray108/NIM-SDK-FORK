//
//  ios_util.h
//  NIM
//
//  Created by amao on 13-3-27.
//  Copyright (c) 2013年 Netease. All rights reserved.
//
#ifndef IOS_UTIL_H
#define IOS_UTIL_H

#include <vector>
#include "biz/protocol/property.h"
#include "base/log/log.h"

namespace nimbiz {

//提供给C++用的辅助方法，由于可能是不具有autoreleasepool的线程里调用，所以需要加autorelease pool
UTF8String  GetAPNSToken();                     //APNS token
UTF8String  GetAPNSCerName();                   //APNS 证书名
UTF8String  GetDeviceID();                      //登录设备的唯一表示
UTF8String  GetUserDirectory();                 //返回当前用户目录
bool        CanConnectInternet();               //是否联网
void        SetShouldSwitchLinkHost(bool fatal);//切换host
void        SetShouldSwitchChatroomHost(std::string &room_id,bool fatal);//切换聊天室host
void        GetLinkAddress(std::string &addr, uint16_t &port);  //获取link地址
bool        HostUserInfos();
uint64_t    GetP2PTimetagByDB(const UTF8String &uid,const UTF8String &messageId);
int32_t     GetLoginTimeout();

}

#endif
