//
//  frequency_controller.cpp
//  NIM
//
//  Created by amao on 1/14/14.
//  Copyright (c) 2014 Netease. All rights reserved.
//

#include "frequency_controller.h"
#include <cmath>
#include "base/time/time.h"

namespace nimbiz
{

#define kMaxRequestTimes        (30)    //最大请求次数
#define kMinRequestDuration     (15)    //最短请求间隔

bool    FrequencyController::IsRequestFrequencyAcceptable(const UTF8String &key)
{
    if (key.empty())
    {
        return false;
    }
    
    std::map<UTF8String, YXFrequency>::iterator it = frequency_.find(key);
    if (it == frequency_.end())
    {
        YXFrequency fre;
        fre.last_request_time_ = (int32_t)nbase::Time::Now().ToTimeT();
        fre.request_times_ = 1;
        
        frequency_[key] = fre;
        
        return true;
    }
    else
    {
        YXFrequency &fre = frequency_[key];
        bool accepted = false;
        if (fre.request_times_ <= kMaxRequestTimes)
        {
            int32_t now = (int32_t)nbase::Time::Now().ToTimeT();
            if (abs(now - fre.last_request_time_) >= kMinRequestDuration)
            {
                fre.last_request_time_ = now;
                fre.request_times_++;
                accepted = true;
            }
        }
        else
        {
            if (!fre.log_)
            {
                fre.log_ = true;
                DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Too Many Request For %s",key.c_str());
            }
            
        }
        return accepted;
        
    }
    
}

}