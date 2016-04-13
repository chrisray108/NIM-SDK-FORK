// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/11/17
//
// eim task base, handle NException

#ifndef BIZ_CORE_EIM_TASK_H_
#define BIZ_CORE_EIM_TASK_H_

#include "base/framework/task.h"
#include "base/error.h"
#include "base/log/log.h"
#include "core_task_id_generator.h"

namespace nimbiz
{

class YixinTask
{
    class RealTask;
public:
    YixinTask()
    {
        task_ = new RealTask(this);
        task_id_ = GenerateCoreTaskID();
    }
    virtual ~YixinTask()
    {
        if (task_)
        {
            task_->handler_ = NULL;
            delete task_;
        }

    }
    virtual void Release() { delete this; }
    
    virtual void Run() = 0;
    virtual void OnException(const nbase::NException *e)
    {
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "errcode: %d, error msg: %s", e->error_code(), e->what());
    }
    
public:
    nbase::Task     *GetTask() { return task_; }
    int32_t         GetTaskId() {return task_id_;}
private:
    int32_t         task_id_;
    RealTask    *task_;
    
private:
    class RealTask : public nbase::Task
    {
    public:
        RealTask(YixinTask *handler) : handler_(handler) {}
        ~RealTask()
        {
            if (handler_)
            {
                handler_->task_ = NULL;
                handler_->Release();
                handler_ = 0;
            }

        }
        
        virtual void Run()
        {
            try 
            {
                handler_->Run();
            } 
            catch (nbase::NException e)
            {
                handler_->OnException(&e);
            }
            catch (std::runtime_error e)
            {
                nbase::NException ne = nbase::NException(e.what());
                handler_->OnException(&ne);
            }
            catch (...)
            {
                nbase::NException e = nbase::NException("Task Run exception, runtime error");
                handler_->OnException(&e);
            }
        }
        
        YixinTask *handler_;
    };
    
};

}


#endif // BIZ_CORE_EIM_TASK_H_
