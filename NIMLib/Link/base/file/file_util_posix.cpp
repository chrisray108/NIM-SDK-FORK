// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/12
//
// Utilities for file and filepath operation

#include "file_util.h"
#include "base/util/string_util.h"

#if defined(OS_POSIX)
#include <string>
#include <vector>
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/errno.h>
#include <sys/stat.h>

namespace nbase
{

typedef struct stat stat_wrapper_t;
static int CallStat(const char *path, stat_wrapper_t *sb)
{
	return stat(path, sb);
}

bool FilePathCurrentDirectory(std::string &directory_out)
{
	char directory[512] = "";
	if (!getcwd(directory, sizeof(directory)))
	{
		return false;
	}

	directory_out = directory;
	directory_out.append(1, kFilePathSeparators[0]);
	return true;
}

bool FilePathCurrentDirectory(std::wstring &directory_out)
{
	std::string directory;
	FilePathCurrentDirectory(directory);
	UTF8ToUTF32(directory, directory_out);
	return true;
}

bool FilePathIsExist(const char *filepath_in, bool is_directory)
{
	if (!is_directory)
		return access(filepath_in, F_OK) == 0;
	else
	{
		DIR *directory = opendir(filepath_in);
		if (directory != NULL)
		{
			closedir(directory);
			return true;
		}
	}
	return false;
}

bool FilePathIsExist(const wchar_t *filepath_in, bool is_directory)
{
	std::string filepath_utf8;
	UTF32ToUTF8(filepath_in, wcslen(filepath_in), filepath_utf8);
	return FilePathIsExist(filepath_utf8, is_directory);
}

FILE* OpenFile(const char *filepath, const char *mode)
{
	FILE* file = NULL;
	do
	{
		file = fopen(filepath, mode);
	} while (!file && errno == EINTR);
	return file;
}

FILE* OpenFile(const std::wstring &filepath, const char *mode)
{
	std::string filepath_utf8;
	UTF32ToUTF8(filepath.c_str(), wcslen(filepath.c_str()), filepath_utf8);
	return OpenFile(filepath_utf8, mode);
}

int ReadFile(const char *filepath, char *data_out, int size)
{
	int fd = open(filepath, O_RDONLY);
	if (fd < 0)
		return -1;

	ssize_t bytes_read = read(fd, data_out, size);
	if (int ret = close(fd) < 0)
		return ret;
	return (int)bytes_read;
}

int ReadFile(const std::wstring &filepath, char *data_out, int size)
{
	std::string filepath_utf8;
	UTF32ToUTF8(filepath.c_str(), wcslen(filepath.c_str()), filepath_utf8);
	return ReadFile(filepath_utf8, data_out, size);
}

int WriteFile(const char *filepath, const char *data, const int size)
{
	int fd = creat(filepath, 0666);
	if (fd < 0)
		return -1;

	ssize_t bytes_written_total = 0;
	for (ssize_t bytes_written_partial = 0; bytes_written_total < size;
		bytes_written_total += bytes_written_partial)
	{
		bytes_written_partial =
			write(fd, data + bytes_written_total,
			size - bytes_written_total);
		if (bytes_written_partial < 0)
			return -1;
	}

	if (int ret = close(fd) < 0)
		return ret;

	return (int)bytes_written_total;
}

int WriteFile(const std::wstring &filepath, const std::string &data)
{
	std::string filepath_utf8;
	UTF32ToUTF8(filepath.c_str(), wcslen(filepath.c_str()), filepath_utf8);
	return WriteFile(filepath_utf8, data);
}

bool CopyFile(const std::string &from_path, const std::string &to_path)
{
	int infile = open(from_path.c_str(), O_RDONLY);
	if (infile < 0)
		return false;

	int outfile = creat(to_path.c_str(), 0666);
	if (outfile < 0)
	{
		close(infile);
		return false;
	}

	const size_t kBufferSize = 32768;
	std::vector<char> buffer(kBufferSize);
	bool result = true;

	while (result)
	{
		ssize_t bytes_read = read(infile, &buffer[0], buffer.size());
		if (bytes_read < 0)
		{
			result = false;
			break;
		}
		if (bytes_read == 0)
			break;
		// Allow for partial writes
		ssize_t bytes_written_per_read = 0;
		do 
		{
			ssize_t bytes_written_partial = write(
				outfile,
				&buffer[bytes_written_per_read],
				bytes_read - bytes_written_per_read);
			if (bytes_written_partial < 0)
			{
				result = false;
				break;
			}
			bytes_written_per_read += bytes_written_partial;
		} while (bytes_written_per_read < bytes_read);
	}

	if (close(infile) < 0)
		result = false;
	if (close(outfile) < 0)
		result = false;

	return result;
}

bool CopyFile(const std::wstring &from_path, const std::wstring &to_path)
{
	std::string from_path_utf8, to_path_utf8;
	UTF32ToUTF8(from_path.c_str(), wcslen(from_path.c_str()), from_path_utf8);
	UTF32ToUTF8(to_path.c_str(), wcslen(to_path.c_str()), to_path_utf8);
	return WriteFile(from_path_utf8, to_path_utf8);
}

bool DeleteFile(const std::string &filepath)
{
	const char* path_str = filepath.c_str();
	stat_wrapper_t file_info;
	int test = CallStat(path_str, &file_info);
	if (test != 0)
	{
		// The Windows version defines this condition as success.
		bool ret = (errno == ENOENT || errno == ENOTDIR);
		return ret;
	}
	if (!S_ISDIR(file_info.st_mode))
		return (unlink(path_str) == 0);

	return true;	
}

bool DeleteFile(const std::wstring &filepath)
{
	std::string filepath_utf8;
	UTF32ToUTF8(filepath.c_str(), wcslen(filepath.c_str()), filepath_utf8);
	return DeleteFile(filepath_utf8);
}

int64_t GetFileSize(const std::string &filepath)
{
	const char* path_str = filepath.c_str();
	stat_wrapper_t file_info;
	int test = CallStat(path_str, &file_info);
	if (test != 0)
		return -1;
	if (!S_ISDIR(file_info.st_mode))
		return file_info.st_size;
	return -1;
}

int64_t GetFileSize(const std::wstring &filepath)
{
	std::string filepath_utf8;
	UTF32ToUTF8(filepath.c_str(), wcslen(filepath.c_str()), filepath_utf8);
	return GetFileSize(filepath_utf8);
}

}  // namespace nbase

#endif  // OS_POSIX

