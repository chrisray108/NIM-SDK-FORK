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
#else
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>
#endif  // OS_WIN

namespace nbase
{

const char    kEndChar  = '\0';
const char    kEndWChar = L'\0'; 
#if defined(OS_WIN)
const char    kFilePathSeparators[]  = "\\/";
const wchar_t kFilePathWSeparators[] = L"\\/";
#else
const char    kFilePathSeparators[]  = "/";
const wchar_t kFilePathWSeparators[] = L"/";
#endif  // OS_WIN
const char    kFilePathCurrentDirectory[]  = ".";
const wchar_t kFilePathWCurrentDirectory[] = L".";
const char    kFilePathParentDirectory[]   = "..";
const wchar_t kFilePathWParentDirectory[]  = L"..";
const char    kFilePathExtensionSeparator  = '.';
const wchar_t kFilePathWExtensionSeparator = L'.';

bool IsFilePathSeparator(const char separator)
{
	if (separator == kEndChar)
		return false;

	size_t len = sizeof(kFilePathSeparators)/sizeof(char);
	for (size_t i = 0; i < len; i++)
	{
		if (separator == kFilePathSeparators[i])
			return true;
	}

	return false;
}

bool IsFilePathSeparator(const wchar_t separator)
{
	if (separator == kEndWChar)
		return false;

	size_t len = sizeof(kFilePathWSeparators) / sizeof(wchar_t);
	for (size_t i = 0; i < len; i++)
	{
		if (separator == kFilePathWSeparators[i])
			return true;
	}
	return false;
}

bool IsFilePathSeparator(const std::string separator)
{
	if (separator.empty())
		return false;
	char c = separator[0];
	return IsFilePathSeparator(c);
}

bool IsFilePathSeparator(const std::wstring separator)
{
	if (separator.empty())
		return false;
	wchar_t wc = separator[0];
	return IsFilePathSeparator(wc);
}

bool FilePathExtension(const std::string &filepath_in, std::string &extension_out)
{
	size_t index = filepath_in.size() - 1;
	if (index <= 0 || filepath_in.size() == 0)
		return false;
	for (; index != 0; index--)
	{
		if (filepath_in[index] == kFilePathExtensionSeparator)
		{
			extension_out = filepath_in.substr(index, std::string::npos);
			return true;
		}
	}
	return false;
}

bool FilePathExtension(const std::wstring &filepath_in, std::wstring &extension_out)
{
	size_t index = filepath_in.size() - 1;
	if (index <= 0 || filepath_in.size() == 0)
		return false;
	for (; index != 0; index--)
	{
		if (filepath_in[index] == kFilePathWExtensionSeparator)
		{
			extension_out = filepath_in.substr(index, std::wstring::npos);
			return true;
		}
	}
	return false;
}

bool FilePathApartDirectory(const std::string &filepath_in, std::string &directory_out)
{
	size_t index = filepath_in.size() - 1;
	if (index <= 0 || filepath_in.size() == 0)
		return false;
	for (; index != 0; index--)
	{
		if (IsFilePathSeparator(filepath_in[index]))
		{
			if (index == filepath_in.size() - 1)
				directory_out = filepath_in;
			else
			    directory_out = filepath_in.substr(0, index + 1);
			return true;
		}
	}
	return false;
}

bool FilePathApartDirectory(const std::wstring &filepath_in, std::wstring &directory_out)
{
	size_t index = filepath_in.size() - 1;
	if (index <= 0 || filepath_in.size() == 0)
		return false;
	for (; index != 0; index--)
	{
		if (IsFilePathSeparator(filepath_in[index]))
		{
			if (index == filepath_in.size() - 1)
				directory_out = filepath_in;
			else
				directory_out = filepath_in.substr(0, index + 1);
			return true;
		}
	}
	return false;
}

bool FilePathApartFileName(const std::string &filepath_in, std::string &filename_out)
{
	size_t index = filepath_in.size() - 1;
	if (index <= 0 || filepath_in.size() == 0)
		return false;
	for (; index != 0; index--)
	{
		if (IsFilePathSeparator(filepath_in[index]))
		{
			if (index == filepath_in.size() - 1)
				return false;
			filename_out = filepath_in.substr(index + 1, std::string::npos);
			return true;
		}
	}	return false;
}

bool FilePathApartFileName(const std::wstring &filepath_in, std::wstring &filename_out)
{
	size_t index = filepath_in.size() - 1;
	if (index <= 0 || filepath_in.size() == 0)
		return false;
	for (; index != 0; index--)
	{
		if (IsFilePathSeparator(filepath_in[index]))
		{
			if (index == filepath_in.size() - 1)
				return false;
			filename_out = filepath_in.substr(index + 1, std::wstring::npos);
			return true;
		}
	}	return false;
}

bool FilePathCompose(const std::string &directory_in, 
	                 const std::string &filename_in, 
					 std::string &filepath_out)
{
	std::string directory;
	if (!FilePathApartDirectory(directory_in, directory))
		return false;
	filepath_out = directory + filename_in;
	return true;
}

bool FilePathCompose(const std::wstring &directory_in, 
	                 const std::wstring &filename_in, 
	                 std::wstring &filepath_out)
{
	std::wstring directory;
	if (!FilePathApartDirectory(directory_in, directory))
		return false;
	filepath_out = directory + filename_in;
	return true;
}

bool FilePathIsExist(const std::string &filepath_in, bool is_directory)
{
	return FilePathIsExist((const char *)filepath_in.c_str(), is_directory);
}

bool FilePathIsExist(const std::wstring &filepath_in, bool is_directory)
{
	return FilePathIsExist((const wchar_t *)filepath_in.c_str(), is_directory);
}

FILE* OpenFile(const std::string &filepath, const char *mode)
{
	return OpenFile(filepath.c_str(), mode);
}

bool CloseFile(FILE *file)
{
	if (NULL == file)
		return true;
	return fclose(file) == 0;
}

int ReadFile(const std::string &filepath, char *data_out, int size)
{
	return ReadFile(filepath.c_str(), data_out, size);
}

int WriteFile(const std::string &filepath, const std::string &data)
{
	return WriteFile(filepath.c_str(), const_cast<char *>(data.c_str()), (int)data.size());
}

bool ReadFileToString(const std::string &filepath, std::string &contents_out)
{
	FILE* file = OpenFile(filepath.c_str(), "rb");
	if (!file)
	{
		return false;
	}

	char buf[1 << 16];
	size_t len;
	while ((len = fread(buf, 1, sizeof(buf), file)) > 0)
	{
		contents_out.append(buf, len);
	}
	CloseFile(file);

	return true;
}

bool ReadFileToString(const std::wstring &filepath, std::string &contents_out)
{
	FILE* file = OpenFile(filepath, "rb");
	if (!file)
	{
		return false;
	}

	char buf[1 << 16];
	size_t len;
	while ((len = fread(buf, 1, sizeof(buf), file)) > 0)
	{
		contents_out.append(buf, len);
	}
	CloseFile(file);

	return true;
}

}  // namespace nbase
