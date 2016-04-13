//
//  NIMLogger.h
//  NIM
//
//  Created by amao on 13-8-23.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "NIMLogger.h"
#import "base/log/log.h"
#import "NIMPathManager.h"


void NIMLOG_OBJC(uint32_t level, const char *file, uint32_t line, NSString *format, ...)
{
    va_list args;
    if (format)
    {
        va_start(args, format);
        NSString *formattedLog = [[NSString alloc]initWithFormat:format
                                                       arguments:args];
        
        if ([formattedLog length])
        {
            nbase::DefLog(level,file,line,"%s",[formattedLog UTF8String]);
        }
        va_end(args);
        
    }
}

void NIMSetupLogger()
{
    nbase::LogInterface *log = nbase::Log_Creater();
    nbase::LogInterface::Level level = nbase::LogInterface::LV_PRO;
    log->SetLevel(level);
}

