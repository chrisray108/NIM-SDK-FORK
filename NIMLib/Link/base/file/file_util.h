// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/12
//
// Utilities for file and filepath operation

#ifndef BASE_FILE_FILE_UTIL_H_
#define BASE_FILE_FILE_UTIL_H_

#include "base/base_api.h"
#include "base/base_types.h"
#include <list>
#include <string>

namespace nbase
{
// Null-terminated array of separators used to separate components in path.
// Each character in this array is a valid separator
extern const char    kFilePathSeparators[];
extern const wchar_t kFilePathWSeparators[];
// A special path component meaning "this directory."
extern const char    kFilePathCurrentDirectory[];
extern const wchar_t kFilePathWCurrentDirectory[];
// A special path component meaning "the parent directory."
extern const char    kFilePathParentDirectory[];
extern const wchar_t kFilePathWParentDirectory[];
// The character used to identify a file extension.
extern const char    kFilePathExtensionSeparator;
extern const wchar_t kFilePathWExtensionSeparator;

/*
 *	purpose		check the character is filepath separator
 */
BASE_API bool IsFilePathSeparator(const char separator);
BASE_API bool IsFilePathSeparator(const wchar_t separator);
BASE_API bool IsFilePathSeparator(const std::string separator);
BASE_API bool IsFilePathSeparator(const std::wstring separator);

/*
 *	purpose		get the file extension from filepath
 */
BASE_API bool FilePathExtension(const std::string &filepath_in, std::string &extension_out);
BASE_API bool FilePathExtension(const std::wstring &filepath_in, std::wstring &extension_out);

/*
 *	purpose		get the directory from the whole filepath
 */
BASE_API bool FilePathApartDirectory(const std::string &filepath_in, std::string &directory_out);
BASE_API bool FilePathApartDirectory(const std::wstring &filepath_in, std::wstring &directory_out);
/*
 *	purpose		get the filename from the whole filepath
 */
BASE_API bool FilePathApartFileName(const std::string &filepath_in, std::string &filename_out);
BASE_API bool FilePathApartFileName(const std::wstring &filepath_in, std::wstring &filename_out);

/*
 *	purpose		compose the filepath from directory and filename
 */
BASE_API bool FilePathCompose(const std::string &directory_in, const std::string &filename_in, std::string &filepath_out);
BASE_API bool FilePathCompose(const std::wstring &directory_in, const std::wstring &filename_in, std::wstring &filepath_out);

/*
 *	purpose		get the current filepath
 */
BASE_API bool FilePathCurrentDirectory(std::string &directory_out);
BASE_API bool FilePathCurrentDirectory(std::wstring &directory_out);

/*
 *	purpose		check the filepath is exist
 */
BASE_API bool FilePathIsExist(const char *filepath_in, bool is_directory);
BASE_API bool FilePathIsExist(const wchar_t *filepath_in, bool is_directory);
BASE_API bool FilePathIsExist(const std::string &filepath_in, bool is_directory);
BASE_API bool FilePathIsExist(const std::wstring &filepath_in, bool is_directory);

/*
 *	purpose		Wrapper for fopen-like calls. Returns non-NULL FILE* on success
 */
BASE_API FILE* OpenFile(const char *filepath, const char *mode);
BASE_API FILE* OpenFile(const std::string &filepath, const char *mode);
BASE_API FILE* OpenFile(const std::wstring &filepath, const char *mode);

/*
 *	purpose		Closes file opened by OpenFile. Returns true on success
 */
BASE_API bool CloseFile(FILE *file);

/*
 *	purpose		Reads the given number of bytes from the file into the buffer
 */
BASE_API int ReadFile(const char *filepath, char *data_out, int size);
BASE_API int ReadFile(const std::string &filepath, char *data_out, int size);
BASE_API int ReadFile(const std::wstring &filepath, char *data_out, int size);

/*
 *	purpose		Writes the given buffer into the file
 */
BASE_API int WriteFile(const char *filepath, const char *data, const int size);
BASE_API int WriteFile(const std::string &filepath, const std::string &data);
BASE_API int WriteFile(const std::wstring &filepath, const std::string &data);

/*
 *	purpose		Copies a single file.
 */
BASE_API bool CopyFile(const std::string &from_path, const std::string &to_path);
BASE_API bool CopyFile(const std::wstring &from_path, const std::wstring &to_path);

/*
 *	purpose		Deletes the given path.
 */
BASE_API bool DeleteFile(const std::string &filepath);
BASE_API bool DeleteFile(const std::wstring &filepath);

/*
 *	purpose		Read the file at |path| into |contents|, returning true on success.
 */
BASE_API bool ReadFileToString(const std::string &filepath, std::string &contents_out);
BASE_API bool ReadFileToString(const std::wstring &filepath, std::string &contents_out);

/*
 *	purpose		Get file size.
 */
BASE_API int64_t GetFileSize(const std::string &filepath);
BASE_API int64_t GetFileSize(const std::wstring &filepath);

}  // namespace nbase

#endif  // BASE_FILE_FILE_UTIL_H_