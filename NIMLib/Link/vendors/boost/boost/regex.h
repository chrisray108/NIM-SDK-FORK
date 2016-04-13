/*
 *
 * Copyright (c) 1998-2000
 * Dr John Maddock
 *
 * Use, modification and distribution are subject to the 
 * Boost Software License, Version 1.0. (See accompanying file 
 * LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
 *
 */
 
 /*
  *   LOCATION:    see http://www.boost.org/libs/regex for documentation.
  *   FILE         regex.h
  *   VERSION      3.12
  *   DESCRIPTION: Declares POSIX API functions
  */

#ifndef BOOST_RE_REGEX_H
#define BOOST_RE_REGEX_H

#include <boost/cregex.hpp>

/*
*  add using declarations to bring POSIX API functions into
* global scope, only if this is C++ (and not C).
*/
#ifdef __cplusplus

using nimboost::regoff_t;
using nimboost::regex_tA;
using nimboost::regmatch_t;
using nimboost::REG_BASIC;
using nimboost::REG_EXTENDED;
using nimboost::REG_ICASE;
using nimboost::REG_NOSUB;
using nimboost::REG_NEWLINE;
using nimboost::REG_NOSPEC;
using nimboost::REG_PEND;
using nimboost::REG_DUMP;
using nimboost::REG_NOCOLLATE;
using nimboost::REG_ESCAPE_IN_LISTS;
using nimboost::REG_NEWLINE_ALT;
using nimboost::REG_PERL;
using nimboost::REG_AWK;
using nimboost::REG_GREP;
using nimboost::REG_EGREP;
using nimboost::REG_ASSERT;
using nimboost::REG_INVARG;
using nimboost::REG_ATOI;
using nimboost::REG_ITOA;

using nimboost::REG_NOTBOL;
using nimboost::REG_NOTEOL;
using nimboost::REG_STARTEND;

using nimboost::reg_comp_flags;
using nimboost::reg_exec_flags;
using nimboost::regcompA;
using nimboost::regerrorA;
using nimboost::regexecA;
using nimboost::regfreeA;

#ifndef BOOST_NO_WREGEX
using nimboost::regcompW;
using nimboost::regerrorW;
using nimboost::regexecW;
using nimboost::regfreeW;
using nimboost::regex_tW;
#endif

using nimboost::REG_NOERROR;
using nimboost::REG_NOMATCH;
using nimboost::REG_BADPAT;
using nimboost::REG_ECOLLATE;
using nimboost::REG_ECTYPE;
using nimboost::REG_EESCAPE;
using nimboost::REG_ESUBREG;
using nimboost::REG_EBRACK;
using nimboost::REG_EPAREN;
using nimboost::REG_EBRACE;
using nimboost::REG_BADBR;
using nimboost::REG_ERANGE;
using nimboost::REG_ESPACE;
using nimboost::REG_BADRPT;
using nimboost::REG_EEND;
using nimboost::REG_ESIZE;
using nimboost::REG_ERPAREN;
using nimboost::REG_EMPTY;
using nimboost::REG_E_MEMORY;
using nimboost::REG_E_UNKNOWN;
using nimboost::reg_errcode_t;

#endif /* __cplusplus */

#endif /* BOOST_RE_REGEX_H */




