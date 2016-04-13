//
//  AudioEncoder.h
//  NIM
//
//  Created by amao on 13-3-14.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#ifndef NIM_AudioEncoder_h
#define NIM_AudioEncoder_h

#include <vector>

namespace NIM {

class AudioEncoder
{
public:
    virtual bool    Init(int sample_rate,int channels, int bitrate) = 0;
    virtual std::vector<uint8_t>    Encode(const void *data,int length) = 0;
    virtual ~AudioEncoder() {}
};

}
#endif
