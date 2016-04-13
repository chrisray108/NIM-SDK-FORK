// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/8
//
// This file defines BASE_API macro

#ifndef BASE_BASE_API_H_
#define BASE_BASE_API_H_

#include "build/build_config.h"
#include "port.h"

#if defined(OS_WIN)
#include "build/winsdk_config.h"
#endif

#if defined(BASE_DLL)
#if defined(OS_WIN)
#if defined(BASE_IMPLEMENTATION)
#define BASE_API __declspec(dllexport)
#else
#define BASE_API __declspec(dllimport)
#endif  // defined(BASE_IMPLEMENTATION)
#else
#define BASE_API __attribute__((visibility("default")))
#endif  // defined(OS_WIN)
#else
#define BASE_API
#endif

#endif  // BASE_BASE_API_H_