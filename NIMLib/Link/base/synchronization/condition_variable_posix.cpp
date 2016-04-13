// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/30
//
// Condition variable implementation on posix

#include "base/synchronization/condition_variable.h"

#if defined(OS_POSIX)

#include <errno.h>
#include <sys/time.h>

#include "base/synchronization/lock.h"
#include "base/time/time.h"

namespace nbase
{

ConditionVariable::ConditionVariable(NLock *user_lock)
	: user_mutex_(user_lock->os_lock())
{
	pthread_cond_init(&condition_, NULL);
}

ConditionVariable::~ConditionVariable()
{
	pthread_cond_destroy(&condition_);
}

void ConditionVariable::Wait()
{
	pthread_cond_wait(&condition_, user_mutex_);
}

void ConditionVariable::TimedWait(const TimeDelta& max_time)
{
	int64_t usecs = max_time.ToMicroseconds();

	// The timeout argument to pthread_cond_timedwait is in absolute time.
	struct timeval now;
	gettimeofday(&now, NULL);

	struct timespec abstime;
	abstime.tv_sec = now.tv_sec + (usecs / Time::kMicrosecondsPerSecond);
	abstime.tv_nsec = (now.tv_usec + (usecs % Time::kMicrosecondsPerSecond)) *
		Time::kNanosecondsPerMicrosecond;
	abstime.tv_sec += abstime.tv_nsec / Time::kNanosecondsPerSecond;
	abstime.tv_nsec %= Time::kNanosecondsPerSecond;

	pthread_cond_timedwait(&condition_, user_mutex_, &abstime);
}

void ConditionVariable::Broadcast()
{
	pthread_cond_broadcast(&condition_);
}

void ConditionVariable::Signal()
{
	pthread_cond_signal(&condition_);
}

}  // namespace nbase

#endif  // OS_POSIX

