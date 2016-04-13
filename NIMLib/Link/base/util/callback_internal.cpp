// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/9/30
//

#include "callback_internal.h"

namespace nbase
{
namespace internal
{
bool CallbackBase::is_null() const
{
	return invoker_storage_.get() == NULL;
}

void CallbackBase::Reset()
{
	invoker_storage_ = NULL;
	polymorphic_invoke_ = NULL;
}

bool CallbackBase::Equals(const CallbackBase& other) const
{
	return invoker_storage_.get() == other.invoker_storage_.get() &&
		polymorphic_invoke_ == other.polymorphic_invoke_;
}

CallbackBase::CallbackBase(InvokeFuncStorage polymorphic_invoke,
	scoped_refptr<InvokerStorageBase>* invoker_storage)
	: polymorphic_invoke_(polymorphic_invoke)
{
	if (invoker_storage)
	{
		invoker_storage_.swap(*invoker_storage);
	}
}

CallbackBase::~CallbackBase()
{
}

}  // namespace internal
}  // namespace nbase