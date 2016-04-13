// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/14
//
// Base64 encode/decode

#ifndef BASE_UTIL_BASE64_H_
#define BASE_UTIL_BASE64_H_

#include <string>
#include "base/base_api.h"

namespace nbase
{
	/*
	 *	purpose		Encodes the input string in base64.  Returns true if successful and false
	 *              otherwise.  The output string is only modified if successful.
	 */
	BASE_API bool Base64Encode(const std::string& input, std::string* output);

	/*
	 *	purpose		Decodes the base64 input string.  Returns true if successful and false
	 *              otherwise.  The output string is only modified if successful.
	 */
	BASE_API bool Base64Decode(const std::string& input, std::string* output);

}  // namespace nbase

#endif  // BASE_UTIL_BASE64_H_
