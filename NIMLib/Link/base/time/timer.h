// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/8
//

#ifndef BASE_TIME_TIMER_H_
#define BASE_TIME_TIMER_H_

#include "base/base_api.h"
#include "base/time/time.h"
#include "base/framework/task.h"

namespace nbase
{
//-----------------------------------------------------------------------------
// This class is an implementation detail of OneShotTimer and RepeatingTimer.
// Please do not use this class directly.
//
// This class exists to share code between BaseTimer<T> template instantiations.
//
class BASE_API TimerBase
{
 public:
    // Stops the timer.
    ~TimerBase()
	{
        OrphanDelayedTask();
    }

    // Returns true if the timer is running (i.e., not stopped).
    bool IsRunning() const
	{
        return delayed_task_ != NULL;
    }

    // Returns the current delay for this timer.  May only call this method when
    // the timer is running!
    TimeDelta GetCurrentDelay() const
    {
		if (IsRunning())
            return delayed_task_->delay_;
		else
			return TimeDelta();
    }

protected:
    TimerBase() : delayed_task_(NULL) {}

    // We have access to the timer_ member so we can orphan this task.
    class TimerTask : public Task
	{
    public:
        TimerTask(TimeDelta delay)
            : timer_(NULL),
              delay_(delay)
		{
        }
    virtual ~TimerTask() {}

    TimerBase *timer_;
    TimeDelta  delay_;
  };

  // Used to orphan delayed_task_ so that when it runs it does nothing.
  void OrphanDelayedTask();

  // Used to initiated a new delayed task.  This has the side-effect of
  // orphaning delayed_task_ if it is non-null.
  void InitiateDelayedTask(TimerTask* timer_task);

  TimerTask* delayed_task_;
};

//-----------------------------------------------------------------------------
// This class is an implementation detail of OneShotTimer and RepeatingTimer.
template <class Receiver, bool repeating>
class Timer : public TimerBase
{
public:
	typedef void (Receiver::*ReceiverMethod)();

	// Call this method to start the timer
	void Start(TimeDelta delay,
		       Receiver* receiver,
		       ReceiverMethod method)
	{
		if (IsRunning())
			return;
		InitiateDelayedTask(new TimerTask(delay, receiver, method));
	}

	// Call this method to stop the timer.  It is a no-op if the timer is not
	// running.
	void Stop()
	{
		OrphanDelayedTask();
	}

	// Call this method to reset the timer delay of an already running timer.
	void Reset()
	{
		InitiateDelayedTask(static_cast<TimerTask*>(delayed_task_)->Clone());
	}

private:
	typedef Timer<Receiver, repeating> SelfType;

	class TimerTask : public TimerBase::TimerTask
	{
	public:
		TimerTask(TimeDelta delay,
			      Receiver* receiver,
			      ReceiverMethod method)
			: TimerBase::TimerTask(delay),
			  receiver_(receiver),
			  method_(method)
		{
		}

		virtual ~TimerTask()
		{
			// This task may be getting cleared because the MessageLoop has been
			// destructed.  If so, don't leave the Timer with a dangling pointer
			// to this now-defunct task.
			ClearTimer();
		}

		virtual void Run()
		{
			if (!timer_)  // timer_ is null if we were orphaned.
				return;
			if (repeating)
				ResetTimer();
			else
				ClearTimer();
			DispatchToMethod(receiver_, method_, Tuple0());
		}

		TimerTask* Clone() const
		{
			return new TimerTask(delay_, receiver_, method_);
		}

	private:
		// Inform the Base that the timer is no longer active.
		void ClearTimer()
		{
			if (timer_)
			{
				SelfType* self = static_cast<SelfType*>(timer_);
				// It is possible that the Timer has already been reset, and that this
				// Task is old.  So, if the Timer points to a different task, assume
				// that the Timer has already taken care of properly setting the task.
				if (self->delayed_task_ == this)
					self->delayed_task_ = NULL;
				// By now the delayed_task_ in the Timer does not point to us anymore.
				// We should reset our own timer_ because the Timer can not do this
				// for us in its destructor.
				timer_ = NULL;
			}
		}

		// Inform the Base that we're resetting the timer.
		void ResetTimer()
		{
			assert(timer_);
			assert(repeating);
			SelfType* self = static_cast<SelfType*>(timer_);
			self->Reset();
		}

		Receiver* receiver_;
		ReceiverMethod method_;
	};
};

//-----------------------------------------------------------------------------
// A simple, one-shot timer.  See usage notes at the top of the file.
template <class Receiver>
class OneShotTimer : public Timer<Receiver, false> {};

//-----------------------------------------------------------------------------
// A simple, repeating timer.  See usage notes at the top of the file.
template <class Receiver>
class RepeatingTimer : public Timer<Receiver, true> {};


}

#endif  // BASE_TIME_TIMER_H_