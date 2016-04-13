// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/8
//
// The basic configuration of Windows SDK and CRT

#ifndef BUILD_WINSDK_CONFIG_H_
#define BUILD_WINSDK_CONFIG_H_

#if !defined(OS_WIN)
#error "Preprocessing symbol 'OS_WIN' needed :-)"
#endif

#ifndef VC_EXTRALEAN
#define VC_EXTRALEAN
#endif

#ifndef WIN32_LEAN_AND_MEAN			// remove rarely used header files, including 'winsock.h'
#define WIN32_LEAN_AND_MEAN			// which will conflict with 'winsock2.h'
#endif

#ifndef WINVER
#define WINVER 0x0500
#endif

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0500
#endif

#ifndef _WIN32_WINDOWS
#define _WIN32_WINDOWS 0x0410
#endif

#ifndef _WIN32_IE
#define _WIN32_IE 0x0600
#endif

#ifdef COMPILER_MSVC
#pragma warning(disable: 4996)
#endif

#endif // BUILD_WINSDK_CONFIG_H_
