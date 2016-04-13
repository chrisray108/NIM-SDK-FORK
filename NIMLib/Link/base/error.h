// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/8
//
// This file defines error and exception

#ifndef BASE_ERROR_H_
#define BASE_ERROR_H_

#include "base_types.h"
#include <string>
#include <stdexcept>

#define          NBASE(n)          5000+n

namespace nbase
{
typedef uint32_t RESULT;

/* define error code */
const RESULT     NIMResultSuccess           = 0;
const RESULT     NIMResultFailed            = 1;      
const RESULT     NIMResultInvalidHandle     = NBASE(2);
const RESULT     NIMResultObjectNull        = NBASE(3);
const RESULT     NIMResultIOError           = NBASE(4);
const RESULT     NIMResultMemoryError       = NBASE(5);
const RESULT     NIMResultTimeout           = NBASE(6);


class BASE_API NException : public std::runtime_error
{
public:
    NException(const std::string &e) : std::runtime_error(e), error_code_(nbase::NIMResultFailed) {}
    NException(const char *s, uint32_t error_code = nbase::NIMResultFailed) 
		: std::runtime_error(s), error_code_(error_code) 
	{}
    NException() 
		: std::runtime_error((const char *)"Unknown error"), error_code_(nbase::NIMResultFailed)
	{}
    virtual ~NException() throw() {}
    uint32_t error_code() const{ return error_code_; }
private:
	uint32_t error_code_;
};

}

#endif  // BASE_ERROR_H_
