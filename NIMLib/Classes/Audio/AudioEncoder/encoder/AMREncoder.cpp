//
//  AMREncoder.cpp
//  NIM
//
//  Created by amao on 13-3-14.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#include "AMREncoder.h"
#include "amr_encoder.h"

namespace NIM {

const int kMaxOutputBufferSize   = 32;
//const int kFrameDurationMS       = 20;
//const int kSampleRate            = 8000;
const int kSamplesPerFrame       = ((8000 * 20) / 1000);
//const int kBytesPerSample        = 2;  // Assume 16-bit PCM samples
const int kBytesPerFrame         = (160 * 2);
const int kShortBufferSize       = kBytesPerFrame / 2;


AMREncoder::AMREncoder()
{
    state_ = 0;
}

AMREncoder::~AMREncoder()
{
    if (state_)
    {
        AMREncodeExit(state_);
    }
}


bool AMREncoder::Init(int sample_rate, int channels, int bitrate)
{
    state_ = AMREncodeInit(0);
    input_buffer_size_ = kSamplesPerFrame * 2;
    return state_ != 0;
}

std::vector<uint8_t>    AMREncoder::Encode(const void *data, int length)
{
    std::vector<uint8_t> output;
    if (state_)
    {
        std::vector<uint8_t>    input = reverse_;
        for (int i = 0; i < length; i++)
        {
            input.push_back(((const uint8_t *)data)[i]);
        }
        int count = (int)(input.size() / input_buffer_size_);
        for (int i = 0; i < count; i++)
        {
            uint8_t *output_buffer = 0;
            int output_size = _Encode(&input[i * input_buffer_size_], input_buffer_size_, &output_buffer);
            if (output_size > 0 && output_buffer)
            {
                for (int j =0 ; j < output_size; j++)
                {
                    output.push_back(output_buffer[j]);
                }
                delete []output_buffer;
            }
        }
        reverse_.clear();
        for (int i = count * input_buffer_size_; i < input.size(); i++)
        {
            reverse_.push_back(input[i]);
        }
    }
    
    return output;
}

int32_t AMREncoder::_Encode(const uint8_t *data, int length, uint8_t **output)
{
    if (length != kBytesPerFrame)
    {
        return -1;
    }
    uint8_t output_buffer[kMaxOutputBufferSize] = {0};
    short short_buffer[kShortBufferSize] = {0};
    for (int i = 0; i < kShortBufferSize; i++)
    {
        short value = (short)((data[i * 2] & 0xff) | ((data[i*2 + 1] & 0xff) << 8));
        short_buffer[i]= value;
    }
    int output_length = AMREncode(state_,short_buffer,output_buffer);
    if (output_length <= 0)
    {
        return -1;
    }
    *output = new uint8_t[output_length];
    memcpy(*output, output_buffer, output_length);
    return output_length;
    
}
    
}
