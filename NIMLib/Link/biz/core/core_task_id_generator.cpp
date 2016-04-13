//
//  core_task_id_generator.cpp
//  NIMLib
//
//  Created by amao on 3/2/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#include "core_task_id_generator.h"

namespace nimbiz
{

TaskIDGenerator::TaskIDGenerator()
{
    task_id_ = 0;
    serial_id_ = 0;
}

TaskIDGenerator *TaskIDGenerator::SharedInstance()
{
    static TaskIDGenerator instance;
    return &instance;
}

int32_t TaskIDGenerator::GenerateTaskID()
{
    int32_t task_id = 0;
    nbase::NAutoLock auto_lock(&lock_);
    task_id_ ++;
    task_id = task_id_;
    return task_id;
}
    
uint16_t TaskIDGenerator::GenerateSerialID()
{
    uint16_t serial = 0;
    nbase::NAutoLock auto_lock(&lock_);
    serial_id_++;
    if (serial_id_ == 0)
    {
        serial_id_++;
    }
    serial = serial_id_;
    return serial;
}


int32_t GenerateCoreTaskID()
{
    return TaskIDGenerator::SharedInstance()->GenerateTaskID();
}
    
uint16_t GenerateSerialID()
{
    return TaskIDGenerator::SharedInstance()->GenerateSerialID();
}

}