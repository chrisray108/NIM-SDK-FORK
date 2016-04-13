//
//  AACPlusEncoder.h
//  NIM
//
//  Created by fenric on 14-9-17.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#ifndef __NIM__AACPlusEncoder__
#define __NIM__AACPlusEncoder__

#include <iostream>
#include "AudioEncoder.h"
#include "aacplus.h"

namespace NIM {

class AACPlusEncoder : public AudioEncoder
{
public:
    AACPlusEncoder();
    ~AACPlusEncoder();
public:
    virtual bool    Init(int sample_rate,int channels, int bitrate);
    virtual std::vector<uint8_t>    Encode(const void *data,int length);
private:
    int     _Encode(const void *data,
                   int length,
                   int channels,
                   uint8_t **output_array);
    
    int     GetBitrateBySampleRate(int sample_rate,int channels);
private:
    aacplusEncHandle            encoder_handler_;
    int                         input_buffer_size_;
    unsigned long               max_output_bytes_;
    int                         channels_;
    std::vector<uint8_t>        reverse_;
    
};
    
}

#endif /* defined(__NIM__AACPlusEncoder__) */
