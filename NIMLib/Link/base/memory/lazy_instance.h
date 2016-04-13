// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/20
//
// The LazyInstance<Type> class manages a single instance of Type,
// which will be lazily created on the first time it's accessed

#ifndef BASE_MEMORY_LAZY_INSTANCE_H_
#define BASE_MEMORY_LAZY_INSTANCE_H_

#include "base/base_api.h"
#include "base/third_party/chrome/atomicops.h"
#include "boost/noncopyable.hpp"
#include "base/thread/thread.h"

namespace nbase
{

template<typename Type>
class LazyInstance : public nimboost::noncopyable
{
public:
	LazyInstance() : instance_(NULL)
	{
		nbase::subtle::Acquire_Store(&state_, kNone);
	}

	~LazyInstance()
	{
		if (instance_)
		{
			delete instance_;
			instance_ = NULL;
		}
		nbase::subtle::Release_Store(&state_, kNone);
	}

	Type& Get()
	{
		return *Pointer();
	}

	Type* Pointer()
	{
		if (nbase::subtle::Acquire_Load(&state_) != kCreated)
		{
			nbase::subtle::Atomic32 state = nbase::subtle::NoBarrier_CompareAndSwap(&state_, kNone, kCreating);
			if (state == kNone)
			{
				// we take the chance to create the instance
				instance_ = new Type();
				nbase::subtle::Release_Store(&state_, kCreated);
			}
			else if (state != kCreated)
			{
				// wait, util another thread created the instance
				while (nbase::subtle::Acquire_Load(&state_) != kCreated)
					Thread::YieldThread();
			}
		}

		return instance_;
	}

	bool operator ==(Type *object) const
	{
		switch (nbase::subtle::NoBarrier_Load(&state_))
		{
		case kNone:
			return object == NULL;
		case kCreating:
		case kCreated:
			return instance_ == object;
		default:
			return false;
		}
	}

private:
	enum
	{
		kNone = 0,
		kCreating,
		kCreated,
		kDeleting,
	};

	Type *instance_;
	nbase::subtle::Atomic32 state_;
};

}

#endif // BASE_MEMORY_LAZY_INSTANCE_H_
