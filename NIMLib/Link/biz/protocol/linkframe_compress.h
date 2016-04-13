// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/26
//
// This file defines the compress info of the linkframe data.
// 当linkframe中compress_字段为真时，使用该类压缩数据，维护解压所需的数据结构。
// 压缩后的数据结构为[header][compressed data],其中header仅存有原始数据的长度。
// 每次使用哪个必须生命不同的实例。

#ifndef BIZ_PROTOCOL_LINKFRAME_COMPRESS_H_
#define BIZ_PROTOCOL_LINKFRAME_COMPRESS_H_

#include <zlib.h>
#include "base/memory/packet.h"

namespace nimbiz
{

class CompressInfo
{
private:
    nbase::PackBuffer   buf_;       // 待压缩或解压的数据
    size_t              length_;    // 未压缩的原始数据的长度
    
public:
    CompressInfo()
    {
        length_ = 0;
    }
    
    const char * data()     { return buf_.data(); }
    size_t length() const   { return length_; }
    
    enum { kHeaderLength = 4 };
   
    // 压缩
    bool compress(const void * in, size_t in_length)
    {
        
        buf_.resize(0);
#if (ZLIB_VERNUM >= 0x1200)
        uLong buf_len = compressBound((uLong)in_length) + kHeaderLength;
#else
        uLong buf_len = in_length + in_length / 1000 + 12 + kHeaderLength;
#endif
        // allocate buffer
        buf_.reserve(buf_len);
        nbase::Pack p(buf_);
        p.push_uint32((uint32_t)in_length);
        // compress
        Byte *buf = (Byte *)(buf_.data() + p.size());
        buf_len -= (uLong)p.size();
        
        int ret = ::compress(buf, &buf_len, (Byte *)in, (uLong)in_length);
        length_ = buf_len + p.size();
        return (Z_OK == ret);
    }
    
    // 解压
    bool uncompress(const nbase::Unpack &up)
    {
        length_ = up.pop_uint32();
        buf_.reserve(length_);
        
        int ret = ::uncompress(
                               (Bytef *)buf_.data(), 
                               (uLong *)(&length_), 
                               (const Bytef *)up.data(), 
                               (uLong)up.size()
                               );
        return (Z_OK == ret);
    }
};
}


#endif // BIZ_PROTOCOL_LINKFRAME_COMPRESS_H_
