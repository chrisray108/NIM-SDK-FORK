//
//  AACPlusEncoder.cpp
//  NIM
//
//  Created by fenric on 14-9-17.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#include "AACPlusEncoder.h"

namespace NIM {

AACPlusEncoder::AACPlusEncoder()
{
    encoder_handler_ = 0;
}

AACPlusEncoder::~AACPlusEncoder()
{
    if (encoder_handler_) {
        aacplusEncClose(encoder_handler_);
        encoder_handler_ = 0;
    }
}

bool    AACPlusEncoder::Init(int sample_rate,int channels, int bitrate)
{
    channels_ = channels;
    
    unsigned long inputSamples = 0;
    encoder_handler_ = aacplusEncOpen(sample_rate,
                                      channels,
                                      &inputSamples,
                                      &max_output_bytes_);
    
    input_buffer_size_ = (int)(channels * 2 * inputSamples);

    aacplusEncConfiguration *cfg = aacplusEncGetCurrentConfiguration(encoder_handler_);
    cfg->sampleRate = sample_rate;
    cfg->bitRate = bitrate;
    cfg->nChannelsIn = channels;
    cfg->nChannelsOut = 1;
    cfg->bandWidth = 0;
    cfg->inputFormat = AACPLUS_INPUT_16BIT;
    cfg->outputFormat = 1;
    
    printf("aacplus setting: sampleRate=%d, bitrate=%d\n", sample_rate, bitrate);
    int ret = aacplusEncSetConfiguration(encoder_handler_, cfg);
    if (ret == 0) {
        printf("aacplus set config error: %d\n", ret);
        return false;
    }
    return true;
}

std::vector<uint8_t>    AACPlusEncoder::Encode(const void *data, int length)
{
    std::vector<uint8_t> output;
    if (encoder_handler_ && length > 0) {
        std::vector<uint8_t> input = reverse_;
        for (int i = 0; i < length; i++) {
            input.push_back(((const uint8_t *)data)[i]);
        }
        int count = (int)(input.size() / input_buffer_size_);
        for (int i = 0; i < count; i++) {
            uint8_t *output_buffer = 0;
            int output_size = _Encode(&input[i * input_buffer_size_],
                                      input_buffer_size_,
                                      channels_, &output_buffer);
            if (output_size > 0 && output_buffer) {
                for (int j = 0; j < output_size; j++) {
                   output.push_back(output_buffer[j]);
                }
                delete []output_buffer;
            }
        }
        reverse_.clear();
        for (int i = count * input_buffer_size_; i < input.size(); i++) {
            reverse_.push_back(input[i]);
        }
    }
    
    return output;
}

int AACPlusEncoder::_Encode(const void *data, int length, int channels,uint8_t
                        **output_array)
{
    if (encoder_handler_) {
        int input_size = input_buffer_size_;
        if (length < input_size) {
            return -1;
        }

        uint8_t outbuf[max_output_bytes_];
        
        int bytes = aacplusEncEncode(encoder_handler_,
                                     (int32_t *) data,
                                     input_size/2,
                                     outbuf,
                                     (unsigned int)max_output_bytes_);
        if (bytes > 0) {
            *output_array = new uint8_t[bytes];
            memcpy(*output_array, outbuf, bytes);
        }
        return bytes;
    }
    else {
        return 0;
    }
}

}
