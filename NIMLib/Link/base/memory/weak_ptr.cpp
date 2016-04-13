// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/9/30
//

#include "base/memory/weak_ptr.h"

namespace nbase
{
namespace internal
{

WeakReference::Flag::Flag()
	: is_valid_(true)
{
}

void WeakReference::Flag::Invalidate()
{
  // The flag being invalidated with a single ref implies that there are no
  // weak pointers in existence. Allow deletion on other thread in this case.
  is_valid_ = false;
}

bool WeakReference::Flag::IsValid() const
{
  return is_valid_;
}

WeakReference::Flag::~Flag()
{
}

WeakReference::WeakReference()
{
}

WeakReference::WeakReference(Flag* flag)
	: flag_(flag)
{
}

WeakReference::~WeakReference()
{
}

bool WeakReference::is_valid() const
{
  return flag_ && flag_->IsValid();
}

WeakReferenceOwner::WeakReferenceOwner()
{
}

WeakReferenceOwner::~WeakReferenceOwner()
{
    Invalidate();
}

WeakReference WeakReferenceOwner::GetRef() const
{
    // We also want to reattach to the current thread if all previous references
    // have gone away.
    if (!HasRefs())
        flag_ = new WeakReference::Flag();
    return WeakReference(flag_);
}

void WeakReferenceOwner::Invalidate()
{
	if (flag_)
	{
	    flag_->Invalidate();
	    flag_ = NULL;
	}
}

WeakPtrBase::WeakPtrBase()
{
}

WeakPtrBase::~WeakPtrBase()
{
}

WeakPtrBase::WeakPtrBase(const WeakReference& ref)
	: ref_(ref)
{
}

}  // namespace internal
}  // namespace nbase