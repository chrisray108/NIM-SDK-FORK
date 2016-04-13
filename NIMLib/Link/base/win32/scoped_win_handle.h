/*
 *
 *	Author		Wang Rongtao <rtwang@corp.netease.com>
 *	Date		2011-06-08
 *	Copyright	Hangzhou, Netease Inc.
 *	Brief		a implementation of scoped handle which ensures the safe use of Windows handles
 *
 */

#ifndef BASE_WIN32_SCOPED_WIN_HANDLE_H_
#define BASE_WIN32_SCOPED_WIN_HANDLE_H_

#include "base/base_api.h"
#if defined(OS_WIN)
#include <windows.h>
#include "third_party/boost/noncopyable.hpp"

namespace nbase
{
namespace win32
{

class BASE_API ScopedWinHandle : public boost::noncopyable
{
public:

	ScopedWinHandle() : handle_(INVALID_HANDLE_VALUE) {}
	ScopedWinHandle(HANDLE handle) : handle_(handle) {}
	~ScopedWinHandle() { Reset(INVALID_HANDLE_VALUE); }

	bool Valid() const { return handle_ != INVALID_HANDLE_VALUE; }
	HANDLE Get() const { return handle_; }
	HANDLE Release() { HANDLE old_handle = handle_; handle_ = INVALID_HANDLE_VALUE; return old_handle; }
	void Reset(HANDLE handle) { if (Valid()) ::CloseHandle(handle_); handle_ = handle; }
	operator HANDLE() const { return handle_; }

private:

	HANDLE handle_;
};

} // namespace win32
} // namespace nbase

#endif // OS_WIN
#endif // BASE_WIN32_SCOPED_WIN_HANDLE_H_
