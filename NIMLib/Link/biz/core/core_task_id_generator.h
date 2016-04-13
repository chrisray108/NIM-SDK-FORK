//
//  core_task_id_generator.h
//  NIMLib
//
//  Created by amao on 3/2/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef __NIMLib__core_task_id_generator__
#define __NIMLib__core_task_id_generator__

#include "base/synchronization/lock.h"

namespace nimbiz
{

class TaskIDGenerator
{
public:
    static  TaskIDGenerator *SharedInstance();
public:
    TaskIDGenerator();
    int32_t GenerateTaskID();       
    uint16_t GenerateSerialID();
    
private:
    nbase::NLock    lock_;
    int32_t         task_id_;
    uint16_t        serial_id_;
};


int32_t GenerateCoreTaskID();
uint16_t GenerateSerialID();
    
}

#endif /* defined(__NIMLib__core_task_id_generator__) */
