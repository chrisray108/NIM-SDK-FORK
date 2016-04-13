// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/12
//
// Log implementation

#ifndef BASE_LOG_LOG_IMPL_H_
#define BASE_LOG_LOG_IMPL_H_

#include "base/log/log.h"
#include <string>

namespace nbase
{
class Log_Impl : public nbase::LogInterface
{
public:
	Log_Impl();
	Log_Impl(const char *path);
	Log_Impl(int fd);
	virtual ~Log_Impl() {}

	const char * Version() const
	{
		return (const char *)"nbase::Log_Impl::1.0";
	}
	void SetFlag(Flag flag)
	{
		if (flag & LOG_OTYPE_DESCRIPTOR)
			return;
		flags_ |= flag;
	}
	void RemoveFlag(Flag flag)
	{
		if (flag & LOG_OTYPE_DESCRIPTOR)
			return;
		flags_ &= flag ^ 0xffffffff;
	}
	inline void SetLevel(uint32_t level)
	{
		level_ = level;
	}
	inline uint32_t GetLevel() const
	{
		return level_;
	}
	
	void VLog(uint32_t level, const char *file, uint32_t line, const char *format, va_list args);

protected:
	uint32_t          flags_;           // format flags

private:
	std::string       CreateHeader(const char *file = 0, int32_t line = -1);
	uint32_t          level_;           // debug level

};


}  // namespace nbase

#endif  // BASE_LOG_LOG_IMPL_H_

