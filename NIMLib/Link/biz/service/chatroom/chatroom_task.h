//
//  chatroom_task.h
//  NIMLib
//
//  Created by amao on 12/8/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#ifndef chatroom_task_h
#define chatroom_task_h

#include "chatroom_protocol.h"
#include "biz/protocol/property.h"
#include "biz/core/eim_task.h"

namespace nimbiz
{
    class ChatroomConnectTask : public YixinTask
    {
    public:
        ChatroomConnectTask(const LinkChatroomData &data,const IAsynCallback &callback)
        :data_(data),callback_(callback){}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_ConnectRoom(data_, callback_);
            }
        }
    private:
        IAsynCallback callback_;
        LinkChatroomData data_;
    };
    
    
    
    class ChatroomNotifyConnectTask : public YixinTask
    {
    public:
        ChatroomNotifyConnectTask(const UTF8String &room_id,const UTF8String &link_id,NetErrorCode code)
        :room_id_(room_id),link_id_(link_id),code_(code){}
            
            virtual void Run()
            {
                IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
                if(service)
                {
                    service->Remote_NotifyConnected(room_id_, link_id_, code_);
                }
            }
        private:
            UTF8String  room_id_;
            UTF8String  link_id_;
            NetErrorCode code_;
    };
    
    
    
    class ChatroomNotifyDisconnectedTask : public YixinTask
    {
    public:
        ChatroomNotifyDisconnectedTask(const UTF8String &room_id,const UTF8String &link_id,NetErrorCode code)
        :room_id_(room_id),link_id_(link_id),code_(code){}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_NotifyDisconnected(room_id_,link_id_,code_);
            }
        }
    private:
        UTF8String  room_id_;
        UTF8String  link_id_;
        NetErrorCode code_;
    };
    
    class ChatroomEnterTask : public YixinTask
    {
    public:
        ChatroomEnterTask(const EnterChatroomRequest &request,const IAsynCallback &callback)
        :request_(request),callback_(callback){}
            
            virtual void Run()
            {
                IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
                if(service)
                {
                    service->Remote_EnterRoom(request_, callback_, GetTaskId());
                }
            }
        private:
            EnterChatroomRequest request_;
            IAsynCallback callback_;
    };
    
    
    class ChatroomExitTask : public YixinTask
    {
    public:
        ChatroomExitTask(const UTF8String &room_id,const IAsynCallback &callback)
        :room_id_(room_id),callback_(callback) {}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_ExitRoom(room_id_, callback_, GetTaskId());
            }
        }
    private:
        UTF8String  room_id_;
        IAsynCallback callback_;    };
    
    
    class ChatroomRequestChatroomTask : public YixinTask
    {
    public:
        ChatroomRequestChatroomTask(const UTF8String &room_id,const IAsynCallback &callback)
        :room_id_(room_id),callback_(callback) {}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_RequestChatroom(room_id_, callback_, GetTaskId());
            }
        }
    private:
        UTF8String  room_id_;
        IAsynCallback callback_;
    };
    
    
    class ChatroomSendMsgTask : public YixinTask
    {
    public:
        ChatroomSendMsgTask(const Property &msg,int32_t retry_duration)
        :msg_(msg),retry_duration_(retry_duration){}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_Say(msg_,retry_duration_);
            }
        }
    private:
        Property msg_;
        int32_t retry_duration_;
    };
    
    class ChatroomPingTask : public YixinTask
    {
        public:
            ChatroomPingTask(const UTF8String &room_id)
            :room_id_(room_id){}
            
            virtual void Run()
            {
                IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
                if(service)
                {
                    service->Remote_Ping(room_id_);
                }
            }
        private:
            UTF8String room_id_;
    };
    
    
    class ChatroomFetchMembersTask : public YixinTask
    {
        public:
            ChatroomFetchMembersTask(const ChatroomMembersRequest &request,const IAsynCallback &callback)
            :request_(request),callback_(callback){}
            
            virtual void Run()
            {
                IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
                if(service)
                {
                    service->Remote_FetchRoomMember(request_, callback_, GetTaskId());
                }
            }
        private:
            ChatroomMembersRequest request_;
            IAsynCallback callback_;
    };
    
    
    class ChatroomHistoryMsgTask : public YixinTask
    {
        public:
            ChatroomHistoryMsgTask(const ChatroomHistoryMsgReqeust &request,const IAsynCallback &callback)
            :request_(request),callback_(callback){}
            
            virtual void Run()
            {
                IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
                if(service)
                {
                    service->Remote_HistoryMsg(request_, callback_, GetTaskId());
                }
            }
        private:
            ChatroomHistoryMsgReqeust request_;
            IAsynCallback callback_;
    };
    
    
    class ChatroomUpdateMemberTask : public YixinTask
    {
    public:
        ChatroomUpdateMemberTask(const ChatroomMemberUpdateRequest &request,const IAsynCallback &callback)
        :request_(request),callback_(callback){}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_UpdateMember(request_, callback_, GetTaskId());
            }
        }
    private:
        ChatroomMemberUpdateRequest request_;
        IAsynCallback callback_;
    };
    
    
    class ChatroomCloseRoomTask : public YixinTask
    {
    public:
        ChatroomCloseRoomTask(const ChatroomCloseRoomRequest &request,const IAsynCallback &callback)
        :request_(request),callback_(callback){}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_CloseRoom(request_, callback_, GetTaskId());
            }
        }
    private:
        ChatroomCloseRoomRequest request_;
        IAsynCallback callback_;
    };
    
    
    class ChatroomGetRoomInfoTask : public YixinTask
    {
    public:
        ChatroomGetRoomInfoTask(const UTF8String &room_id,const IAsynCallback &callback)
        :room_id_(room_id),callback_(callback){}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_GetRoomInfo(room_id_, callback_, GetTaskId());
            }
        }
    private:
        UTF8String room_id_;
        IAsynCallback callback_;
    };
    
    
    class ChatroomFetchMembersByIdsTask : public YixinTask
    {
    public:
        ChatroomFetchMembersByIdsTask(const ChatroomMembersRequestByIds &request,const IAsynCallback &callback)
        :request_(request),callback_(callback){}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_FetchMembersByIds(request_, callback_, GetTaskId());
            }
        }
    private:
        ChatroomMembersRequestByIds request_;
        IAsynCallback callback_;
    };
    
    
    class ChatroomKickTask : public YixinTask
    {
    public:
        ChatroomKickTask(const ChatroomMemberKickRequest &request,const IAsynCallback &callback)
        :request_(request),callback_(callback){}
        
        virtual void Run()
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if(service)
            {
                service->Remote_KickMember(request_, callback_, GetTaskId());
            }
        }
    private:
        ChatroomMemberKickRequest request_;
        IAsynCallback callback_;
    };
}





#endif /* chatroom_task_h */
