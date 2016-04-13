//
//  chatroom_protocol.h
//  NIMLib
//
//  Created by amao on 12/8/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#ifndef chatroom_protocol_h
#define chatroom_protocol_h

#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"
#include "biz/core/link_socket.h"


namespace nimbiz
{
    enum
    {
        CID_CR_REQUEST_ROOM_ADDR=   1,
        CID_CR_ENTER            =   2,
        CID_CR_NOTIFY_KICK      =   3,
        CID_CR_EXIT             =   4,
        CID_CR_SAY              =   6,
        CID_CR_NOTIFY_SAY       =   7,
        CID_CR_FETCH_MEMBERS    =   8,
        CID_CR_HISTORY_MSG      =   9,
        CID_CR_UPDATE_MEMBER    =   11,
        CID_CR_CLOSE            =   12,
        CID_CR_ROOM_INFO        =   13,
        CID_CR_MEMBER_INFO_LIST =   16,
        CID_CR_KICK             =   17,
    };
    
    enum NIMChatroomLoginTag
    {
        NIMChatroomLoginTagAppKey       = 1,
        NIMChatroomLoginTagAppAccount   = 2,
        NIMChatroomLoginTagDeviceId     = 3,
        NIMChatroomLoginTagIMConsid     = 4,
        NIMChatroomLoginTagRoomId       = 5,
        
        NIMChatroomLoginTagNick         = 20,
        NIMChatroomLoginTagAvatar       = 21,
        NIMChatroomLoginTagRoomExt      = 22,
        NIMChatroomLoginTagNotifyExt    = 23,
        
        NIMChatroomLoginTagClientSession= 26,
        
    };
    
    
    enum NIMChatroomMsgTag
    {
        NIMChatroomMsgTagClientId   =   1,
        NIMChatroomMsgTagContentType=   2,
        NIMChatroomMsgTagAttach     =   3,
        NIMChatroomMsgTagServerExt  =   4,
        NIMChatroomMsgTagResendFlag =   5,
        
        //聊天室拓展tag
        NIMChatroomMsgTagFromNick   =   7,
        NIMChatroomMsgTagFromAvatar =   8,
        NIMChatroomMsgTagFromExt    =   9,
        
        NIMChatroomMsgTagTime       =   20,
        NIMChatroomMsgTagFromId     =   21,
        NIMChatroomMsgTagRoomId     =   22,
        NIMChatroomMsgTagClientType =   23,
        
    };
    
    enum NIMChatroomMemberTag
    {
        NIMChatroomMemberTagUid       =   2,
        NIMChatroomMemberTagType      =   3,
        NIMChatroomMemberTagLevel     =   4,
        NIMChatroomMemberTagNick      =   5,
        NIMChatroomMemberTagAvatar    =   6,
        NIMChatroomMemberTagExt       =   7,
        
        NIMChatroomMemberTagOnline    =   8,
        NIMChatroomMemberTagGuest     =   9,
        NIMChatroomMemberTagEnterTime =   10,
        
        NIMChatroomMemberTagBlackList =   12,
        NIMChatroomMemberTagMuted     =   13,
        NIMChatroomMemberTagVaild     =   14,
        NIMChatroomMemberTagUpdateTime =  15,
    };
    
    enum NIMChatroomUpdateTag
    {
        NIMChatroomMemberUpdateTagMuted     = -2,
        NIMChatroomMemberUpdateTagBlacklist = -1,
        NIMChatroomMemberUpdateTagManager   = 1,
        NIMChatroomMemberUpdateTagCommon    = 2,
    };

    
    enum NIMChatroomTag
    {
        NIMChatroomTagRoomId        =   1,
        NIMChatroomTagName          =   3,
        NIMChatroomTagAnnouncement  =   4,
        NIMChatroomTagBroadcastUrl  =   5,
        NIMChatroomTagExt           =   12,
        NIMChatroomTagCreator       =   100,
        NIMChatroomTagOnlineCount   =   101,
    };
    
#pragma mark - 回调参数
    struct CBChatroomParam : IAsynCallbackParam
    {
        UTF8String  room_id_;
    };
    
    struct CBChatroomTaskParam : IAsynTaskCallbackParam
    {
        UTF8String  room_id_;
    };
    
    
    struct CBLinkChatroomParam : CBChatroomTaskParam
    {
        UTF8String link_id_;
        bool connected;
    };
    
    struct CBDisconnectChatroomParam : CBChatroomParam
    {
        UTF8String link_id_;
    };
    
    struct CBChatroomBeKickedParam : CBChatroomParam
    {
        int32_t reason_;
    };
    
    struct CBEnterChatroomParam : CBChatroomTaskParam
    {
        Property room_;
        Property me_;
    };
    
    typedef CBChatroomTaskParam CBExitChatroomParam;
    
    typedef CBChatroomTaskParam CBCloseChatroomParam;
    
    typedef CBChatroomTaskParam CBKickChatroomParam;
    
    
    struct CBChatroomRequestChatroomParam : CBChatroomTaskParam
    {
        std::list<UTF8String>  addresses_;
    };
    
    struct CBChatroomSendMsgParam : CBChatroomParam
    {
        UTF8String client_id_;
    };
    
    struct CBChatroomReceiveMsgParam : CBChatroomParam
    {
        Property cb_msg_;
    };
    
    struct CBChatroomFetchMembersParam : CBChatroomTaskParam
    {
        std::list<Property>  members_;
    };
    
    struct CBChatroomHistoryMsgParam : CBChatroomTaskParam
    {
        std::list<Property>  msgs_;
    };
    
    struct CBChatroomUpdateMemberParam : CBChatroomTaskParam
    {
        Property  member_;
    };
    
    struct CBChatroomInfoParam : CBChatroomTaskParam
    {
        Property  room_;
    };
    
    
#pragma mark - 请求参数
    struct LinkChatroomData
    {
        UTF8String room_id_;
        UTF8String room_ip_;
        int32_t room_port_;
        UTF8String link_id_;
    };
    
    
    struct EnterChatroomRequest : nbase::Marshallable {
        
        int32_t type_;
        Property chatroom_request_;
        Property im_request_;
        
        EnterChatroomRequest():type_(2){}
        
        void marshal(nbase::Pack &p) const
        {
            p.push_uint8(type_);
            p << chatroom_request_;
            p << im_request_;
        }
        YX_REQUEST_ONLY();
    };
    
    
    struct ChatroomMembersRequest : nbase::Marshallable {
        
        UTF8String room_id_;
        int32_t type_;
        int64_t end_;
        int32_t limit_;
        
        void marshal(nbase::Pack &p) const
        {
            p.push_uint8(type_);
            p.push_uint64(end_);
            p.push_uint32(limit_);
        }
        YX_REQUEST_ONLY();
    };
    
    
    struct ChatroomMembersRequestByIds : nbase::Marshallable {
        
        UTF8String room_id_;
        std::list<UTF8String> uids_;
        void marshal(nbase::Pack &p) const
        {
            size_t size = uids_.size();
            p.push_len((uint32_t)size);
            for (auto it = uids_.begin(); it!= uids_.end(); it++)
            {
                p.push_varstr(*it);
            }
        }
        YX_REQUEST_ONLY();
    };
    
    
    struct ChatroomHistoryMsgReqeust : nbase::Marshallable
    {
        UTF8String room_id_;
        uint64_t from_time_;
        uint32_t limit_;
        
        void marshal(nbase::Pack &p) const
        {
            p.push_uint64(from_time_);
            p.push_uint32(limit_);
        }
        YX_REQUEST_ONLY();
    };
    
    
    struct ChatroomMemberUpdateRequest : nbase::Marshallable {
        
        UTF8String room_id_;
        UTF8String user_id_;
        int32_t option_;
        int32_t level_;
        UTF8String notifyExt_;
        bool valid_;
        
        void marshal(nbase::Pack &p) const
        {
            p.push_varstr(user_id_);
            p.push_uint32(option_);
            p.push_bool(valid_);
            p.push_uint32(level_);
            p.push_varstr(notifyExt_);
        }
        YX_REQUEST_ONLY();
    };
    
    struct ChatroomCloseRoomRequest : nbase::Marshallable {
        UTF8String room_id_;
        UTF8String notify_ext_;
        
        void marshal(nbase::Pack &p) const
        {
            p.push_varstr(notify_ext_);
        }
        YX_REQUEST_ONLY();
    };
    
    struct ChatroomMemberKickRequest : nbase::Marshallable {
        UTF8String room_id_;
        UTF8String target_id_;
        UTF8String notify_ext_;
        
        void marshal(nbase::Pack &p) const
        {
            p.push_varstr(target_id_);
            p.push_varstr(notify_ext_);
        }
        YX_REQUEST_ONLY();
    };
    

    
    
    
    
    class IChatroomService : public IService
    {
    public:
        IChatroomService() : IService(SVID_NIM_CHATROOM) {}
    public:
        virtual int32_t Invoke_RequestChatroom(const UTF8String &room_id,const IAsynCallback &callback) = 0;
        virtual void    Remote_RequestChatroom(const UTF8String &room_id,const IAsynCallback &callback,int task_id) = 0;
        
        
        virtual void    Invoke_ConnectRoom(const LinkChatroomData &data,const IAsynCallback &callback) = 0;
        virtual void    Remote_ConnectRoom(const LinkChatroomData &data,const IAsynCallback &callback) = 0;
        virtual void    Register_DisconnectCallback(const IAsynCallback &callback) = 0;
        virtual void    Remote_NotifyConnected(const UTF8String &room_id,const UTF8String &link_id,NetErrorCode code) = 0;
        virtual void    Remote_NotifyDisconnected(const UTF8String &room_id,const UTF8String &link_id,NetErrorCode code) = 0;
        
        
        virtual int32_t Invoke_EnterRoom(const EnterChatroomRequest &request,const IAsynCallback &callback) = 0;
        virtual void    Remote_EnterRoom(const EnterChatroomRequest &request,const IAsynCallback &callback,int32_t task_id) = 0;
        
        virtual int32_t Invoke_ExitRoom(const UTF8String &room_id,const IAsynCallback &callback) = 0;
        virtual void    Remote_ExitRoom(const UTF8String &room_id,const IAsynCallback &callback,int32_t task_id) = 0;
        
        virtual void    Invoke_Say(Property &msg,int32_t retry_duration = 0) = 0;
        virtual void    Remote_Say(Property &msg,int32_t retry_duration = 0) = 0;
        
        virtual void    Register_SendMsgCallback(const IAsynCallback &callback) = 0;
        virtual void    Register_RecvMsgsCallback(const IAsynCallback &callback)= 0;
        virtual void    Register_KickCallback(const IAsynCallback &callback) = 0;
        
        virtual void    Invoke_Ping(const UTF8String &room_id) = 0;
        virtual void    Remote_Ping(const UTF8String &room_id) = 0;
        
        
        virtual int32_t Invoke_FetchRoomMember(const ChatroomMembersRequest &request,const IAsynCallback &callback) = 0;
        virtual void    Remote_FetchRoomMember(const ChatroomMembersRequest &request,const IAsynCallback &callback,int32_t task_id) = 0;
        
        virtual int32_t Invoke_HistoryMsg(const ChatroomHistoryMsgReqeust &request,const IAsynCallback &callback) = 0;
        virtual void    Remote_HistoryMsg(const ChatroomHistoryMsgReqeust &request,const IAsynCallback &callback,int32_t task_id) = 0;
        
        virtual int32_t Invoke_UpdateMember(const ChatroomMemberUpdateRequest &request,const IAsynCallback &callback) = 0;
        virtual void    Remote_UpdateMember(const ChatroomMemberUpdateRequest &request,const IAsynCallback &callback,int32_t task_id) = 0;

        virtual int32_t Invoke_CloseRoom(const ChatroomCloseRoomRequest &request,const IAsynCallback &callback) = 0;
        virtual void    Remote_CloseRoom(const ChatroomCloseRoomRequest &request,const IAsynCallback &callback,int32_t task_id) = 0;
        
        virtual int32_t Invoke_GetRoomInfo(const UTF8String &room_id,const IAsynCallback &callback) = 0;
        virtual void    Remote_GetRoomInfo(const UTF8String &room_id,const IAsynCallback &callback,int32_t task_id) = 0;
        
        virtual int32_t Invoke_FetchMembersByIds(const ChatroomMembersRequestByIds &request,const IAsynCallback &callback) = 0;
        virtual void    Remote_FetchMembersByIds(const ChatroomMembersRequestByIds &request,const IAsynCallback &callback,int32_t task_id) = 0;
        
        virtual int32_t Invoke_KickMember(const ChatroomMemberKickRequest &request,const IAsynCallback &callback) = 0;
        virtual void    Remote_KickMember(const ChatroomMemberKickRequest &request,const IAsynCallback &callback,int32_t task_id) = 0;

        
        virtual void    CleanUp() = 0;
        
    };
}





#endif /* _chatroom_protocol_h */
