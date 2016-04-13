//
//  user_protocol.h
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef NIMLib_user_protocol_h
#define NIMLib_user_protocol_h


#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"

namespace nimbiz
{

enum
{
    CID_UPDATE_PUSH_TOKEN   = 1,
    CID_APP_BACKGROUND      = 2,
    
    CID_MARK_IN_BLACKLIST       = 3,
    CID_MARK_IN_BLACKLIST_SYNC  = 103,

    CID_MARK_MUTELIST       = 5,
    CID_MARK_MUTELIST_SYNC  = 105,
    
    CID_GET_USER_UINFO      = 7,
    
    CID_SYNC_MUTE_AND_BLACK = 8,
    
    CID_UPDATE_MY_UINFO       = 10,
    CID_SYNC_MY_UINFO          = 109, //同步我的uinfo
    CID_SYNC_UPDATE_MY_UINFO = 110,   //多端同步更新我的uinfo
    
    CID_APP_APNS            = 13,
    CID_SET_USER_STAT       = 14,
};

enum
{
    NIMRelationTagId         = 0,
    NIMRelationTagMute       = 1,
    NIMRelationTagBlackList  = 2,
    NIMRelationTagCreateTime = 3,
    NIMRelationTagUpdateTime = 4,
};


enum
{
    NIMUserInfoTagId         = 1,
    NIMUserInfoTagAppId      = 2,
    NIMUserInfoTagNick       = 3,
    NIMUserInfoTagAvatar     = 4,
    NIMUserInfoTagSign       = 5,
    NIMUserInfoTagGender     = 6,
    NIMUserInfoTagEmail      = 7,
    NIMUserInfoTagBirth      = 8,
    NIMUserInfoTagMobile     = 9,
    NIMUserInfoTagEx         = 10,
    NIMUserInfoTagCreateTime = 12,
    NIMUserInfoTagUpdateTime = 13,    
};


typedef IAsynTaskCallbackParam CBUpdateApnsParam;

struct CBUpdateOnlineStateParam : IAsynCallbackParam
{
    uint32_t state_;
};

struct CBUserInfoListParam : IAsynTaskCallbackParam
{
    int32_t code_;
    std::list<Property> userInfoList_;
};


#pragma mark - IUserService
class IUserService : public IService
{
public:
    IUserService() : IService(SVID_NIM_USER) {}
public:
    
    virtual void    Invoke_UpdateToken() = 0;
    virtual void    Remote_UpdateToken() = 0;

    virtual void    Invoke_UpdateAppInfo(bool background,uint32_t badge) = 0;
    virtual void    Remote_UpdateAppInfo(bool background,uint32_t badge) = 0;
    
    
    virtual int32_t    Invoke_UpdatePush(const Property &info,const IAsynCallback &callback) = 0;
    virtual void       Remote_UpdatePush(const Property &info,const IAsynCallback &callback,int32_t task_id) = 0;
    
    virtual void    Invoke_UpdateOnlineState(uint32_t state,const IAsynCallback &callback) = 0;
    virtual void    Remote_UpdateOnlineState(uint32_t state,const IAsynCallback &callback) = 0;
    
    
    virtual int32_t Invoke_UpdateBlack(const UTF8String &uid,bool black,const IAsynCallback &callback) = 0;
    virtual void    Remote_UpdateBlack(const UTF8String &uid,bool black,const IAsynCallback &callback,int32_t task_id) = 0;
    
    
    virtual int32_t Invoke_UpdateMute(const UTF8String &uid,bool mute,const IAsynCallback &callback) = 0;
    virtual void    Remote_UpdateMute(const UTF8String &uid,bool mute,const IAsynCallback &callback,int32_t task_id) = 0;
    
    virtual int32_t Invoke_FetchUsers(std::list<UTF8String> &uids,const IAsynCallback &callback) = 0;
    virtual void    Remote_FetchUsers(std::list<UTF8String> &uids,const IAsynCallback &callback,int32_t task_id) = 0;

    virtual int32_t Invoke_UpdateMyInfo(Property &info,const IAsynCallback &callback) = 0;
    virtual void    Remote_UpdateMyInfo(Property &info,const IAsynCallback &callback,int32_t task_id) = 0;

    
    virtual uint32_t    GetBlackList(std::list<UTF8String> &uids) = 0;
    virtual uint32_t    GetMuteList(std::list<UTF8String> &uids) = 0;
    virtual void        GetUserInfo(const UTF8String &uid,Property &property) = 0;
    virtual bool        IsUserInBlackList(const UTF8String &uid) = 0;
    virtual bool        IsUserMute(const UTF8String &uid) = 0;
    virtual void        CheckUserInfo(const Property &recv_msg) = 0;
    virtual void        SaveUserInfoFromServer(const Property &info) = 0;
    virtual bool        UserInfoExists(const UTF8String &uid) = 0;
    
};

}

#endif
