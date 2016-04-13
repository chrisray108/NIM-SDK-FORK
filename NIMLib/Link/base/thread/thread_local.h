// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/14
//
// This file implements some useful thread local template data structures

#ifndef BASE_THREAD_THREAD_LOCAL_H_
#define BASE_THREAD_THREAD_LOCAL_H_

#include "base/base_api.h"
#if defined(OS_POSIX)
#include <pthread.h>
#endif
#include "base/macros.h"
#include "boost/noncopyable.hpp"

namespace nbase
{

namespace internal
{

struct ThreadLocalPlatform
{
#if defined(OS_WIN)
	typedef unsigned long SlotType;
#elif defined(OS_POSIX)
	typedef pthread_key_t SlotType;
#endif

	static void AllocateSlot(SlotType &slot);
	static void FreeSlot(SlotType &slot);
	static void* GetValueFromSlot(SlotType &slot);
	static void SetValueInSlot(SlotType &slot, void *value);
};

} // namespace internal

template<typename Type>
class ThreadLocalPointer : public nimboost::noncopyable
{
public:
	ThreadLocalPointer() : slot_()
	{
		internal::ThreadLocalPlatform::AllocateSlot(slot_);
	}

	~ThreadLocalPointer()
	{
		internal::ThreadLocalPlatform::FreeSlot(slot_);
	}

	Type* Get()
	{
		return static_cast<Type*>(internal::ThreadLocalPlatform::GetValueFromSlot(slot_));
	}

	void Set(Type *ptr)
	{
		internal::ThreadLocalPlatform::SetValueInSlot(slot_, ptr);
	}

private:
	typedef internal::ThreadLocalPlatform::SlotType SlotType;
	SlotType slot_;
};

class ThreadLocalBoolean : public nimboost::noncopyable
{
public:
	ThreadLocalBoolean() {}
	~ThreadLocalBoolean() {}

	bool Get()
	{
		return !!tlp_.Get();
	}

	void Set(bool val)
	{
		tlp_.Set(reinterpret_cast<void*>(val ? 1 : 0));
	}

private:
	ThreadLocalPointer<void> tlp_;
};

} // namespace nbase

#endif // BASE_THREAD_THREAD_LOCAL_H_
