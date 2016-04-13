// Copyright (c) 2012, NetEase Inc. All rights reserved.
//
// Wang Rongtao <rtwang@corp.netease.com>
// 2012/2/22
//
// a thread manager for iter-thread communicatios, etc.

#include "thread_manager.h"
#include <assert.h>
#include "base/framework/message_loop.h"
#include "base/third_party/chrome/atomicops.h"

#define AUTO_MAP_LOCK() NAutoLock lock(&g_instance->lock_);
#define AQUIRE_ACCESS() { if (!AquireAccess()) { assert(false); return false; } }
#define AQUIRE_INSTANCE() { if (!g_instance) g_instance = new ThreadManager; g_instance->AddRef(); }

namespace nbase
{
static nbase::subtle::Atomic32 g_instance_lock = 0;
static ThreadManager *g_instance;

static void AquireInstanceLock()
{
	// spin lock is always good here
	while (nbase::subtle::NoBarrier_CompareAndSwap(&g_instance_lock, 0, 1) != 0)
		FrameworkThread::YieldThread();
}

static void ReleaseInstanceLock()
{
	nbase::subtle::Release_Store(&g_instance_lock, 0);
}

static void ReleaseInstance()
{
	assert(g_instance);
	if (g_instance && g_instance->Release() == 0)
		g_instance = NULL;
}

bool ThreadManager::RegisterThread(int self_identifier, FrameworkThread *self)
{
	assert(self_identifier >= 0 && self);
	if (self_identifier < 0 || !self)
		return false;

	FrameworkThreadTlsData *tls = FrameworkThread::GetTlsData();
	assert(tls); // should be called by a Framework thread
	if (tls == NULL)
		return false;
	assert(tls->self == self); // must be called on thread proc of 'self'
	if (tls->self != self)
		return false;

	// ensure we have an instance
	AquireInstanceLock();
	AQUIRE_INSTANCE()
	ReleaseInstanceLock();

	AUTO_MAP_LOCK()
	std::pair<std::map<int, FrameworkThread*>::iterator, bool> pr =
		g_instance->threads_.insert(std::make_pair(self_identifier, self));
	if (!pr.second)
	{
		if (pr.first->second != self)
		{
			ReleaseInstance();
			assert(false); // another thread has registered with the same id
			return false;
		}
		// yes, it's me, check logic error
		assert(tls->managed > 0);
		assert(tls->managed_thread_id == self_identifier);
	}
	// 'self' is registered
	tls->managed++;
	tls->managed_thread_id = self_identifier;
	return true;
}

bool ThreadManager::UnregisterThread()
{
	FrameworkThreadTlsData *tls = FrameworkThread::GetTlsData();
	assert(tls); // should be called by a Framework thread
	assert(tls->managed > 0); // should be managed
	if (!tls || tls->managed < 1)
		return false;

	assert(g_instance); // logic error

	// remove from internal thread map
	// here, since tls->managed is greater than zero,
	// we must have a reference of the glabal ThreadManager instance (see RegisterThread)
	if (--tls->managed == 0)
	{
		AUTO_MAP_LOCK()
		std::map<int, FrameworkThread*>::iterator iter = g_instance->threads_.find(tls->managed_thread_id);
		if (iter != g_instance->threads_.end())
			g_instance->threads_.erase(iter);
		else
			assert(false);	// logic error, we should not come here
		tls->managed_thread_id = -1;
	}

	// Release the instance
	AquireInstanceLock();
	ReleaseInstance();
	ReleaseInstanceLock();
	return true;
}

bool ThreadManager::AquireAccess()
{
	FrameworkThreadTlsData *tls = FrameworkThread::GetTlsData();
	if (!tls || tls->managed < 1)
		return false;
	return true;
}

// no lock
FrameworkThread* ThreadManager::QueryThreadInternal(int identifier) const
{
	std::map<int, FrameworkThread*>::iterator iter = g_instance->threads_.find(identifier);
	if (iter == g_instance->threads_.end())
		return NULL;
	return iter->second;
}

FrameworkThread* ThreadManager::QueryThread(int identifier)
{
	AQUIRE_ACCESS()
	AUTO_MAP_LOCK()
	return g_instance->QueryThreadInternal(identifier);
}

int ThreadManager::QueryThreadId(const FrameworkThread *thread)
{
	AQUIRE_ACCESS()
	AUTO_MAP_LOCK()
	std::map<int, FrameworkThread*>::iterator iter;
	for (iter = g_instance->threads_.begin(); iter != g_instance->threads_.end(); iter++)
		if (iter->second == thread)
			return iter->first;
	return -1;
}

MessageLoop* ThreadManager::GetMessageLoop(int identifier) const
{
	FrameworkThread *thread = QueryThreadInternal(identifier);
	if (thread == NULL)
		return NULL;
	MessageLoop *message_loop = thread->message_loop();
	if (message_loop == NULL)
		return NULL;
	return message_loop;
}

bool ThreadManager::PostTask(int identifier, Task *task)
{
	AQUIRE_ACCESS()
	AUTO_MAP_LOCK()
	MessageLoop *message_loop = g_instance->GetMessageLoop(identifier);
	if (message_loop == NULL)
		return false;
	message_loop->PostTask(task);
	return true;
}

bool ThreadManager::PostDelayedTask(int identifier, Task *task, int64_t delay_ms)
{
	AQUIRE_ACCESS()
	AUTO_MAP_LOCK()
	MessageLoop *message_loop = g_instance->GetMessageLoop(identifier);
	if (message_loop == NULL)
		return false;
	message_loop->PostDelayedTask(task, delay_ms);
	return true;
}

bool ThreadManager::PostNonNestableTask(int identifier, Task *task)
{
	AQUIRE_ACCESS()
	AUTO_MAP_LOCK()
	MessageLoop *message_loop = g_instance->GetMessageLoop(identifier);
	if (message_loop == NULL)
		return false;
	message_loop->PostNonNestableTask(task);
	return true;
}

bool ThreadManager::PostNonNestableDelayedTask(int identifier, Task *task, int64_t delay_ms)
{
	AQUIRE_ACCESS()
	AUTO_MAP_LOCK()
	MessageLoop *message_loop = g_instance->GetMessageLoop(identifier);
	if (message_loop == NULL)
		return false;
	message_loop->PostNonNestableDelayedTask(task, delay_ms);
	return true;
}

}
