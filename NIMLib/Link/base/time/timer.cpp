// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/8
//

#include "timer.h"
#include "base/framework/message_loop.h"

namespace nbase
{

void TimerBase::OrphanDelayedTask()
{
	if (delayed_task_)
	{
		delayed_task_->timer_ = NULL;
		delayed_task_ = NULL;
	}
}

void TimerBase::InitiateDelayedTask(TimerTask* timer_task)
{
	OrphanDelayedTask();

	delayed_task_ = timer_task;
	delayed_task_->timer_ = this;
	MessageLoop::current()->PostNonNestableDelayedTask(timer_task,
		static_cast<int64_t>(timer_task->delay_.ToMillisecondsRoundedUp()));
}

}  // namespace nbase
