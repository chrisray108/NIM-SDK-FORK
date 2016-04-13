// Copyright (c) 2012, NetEase Inc. All rights reserved.
//
// Wang Rongtao <rtwang@corp.netease.com>
// 2012/2/22
//
// a thread manager for iter-thread communicatios, etc.

#ifndef BASE_THREAD_THREAD_MANAGER_H_
#define BASE_THREAD_THREAD_MANAGER_H_

#include <map>
#include "base/base_api.h"
#include "base/thread/framework_thread.h"
#include "base/synchronization/lock.h"
#include "base/memory/ref_count.h"
#include "boost/noncopyable.hpp"

namespace nbase
{
class MessageLoop;

// 使用ThreadManager可以极大地方便线程间通信
// 注意：只有受ThreadManager托管的线程（通过Register托管）才允许调用除Register外的成员函数
class ThreadManager : public ThreadSafeRefCount, public nimboost::noncopyable
{
public:
	// 托管线程
	// identifier >= 0
	// 必须在self的线程过程内被调用
	static bool RegisterThread(int self_identifier, FrameworkThread *self);
	// 取消当前线程托管
	// 线程运行结束之前必须调用UnregisterThread取消托管
	static bool UnregisterThread();

	// 查找
	static FrameworkThread* QueryThread(int identifier);
	static int QueryThreadId(const FrameworkThread *thread);

	// Task投递
	static bool PostTask(int identifier, Task *task);
	static bool PostDelayedTask(int identifier, Task *task, int64_t delay_ms);
	static bool PostNonNestableTask(int identifier, Task *task);
	static bool PostNonNestableDelayedTask(int identifier, Task *task, int64_t delay_ms);

private:
	static bool AquireAccess();

	ThreadManager() {}
	virtual ~ThreadManager() {}

	FrameworkThread* QueryThreadInternal(int identifier) const;
	MessageLoop* GetMessageLoop(int identifier) const;

	NLock lock_;
	std::map<int, FrameworkThread*> threads_;
};

}

#endif // BASE_THREAD_THREAD_MANAGER_H_
