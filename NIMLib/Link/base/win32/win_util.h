/*
 *	Author		Wang Rongtao <rtwang@corp.netease.com>
 *	Date		2011-06-14
 *	Copyright	Hangzhou, Netease Inc.
 *	Brief		Utilities for Windows applications
 */

#ifndef BASE_WIN32_WIN_UTIL_H_
#define BASE_WIN32_WIN_UTIL_H_

#include "base/base_api.h"
#if defined(OS_WIN)
#include <string>
#include <windows.h>
#include <accctrl.h>

namespace nbase
{
namespace win32
{
BASE_API std::wstring GetAppPath(HMODULE module = NULL);

BASE_API bool RunApp(const wchar_t *application, HANDLE *process = NULL);
BASE_API bool RunAppWithCommand(const wchar_t *application, const wchar_t *command, HANDLE *process = NULL);
BASE_API bool RunAppWithRedirection(const wchar_t *application, const wchar_t *command, HANDLE input, HANDLE output, HANDLE error, HANDLE *process = NULL);

BASE_API bool MinimizeProcessWorkingSize();
BASE_API bool SingletonRun(const wchar_t *application);

BASE_API bool IsVistaOrHigher();
BASE_API bool SetObjectToLowIntegrity(HANDLE hObject, SE_OBJECT_TYPE type = SE_KERNEL_OBJECT);

// the following functions are used to convert encodings between MBCS and Unicode
BASE_API bool MBCSToUnicode(const char *input, std::wstring& output, int code_page = CP_ACP);
BASE_API bool MBCSToUnicode(const std::string &input, std::wstring& output, int code_page = CP_ACP);
BASE_API bool UnicodeToMBCS(const wchar_t *input, std::string &output, int code_page = CP_ACP);
BASE_API bool UnicodeToMBCS(const std::wstring& input, std::string &output, int code_page = CP_ACP);

} // namespace win32
} // namespace nbase

#endif // OS_WIN
#endif // BASE_WIN32_WIN_UTIL_H_
