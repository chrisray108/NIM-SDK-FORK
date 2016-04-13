//
//  frequency_controller.h
//  NIM
//
//  Created by amao on 1/14/14.
//  Copyright (c) 2014 Netease. All rights reserved.
//

#ifndef BIZ_CORE_FREQUENCY_CONTROLLER_H
#define BIZ_CORE_FREQUENCY_CONTROLLER_H

#include "document.h"

namespace nimbiz
{

struct YXFrequency
{
    YXFrequency()
    {
        last_request_time_ = 0;
        request_times_ = 0;
        log_ = false;
    }
    
    int32_t last_request_time_;
    int32_t request_times_;
    bool    log_;
};

class FrequencyController
{
public:
    bool    IsRequestFrequencyAcceptable(const UTF8String &key);
private:
    std::map<UTF8String, YXFrequency>   frequency_;
};
    
}

#endif
