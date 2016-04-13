/*
 *	Author		Wang Rongtao <rtwang@corp.netease.com>
 *	Date		2011-06-14
 *	Copyright	Hangzhou, Netease Inc.
 *	Brief		Utilities for Windows applications
 */

#include "base/win32/win_util.h"
#if defined(OS_WIN)
#include <assert.h>
#include <stdlib.h>
#include <string>
#include <aclapi.h> // ConvertStringSecurityDescriptorToSecurityDescriptorW
#include <sddl.h>	// SetSecurityInfo

static const wchar_t kLowIntegeritySddlSaclW[] = L"S:(ML;;NW;;;LW)";

namespace nbase
{
namespace win32
{
std::wstring GetAppPath(HMODULE module)
{
	std::wstring result;
	result.resize(MAX_PATH);
	result.resize(::GetModuleFileName(module, &result[0], result.size()));
	size_t pos = result.find_last_of(L'\\');
	result.erase(pos + 1);
	return result;
}

bool RunApp(const wchar_t *application, HANDLE *process)
{
	return RunAppWithRedirection(application, NULL, NULL, NULL, NULL, process);
}

bool RunAppWithCommand(const wchar_t *application, const wchar_t *command, HANDLE *process)
{
	return RunAppWithRedirection(application, command, NULL, NULL, NULL, process);
}

bool RunAppWithRedirection(const wchar_t *application,
						   const wchar_t *command,
						   HANDLE input,
						   HANDLE output,
						   HANDLE error,
						   HANDLE *process)
{
	PROCESS_INFORMATION pi;
	STARTUPINFOW si;

	memset(&si, 0, sizeof(si));

	if (!!input || !!output || !!error)
		si.dwFlags = STARTF_USESTDHANDLES;

	si.cb			= sizeof(si);
	si.hStdInput	= input ? input : ::GetStdHandle(STD_INPUT_HANDLE);
	si.hStdOutput	= output ? output : ::GetStdHandle(STD_OUTPUT_HANDLE);
	si.hStdError	= error ? error : ::GetStdHandle(STD_ERROR_HANDLE);

	wchar_t *command_dup = wcsdup(command);

	if (::CreateProcessW(application,
						command_dup,
						NULL,
						NULL,
						FALSE,
						CREATE_NO_WINDOW,
						NULL,
						NULL,
						&si,
						&pi))
	{
		::CloseHandle(pi.hThread);
		if (process == NULL)
			::CloseHandle(pi.hProcess);
		else
			*process = pi.hProcess;
		free(command_dup);
		return true;
	}

	free(command_dup);
	return false;
}

bool MinimizeProcessWorkingSize()
{
	OSVERSIONINFOW osvi;
	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);

	::GetVersionExW(&osvi);
	if(osvi.dwPlatformId == VER_PLATFORM_WIN32_NT)
	{
		::SetProcessWorkingSetSize(GetCurrentProcess(), -1, -1);
		return true;
	}

	return false;
}

bool SingletonRun(const wchar_t *application)
{
	assert(application);
	if (application == NULL)
		return false;

	HANDLE hMutex = ::CreateMutexW(NULL, TRUE, application);

	if (hMutex == NULL)
		return false;

	if (::GetLastError() == ERROR_ALREADY_EXISTS)
	{
		::CloseHandle(hMutex);
		return false;
	}

	/* 从此这个互斥信号量就被不受控地打开了，直到进程退出 */
	return true;
}

bool IsVistaOrHigher()
{
	OSVERSIONINFO os_version = {0};
	os_version.dwOSVersionInfoSize = sizeof(os_version);
	GetVersionEx(&os_version);
	return os_version.dwMajorVersion >= 6;
}

bool SetObjectToLowIntegrity(HANDLE hObject, SE_OBJECT_TYPE type /*= SE_KERNEL_OBJECT*/)
{
	if(!IsVistaOrHigher())
		return true;

	bool bRet = false;
	DWORD dwErr = ERROR_SUCCESS;
	PSECURITY_DESCRIPTOR pSD = NULL;
	PACL pSacl = NULL;
	BOOL fSaclPresent = FALSE;
	BOOL fSaclDefaulted = FALSE;

	if (ConvertStringSecurityDescriptorToSecurityDescriptorW(kLowIntegeritySddlSaclW, SDDL_REVISION_1, &pSD, NULL))
	{
		if (GetSecurityDescriptorSacl(pSD, &fSaclPresent, &pSacl, &fSaclDefaulted))
		{
			dwErr = SetSecurityInfo(hObject, type, LABEL_SECURITY_INFORMATION, NULL, NULL, NULL, pSacl);
			bRet = (ERROR_SUCCESS == dwErr);
		}
		LocalFree(pSD);
	}
	return bRet;
}

bool MBCSToUnicode(const char *input, std::wstring& output, int code_page)
{
	output.clear();
	int length = ::MultiByteToWideChar(code_page, 0, input, -1, NULL, 0);
	if (length <= 0)
		return false;
	output.resize(length-1);
	::MultiByteToWideChar(code_page,
						  0,
						  input,
						  -1,
						  &output[0],
						  static_cast<int>(output.size()));
	return true;
}

bool MBCSToUnicode(const std::string &input, std::wstring& output, int code_page)
{
	output.clear();
	int length = ::MultiByteToWideChar(code_page, 0, input.c_str(), static_cast<int>(input.size()), NULL, 0);
	output.resize(length);
	::MultiByteToWideChar(code_page,
						  0,
						  input.c_str(),
						  static_cast<int>(input.size()),
						  &output[0],
						  static_cast<int>(output.size()));
	return true;
}

bool UnicodeToMBCS(const wchar_t *input, std::string &output, int code_page)
{
	output.clear();
	int length = ::WideCharToMultiByte(code_page, 0, input, -1, NULL, 0, NULL, NULL);
	if (length <= 0)
		return false;
	output.resize(length-1);
	::WideCharToMultiByte(code_page,
						  0,
						  input,
						  length-1,
						  &output[0],
						  static_cast<int>(output.size()),
						  NULL,
						  NULL);
	return true;
}

bool UnicodeToMBCS(const std::wstring& input, std::string &output, int code_page)
{
	output.clear();
	int length = ::WideCharToMultiByte(code_page, 0, input.c_str(), static_cast<int>(input.size()), NULL, 0, NULL, NULL);
	output.resize(length);
	::WideCharToMultiByte(code_page,
						  0,
						  input.c_str(),
						  static_cast<int>(input.size()),
						  &output[0],
						  static_cast<int>(output.size()),
						  NULL,
						  NULL);
	return true;
}

} // namespace win32
} // namespace nbase

#endif // OS_WIN
