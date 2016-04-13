// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/12
//
// Log implementation

#include "log_impl.h"
#include "base/util/string_util.h"
#include "base/file/file_util.h"
#include "base/time/time.h"

#if defined(OS_WIN)
#include <io.h>
#else
#include <unistd.h>
#include <string.h>
#endif  // OS_WIN

#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <stdarg.h>
#include "ios_log_helper.h"


namespace nbase
{

nbase::LogInterface *kSystemLog = 0;

#if defined(OS_WIN)
const char kFileLineBreak[] = "\r\n";
#else
const char kFileLineBreak[] = "\n";
#endif

nbase::LogInterface * Log_Creater()
{
	if (kSystemLog == 0)
		kSystemLog = new Log_Impl();
	return kSystemLog;
}

    
void DefLog(uint32_t level, const char *file, uint32_t line, const char *format,...)
{
	if (level <= nbase::Log_Creater()->GetLevel())
	{
        va_list args;
        va_start(args, format);
        nbase::Log_Creater()->VLog(level, file, line,format,args);
        va_end(args);
	}
}

// Log_Impl ------------------------------------------------------
nbase::Log_Impl::Log_Impl()
	: flags_(nbase::LogInterface::LOG_DATE |
             nbase::LogInterface::LOG_TIME |
             nbase::LogInterface::LOG_TIMESTAMP |
             nbase::LogInterface::LOG_FILE |
             nbase::LogInterface::LOG_LINE )
    {
      level_    = 0;
}


void nbase::Log_Impl::VLog(uint32_t level, const char *file, uint32_t line, const char *format, va_list args)
{
	if (level > level_)
		return;
    

    
    char buffer[2048];
    vsnprintf(buffer, sizeof(buffer), format, args);

    std::string log_content = CreateHeader(file, line);
    log_content += buffer;

    nbase::Log2File(log_content);
    

}

//  Format : "[MM-DD-YYYY hh:mm:ss:msec](level:level file:file line:line)<SYS_ERRNO:SYS_ERRMSG>"
std::string nbase::Log_Impl::CreateHeader(const char *file, int32_t line)
{
    if (file == 0)
    {
        return "";
    }

    uint32_t    flags = flags_;
    std::string header;
	std::string buff;
    //    Time and Date
    if (flags & (nbase::LogInterface::LOG_DATE|nbase::LogInterface::LOG_TIME|nbase::LogInterface::LOG_TIMESTAMP))
    {
		nbase::Time::TimeStruct ts = nbase::Time::Now().ToTimeStruct(true);
        if (flags & nbase::LogInterface::LOG_TIMESTAMP)
        {
			nbase::StringPrintf(buff, "[%04d-%02d-%02d %02d:%02d:%02d:%03d]",
				                ts.year(), ts.month(), ts.day_of_month(),
								ts.hour(), ts.minute(), ts.second(), ts.millisecond());
			header += buff;
        }
        else
        {
			header += (const char *)"[";
			if (flags & nbase::LogInterface::LOG_DATE)
			{
				nbase::StringPrintf(buff, "%04d-%02d-%02d",
					ts.year(), ts.month(), ts.day_of_month());
				header += buff;
			}
			if (flags & nbase::LogInterface::LOG_TIME)
			{
				if (flags & nbase::Log_Impl::LOG_DATE)
					header += (const char *)" ";
				nbase::StringPrintf(buff, "%02d:%02d:%02d",
					ts.hour(), ts.minute(), ts.second());
				header += buff;
			}
			header += (const char *)"]";
        }
    }
    //    filename and line number
    if (file)
	{
        if (flags & nbase::LogInterface::LOG_FILE)
        {
			std::string filename;
			nbase::FilePathApartFileName(file, filename);
			nbase::StringPrintf(buff, " file:%s", filename.c_str());
            header += buff;
        }
        if (flags & nbase::LogInterface::LOG_LINE)
        {
			nbase::StringPrintf(buff, " line: %d", line);
			header += buff;
        }
    }
    header += (const char *)")";

    //System errno and errmsg
    if (flags & ( nbase::LogInterface::LOG_SYS_CODE | nbase::LogInterface::LOG_SYS_MSG ))
    {
		if (flags & nbase::LogInterface::LOG_SYS_MSG)
#if defined(OS_WIN) && defined(COMPILER_MSVC)
        {
			char errbuf[256];
			strerror_s(errbuf, 256, errno);
			nbase::StringPrintf(buff, " {%d:%s}%s", errno, errbuf, nbase::kFileLineBreak);
		}
#else
			nbase::StringPrintf(buff, " {%d:%s}%s", errno, strerror(errno), nbase::kFileLineBreak);
#endif
        else
			nbase::StringPrintf(buff, " {%d}%s", errno, nbase::kFileLineBreak);
        header += buff;
    }
    //    "<<<"
    header += (const char *)"<<<<";
    return header;
}


}  // namespace nbase
