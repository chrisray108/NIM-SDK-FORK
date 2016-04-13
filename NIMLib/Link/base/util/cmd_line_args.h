/*
 *
 *	Author		Wang Rongtao <rtwang@corp.netease.com>
 *	Date		2010-09-01
 *	Copyright	Hangzhou, Netease Inc.
 *	Brief		a Windows command line parser
 *
 */

#ifndef BASE_UTIL_CMD_LINE_ARGS_H_
#define BASE_UTIL_CMD_LINE_ARGS_H_

#include "base/base_api.h"
#include <vector>
#include <ctype.h>

namespace nbase
{

class CmdLineArgs: public std::vector<wchar_t*>
{
public:

	CmdLineArgs(const wchar_t *command_line = 0);
	virtual ~CmdLineArgs();

private:

	bool ParseCommandLine();

	wchar_t *buffer_;
};

} // namespace

#endif // BASE_UTIL_CMD_LINE_ARGS_H_
