// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/12
//
// Log interface

#ifndef BASE_LOG_LOG_H_
#define BASE_LOG_LOG_H_

#include "base/base_types.h"
#include <string>

namespace nbase
{

class BASE_API LogInterface
{
public:
	// Flag: Determine the log header style
	enum Flag
	{
		LOG_DATE=0x01,              // "MM-DD-YYYY"
		LOG_TIME=0x02,              // "hh:mm:ss"
		LOG_TIMESTAMP=0x04,         // "MM-DD-YYYY hh:mm:ss:MsMsMs"
		LOG_FILE=0x08,              // source file
		LOG_LINE=0X10,              // line number
		LOG_SYS_CODE=0x20,          // system error code
		LOG_SYS_MSG=0x40,           // system error info
		LOG_OTYPE_DESCRIPTOR=0x100, // the output type, decide by you self
		LOG_FTYPE_ONLYONE=0x200,    // only one output file
		LOG_ONLY_LEVEL=0x400        // only output the level_ level log
	};
	// some log level define
	enum Level
	{
		LV_KER = 0, //    kernel level
		LV_ASS = 4, //    assert level
		LV_ERR = 6, //    error level
		LV_WAR = 8, //    warning level
		LV_INT = 10,//    interface level
		LV_APP = 12,//    application frame level
		LV_PRO = 14 //    procedure frame level
	};

public:
	virtual const char * Version() const = 0;
	virtual void         SetFlag(Flag flag) = 0;
	virtual void         RemoveFlag(Flag flag) = 0;
	virtual void         SetLevel(uint32_t level) = 0;
	virtual uint32_t     GetLevel() const = 0;

	virtual void         VLog(uint32_t level, const char *file, uint32_t line, const char *format, va_list args) = 0;
};

BASE_API nbase::LogInterface * Log_Creater();
    
#define DEFLOGALLOW(lv)  (lv <= nbase::Log_Creater()->GetLevel())
#define DEFLOG           DefLog
    

BASE_API void DefLog(uint32_t level, const char *file, uint32_t line, const char *format,...);

}  // namespace nbase

#endif  // BASE_LOG_LOG_H_