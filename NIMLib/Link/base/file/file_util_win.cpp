// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/12
//
// Utilities for file and filepath operation

#include "file_util.h"
#include "base/util/string_util.h"

#if defined(OS_WIN)
#include <windows.h>
#include "base/win32/scoped_win_handle.h"

namespace nbase
{
bool FilePathCurrentDirectory(std::string &directory_out)
{
	char directory[MAX_PATH];
	directory[0] = 0;
	DWORD len = ::GetCurrentDirectoryA(MAX_PATH, directory);
	if (len == 0 || len > MAX_PATH)
	{
		return false;
	}
	directory_out = directory;
	directory_out.append(1, kFilePathSeparators[0]);

	return true;
}

bool FilePathCurrentDirectory(std::wstring &directory_out)
{
	wchar_t directory[MAX_PATH];
	directory[0] = 0;
	DWORD len = ::GetCurrentDirectoryW(MAX_PATH, directory);
	if (len == 0 || len > MAX_PATH)
	{
		return false;
	}
	directory_out = directory;
	directory_out.append(1, kFilePathSeparators[0]);

	return true;
}

bool FilePathIsExist(const char *filepath_in, bool is_directory)
{
	const DWORD file_attr = ::GetFileAttributesA(filepath_in);
	if (file_attr != INVALID_FILE_ATTRIBUTES)
	{
		if (is_directory)
			return (file_attr & FILE_ATTRIBUTE_DIRECTORY) != 0;
		else
			return true;
	}
	return false;
}

bool FilePathIsExist(const wchar_t *filepath_in, bool is_directory)
{
	const DWORD file_attr = ::GetFileAttributesW(filepath_in);
	if (file_attr != INVALID_FILE_ATTRIBUTES)
	{
		if (is_directory)
			return (file_attr & FILE_ATTRIBUTE_DIRECTORY) != 0;
		else
			return true;
	}
	return false;
}

FILE* OpenFile(const char *filepath, const char *mode)
{
	return _fsopen(filepath, mode, _SH_DENYNO);
}

FILE* OpenFile(const std::wstring &filepath, const char *mode)
{
	std::wstring wmode;
	UTF8ToUTF16(std::string(mode), wmode);
	return _wfsopen(filepath.c_str(), wmode.c_str(), _SH_DENYNO);
}

int ReadFile(const char *filepath, char *data_out, int size)
{
	win32::ScopedWinHandle file(CreateFileA(filepath,
		                                    GENERIC_READ,
		                                    FILE_SHARE_READ | FILE_SHARE_WRITE,
		                                    NULL,
		                                    OPEN_EXISTING,
		                                    FILE_FLAG_SEQUENTIAL_SCAN,
		                                    NULL));
	if (!file)
		return -1;

	DWORD read;
	if (::ReadFile(file, data_out, size, &read, NULL) &&
		static_cast<int>(read) == size)
		return read;
	return -1;
}

int ReadFile(const std::wstring &filepath, char *data_out, int size)
{
	win32::ScopedWinHandle file(CreateFileW(filepath.c_str(),
		                                    GENERIC_READ,
		                                    FILE_SHARE_READ | FILE_SHARE_WRITE,
		                                    NULL,
		                                    OPEN_EXISTING,
		                                    FILE_FLAG_SEQUENTIAL_SCAN,
		                                    NULL));
	if (!file)
		return -1;

	DWORD read;
	if (::ReadFile(file, data_out, size, &read, NULL) &&
		static_cast<int>(read) == size)
		return read;
	return -1;
}

int WriteFile(const char *filepath, const char *data, const int size)
{
	win32::ScopedWinHandle file(CreateFileA(filepath,
		                        GENERIC_WRITE,
		                        0,
		                        NULL,
		                        CREATE_ALWAYS,
		                        0,
		                        NULL));
	if (!file)
		return -1;

	DWORD written;
	BOOL result = ::WriteFile(file, data, size, &written, NULL);
	if (result && static_cast<int>(written) == size)
		return written;

	return -1;
}

int WriteFile(const std::wstring &filepath, const std::string &data)
{
	win32::ScopedWinHandle file(CreateFileW(filepath.c_str(),
		                                    GENERIC_WRITE,
		                                    0,
		                                    NULL,
		                                    CREATE_ALWAYS,
		                                    0,
		                                    NULL));
	if (!file)
		return -1;

	DWORD written;
	BOOL result = ::WriteFile(file, data.data(), data.size(), &written, NULL);
	if (result && static_cast<int>(written) == data.size())
		return written;

	return -1;
}

bool CopyFile(const std::string &from_path, const std::string &to_path)
{
	if (from_path.size() >= MAX_PATH ||
		to_path.size() >= MAX_PATH) {
			return false;
	}
	return (::CopyFileA(from_path.c_str(), to_path.c_str(),
		false) != 0);
}

bool CopyFile(const std::wstring &from_path, const std::wstring &to_path)
{
	if (from_path.size() >= MAX_PATH ||
		to_path.size() >= MAX_PATH) {
			return false;
	}
	return (::CopyFileW(from_path.c_str(), to_path.c_str(),
		false) != 0);
}

bool DeleteFile(const std::string &filepath)
{
	if (::DeleteFileA(filepath.c_str()) != 0)
		return true;
	return false;
}

bool DeleteFile(const std::wstring &filepath)
{
	if (::DeleteFileW(filepath.c_str()) != 0)
		return true;
	return false;
}

int64_t GetFileSize(const std::string &filepath)
{
	WIN32_FIND_DATAA file_data;
	HANDLE file = FindFirstFileA(filepath.c_str(), &file_data);

	if (file == INVALID_HANDLE_VALUE)
		return -1;
	LARGE_INTEGER li = { file_data.nFileSizeLow, file_data.nFileSizeHigh };
	FindClose(file);
	return li.QuadPart;
}

int64_t GetFileSize(const std::wstring &filepath)
{
	WIN32_FIND_DATAW file_data;
	HANDLE file = FindFirstFileW(filepath.c_str(), &file_data);

	if (file == INVALID_HANDLE_VALUE)
		return -1;
	LARGE_INTEGER li = { file_data.nFileSizeLow, file_data.nFileSizeHigh };
	FindClose(file);
	return li.QuadPart;
}

}  // namespace nbase

#endif  // OS_WIN

