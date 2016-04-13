// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/26
//
// This file defines the head of the packet exchanges between client and server

#ifndef BIZ_PROTOCOL_LINKFRAME_H_
#define BIZ_PROTOCOL_LINKFRAME_H_

#include <stdio.h>
#include <string>
#include <vector>
#include "base/util/string_util.h"
#include "base/memory/packet.h"
#include "base/error.h"
#include "base/log/log.h"
#include "protocol.h"
#include "response_code.h"

namespace nimbiz
{

//新包头
struct LinkFrame : public nbase::Marshallable
{
    enum 
    {
        Default        = 0,        //发往Trunk
        Compressed     = 1,        //压缩
        ResCode        = 2,        //回包
        HasKey         = 4,        //是否包含key
    };
    
    uint32_t            length_;        // packet length, includes header
    
    uint8_t             service_id_;    // service id
    uint8_t             command_id_;    // command id
    uint16_t            serial_id_;     // serial id of command
    mutable uint8_t     tag_;           // this value is defined by the constants kTruncked, kCompressed, etc.
    
    //变长内容
    UTF8String          key_;           // uint64_t
    uint16_t            error_;         // error number, set by server
    
    
    //本地数据 (不参与网络发送)
    uint64_t            msg_id_;
    UTF8String          room_id_;
    
    LinkFrame()
    {
        length_     = 0;
        service_id_ = 0;
        command_id_ = 0;
        serial_id_  = 0;
        tag_        = Default;
        
        error_      = NIMResSuccess;
        msg_id_     = 0;
    }
    
    LinkFrame(uint8_t service_id, uint8_t command_id)
    {
        length_     = 0;
        service_id_ = service_id;
        command_id_ = command_id;
        serial_id_  = 0;
        tag_        = Default;
        
        error_      = NIMResSuccess;
        msg_id_     = 0;
    }
    
    
    bool is_compressed() const   { return 0 != (tag_ & Compressed); }
    void set_compressed() const  { tag_ |= Compressed; }
    void clear_compressed() const{ tag_ &= ~Compressed; }
    
    
    bool has_key() const {return 0 != (tag_ & HasKey);}
    bool has_rescode() const { return 0 != (tag_ & ResCode);}
    

    
    virtual void marshal(nbase::Pack &p) const
    {
        
        p.push_uint32(length_);     //marshal的时候还是定长 最后发送时替换
        p.push_uint8(service_id_);
        p.push_uint8(command_id_);
        p.push_uint16(serial_id_);
        p.push_uint8(tag_);
        
        if (has_rescode())
        {
            p.push_uint16(error_);
        }
        if (has_key())
        {
            p.push_varstr_as_uint64(key_);
        }
    }
    
    
    
    virtual void unmarshal(const nbase::Unpack &up)
    {
        //unmarshal时长度可以54
        for (int i = 0; i < 4; i++)
        {
            uint8_t byte = up.pop_uint8();
            if ((byte & 0x80) == 0)
            {
                break;
            }
        }
        
        service_id_ = up.pop_uint8();
        command_id_ = up.pop_uint8();
        serial_id_  = up.pop_uint16();
        tag_        = up.pop_uint8();
        
        if (has_rescode())
        {
            error_ = up.pop_uint16();
        }
        if (has_key())
        {
            key_ = up.pop_uint64_as_str();
        }
    }
    
    
    virtual void marshal_for_nf(nbase::Pack &p) const
    {
        p.push_uint8(0);
        p.push_uint8(service_id_);
        p.push_uint8(command_id_);
        p.push_uint16(serial_id_);
        p.push_uint8(tag_);
        
        if (has_rescode())
        {
            p.push_uint16(error_);
        }
    }
};


//翼聊NotifyFrame
struct NotifyFrame : nbase::Marshallable
{
    uint64_t msg_id_;
    LinkFrame lf_;
    
    void unmarshal(const  nbase::Unpack &up)
    {
        msg_id_ = up.pop_uint64();
        lf_.unmarshal(up);
    }
    
    virtual void marshal(nbase::Pack &p) const
    {
        p.push_uint64(msg_id_);
        lf_.marshal_for_nf(p);
    }

};

struct LinkPacker : public nbase::Pack
{
    LinkPacker(nbase::PackBuffer & pb) : nbase::Pack(pb) {}
    
    void length_to_vt(uint32_t length,std::vector<uint8_t>& vt)
    {
        while (length)
        {
            uint8_t byte = length % 0x80;
            length /= 0x80;
            if (length)
            {
                byte |= 0x80;
            }
            vt.push_back(byte);
        }
    }
    
    void endpack()
    {
        if (size() > 0x7FFFFFFF)
        {
            nbase::DEFLOG(nbase::LogInterface::LV_APP,
                          __FILE__, __LINE__,
                          "LinkPacker, package too big"
                          );
        }
        std::vector<uint8_t> vt;
        length_to_vt((uint32_t)(size() - 4), vt);
        offset_ = 4 - vt.size();
        if (offset_ >= 4)
        {
            assert(0);
            return;
        }
        for (size_t i = 0; i < vt.size(); i++)
        {
            replace_uint8(offset_ + i, vt[i]);
        }
    }
    
    
};
    
}


#endif //BIZ_PROTOCOL_LINKFRAME_H_
