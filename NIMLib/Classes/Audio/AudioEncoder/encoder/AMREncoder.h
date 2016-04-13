//
//  AMREncoder.h
//  NIM
//
//  Created by amao on 13-3-14.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#ifndef __NIM__AMREncoder__
#define __NIM__AMREncoder__

#include <iostream>
#include "AudioEncoder.h"

namespace NIM {

class AMREncoder : public AudioEncoder
{
public:
    AMREncoder();
    ~AMREncoder();
    
    bool    Init(int sample_rate,int channels, int bitrate);
    std::vector<uint8_t>    Encode(const void *data,int length);
private:
    int32_t    _Encode(const uint8_t *data,int length,uint8_t **output);
private:
    void *state_;
    std::vector<uint8_t>    reverse_;
    int input_buffer_size_;
    
};
    
}

#endif /* defined(__NIM__AMREncoder__) */
