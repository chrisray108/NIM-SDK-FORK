// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/8
//
// a implementation of scoped handle which ensures the safe use of stardard handles

#ifndef BASE_MEMORY_SCOPED_STD_HANDLE_H_
#define BASE_MEMORY_SCOPED_STD_HANDLE_H_

#include "base/base_api.h"
#include <stdio.h>
#include "third-party/boost/noncopyable.hpp"

namespace nbase
{

class BASE_API ScopedStdHandle : public boost::noncopyable
{
public:

	ScopedStdHandle(): handle(NULL) {}
	ScopedStdHandle(FILE *handle) : handle_(handle) {}
	~ScopedStdHandle() { Reset(NULL); }

	bool Valid() const { return handle_ != NULL; }
	FILE* Get() const { return handle_; }
	FILE* Release() { FILE *old_handle = handle_; handle_ = NULL; return old_handle; }
	void Reset(FILE *handle) { if (Valid()) fclose(handle_); handle_ = handle; }
	operator FILE *() const { return handle_; }

private:

	FILE *handle_;
};

} // namespace

#endif // BASE_MEMORY_SCOPED_STD_HANDLE_H_
