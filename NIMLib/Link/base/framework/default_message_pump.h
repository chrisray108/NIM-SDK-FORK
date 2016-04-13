// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/24
//
// A implemetation a cross flatform waitable event based message loop 

#ifndef BASE_FRAMEWORK_DEFAULT_MESSAGE_PUMP_H_
#define BASE_FRAMEWORK_DEFAULT_MESSAGE_PUMP_H_

#include "base/framework/message_pump.h"
#include "boost/noncopyable.hpp"
#include "base/time/time.h"
#include "base/synchronization/waitable_event.h"

namespace nbase
{

class DefaultMessagePump : public MessagePump, public nimboost::noncopyable
{
public:
	DefaultMessagePump();
	virtual ~DefaultMessagePump() {}

	virtual void Run(Delegate* delegate);
	virtual void Quit();
	virtual void ScheduleWork();
	virtual void ScheduleDelayedWork(const TimeTicks& delay_message_time);

private:
	void Wait();
	void WaitTimeout(const TimeDelta &timeout);
	void Wakeup();

	WaitableEvent event_;
	bool should_quit;
	TimeTicks delayed_work_time_;
};

}

#endif // BASE_FRAMEWORK_DEFAULT_MESSAGE_PUMP_H_
