// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/27
//
// This file defines a class to pretranslate and send request packet

#ifndef BIZ_CORE_LINK_SENDER_H_
#define BIZ_CORE_LINK_SENDER_H_

#include "biz/protocol/linkframe.h"
#include "biz/protocol/linkframe_compress.h"

namespace nimbiz
{

const int kPopoLinkCompressSize = 1024;
const int kPopoLinkTrunkSize = (60 * 1024);
    
template <class ILinkSenderClass>
class LinkSender
{
public:
    LinkSender(ILinkSenderClass *link_sender, bool trunkable = true)
        : link_sender_(link_sender), trunkable_(trunkable)
    {
        
    }
    
    void send(const LinkFrame &lf, const nbase::Marshallable &request)
    {
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Send Packet : SID %d CID %d SER %d",
                      lf.service_id_,lf.command_id_,lf.serial_id_);
        
        nbase::PackBuffer buffer;
        LinkPacker packet(buffer);
        packet << lf;
        size_t offset = buffer.size();
        packet << request;
        
        if (packet.size() < kPopoLinkCompressSize)
        {
            packet.endpack();
            link_sender_->PostSendTask(packet.data(), packet.size());
            return;
        }
        
        // 大数据包，压缩之后发送
        char *param = buffer.data() + offset;
        if (!lf.is_compressed()) 
        {
            CompressInfo cinfo;
            if (cinfo.compress(param, buffer.size() - offset))
            {
                lf.set_compressed();
                trunk_send(lf, cinfo.data(), cinfo.length());
                return;
            }
            // 压缩失败
        }
        
        if (trunkable_)
        {
            trunk_send(lf, param, buffer.size() - offset);
        }
        else
        {
            pack_send(lf, nbase::Rawmable(param, buffer.size() - offset));
        }
    }
    
private:
    // 分块发送目前未实现
    void trunk_send(const LinkFrame &lf, const char *data, size_t size)
    {
        pack_send(lf, nbase::Rawmable(data, size));
    }
    
    void pack_send(const LinkFrame &lf, const nbase::Marshallable &request)
    {
        nbase::PackBuffer buffer;
        LinkPacker packet(buffer);
        packet << lf << request;
        packet.endpack();
        link_sender_->PostSendTask(packet.data(), packet.size());
    }
    
private:
    ILinkSenderClass *link_sender_;
    bool trunkable_;
};
    
}

#endif // BIZ_CORE_LINK_SENDER_H_
