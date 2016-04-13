//
//  notify_service.h
//  YixinCall
//
//  Created by amao on 10/24/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#ifndef __YixinCall__notify_service__
#define __YixinCall__notify_service__
#include "session_protocol.h"
#include "notify_protocol.h"

namespace nimbiz
{

struct GetAllLeaveMsgsResposne : nbase::Marshallable
{
    std::vector<Property> msgs_;
    void marshal(nbase::Pack &p) const{assert(0);}
    virtual void unmarshal(const nbase::Unpack &up)
    {
        uint32_t length = up.pop_len();
        for (uint32_t i = 0; i < length; i++)
        {
            Property msg;
            up >> msg;
            msgs_.push_back(msg);
        }
    }
};


struct GetAllNetCallLeaveMsgsResponse : nbase::Marshallable
{
    std::vector<Property> netcalls_;
    void marshal(nbase::Pack &p) const{assert(0);}
    virtual void unmarshal(const nbase::Unpack &up)
    {
        uint32_t length = up.pop_len();
        for (uint32_t i = 0; i < length; i++)
        {
            Property msg;
            up >> msg;
            netcalls_.push_back(msg);
        }
    }
};

typedef GetAllLeaveMsgsResposne TeamListSayResponse;
typedef GetAllLeaveMsgsResposne AllRoamMsgsResponse;


struct MarkReadRequest : nbase::Marshallable
{
    uint64_t msg_id_;
    LinkFrame lf_;
    void unmarshal(const  nbase::Unpack &up){assert(0);}
    
    virtual void marshal(nbase::Pack &p) const
    {
        p.push_uint64(msg_id_);
        lf_.marshal_for_nf(p);
    }
};


struct BatchMarkReadRequest : nbase::Marshallable
{
    uint8_t sid_;
    uint8_t cid_;
    std::vector<uint64_t> msg_ids_;
    void unmarshal(const  nbase::Unpack &up){assert(0);}
    
    virtual void marshal(nbase::Pack &p) const
    {
        p.push_uint8(sid_);
        p.push_uint8(cid_);
        p.push_len((uint32_t)msg_ids_.size());
        for (size_t i = 0; i < msg_ids_.size(); i++)
        {
            p.push_uint64(msg_ids_[i]);
        }
    }
};



class NotifyService	: public INotifyService
{
public:
    NotifyService();
    ~NotifyService(void);
    virtual void Release() { delete this; }
    
    uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual void    Register_RecvMsgsCallback(const IAsynCallback &callback) {recv_msgs_callback_ = callback;}
    virtual void    Register_RecvNetCallsCallback(const IAsynCallback &callback) {recv_netcalls_callback_ = callback;}

private:
    void    OnpacketGetNotify(LinkFrame &lf, const nbase::Unpack &up);
    void    OnpacketGetAllLeaveMsgs(LinkFrame &lf, const nbase::Unpack &up);
    void    OnpacketGetAllRoamMsgs(LinkFrame &lf, const nbase::Unpack &up);
    void    OnpacketGetAllSystemNotifications(LinkFrame &lf,const nbase::Unpack &up);
    void    OnpacketGetTeamListResponse(LinkFrame &lf,const nbase::Unpack &up);
    void    OnpacketGetAllNetCallMsgs(LinkFrame &lf, const nbase::Unpack &up);
    void    DispatchNotifyMessage(LinkFrame &dispatch_link_frame, const nbase::Unpack &up, const uint64_t msg_id);
    void    OnpacketGetPush(LinkFrame &lf, const nbase::Unpack &up);
    void    OnpacketGetReceipts(LinkFrame &lf, const nbase::Unpack &up);
    
    void    Remote_MarkRead(const LinkFrame &lf,const uint64_t msg_id);
    void    Remote_BatchMarkRead(const LinkFrame &lf,const std::vector<uint64_t> &msg_ids);
    void    DoBatchMarkRead(const LinkFrame &lf,const std::vector<uint64_t> &msg_ids);
    
private:
    IAsynCallback   recv_msgs_callback_;
    IAsynCallback   recv_netcalls_callback_;

};
    
}

#endif /* defined(__YixinCall__notify_service__) */
