//
//  NIMLogger.h
//  NIM
//
//  Created by amao on 13-8-23.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>



#define NIMLogErr(frmt, ...) NIMLOG_OBJC( 6, __FILE__, __LINE__,frmt,##__VA_ARGS__)
#define NIMLogWar(frmt, ...) NIMLOG_OBJC( 8, __FILE__, __LINE__,frmt,##__VA_ARGS__)
#define NIMLogApp(frmt, ...) NIMLOG_OBJC(12, __FILE__, __LINE__,frmt,##__VA_ARGS__)
#define NIMLogPro(frmt, ...) NIMLOG_OBJC(14, __FILE__, __LINE__,frmt,##__VA_ARGS__)
#define NIMAPITrace() NIMLogApp(@"Call SDK API %s",__FUNCTION__) 


NIM_EXTERN void NIMSetupLogger();
NIM_EXTERN void NIMLOG_OBJC(uint32_t level, const char *file, uint32_t line, NSString *format, ...);


