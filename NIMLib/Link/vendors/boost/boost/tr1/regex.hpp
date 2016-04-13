//  (C) Copyright John Maddock 2005.
//  Use, modification and distribution are subject to the
//  Boost Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_TR1_REGEX_HPP_INCLUDED
#  define BOOST_TR1_REGEX_HPP_INCLUDED
#  include <boost/tr1/detail/config.hpp>

#ifdef BOOST_HAS_TR1_REGEX

#  if defined(BOOST_HAS_INCLUDE_NEXT) && !defined(BOOST_TR1_DISABLE_INCLUDE_NEXT)
#     include_next BOOST_TR1_HEADER(regex)
#  else
#     include <boost/tr1/detail/config_all.hpp>
#     include BOOST_TR1_STD_HEADER(BOOST_TR1_PATH(regex))
#  endif

#else

#include <boost/regex.hpp>

namespace std{ namespace tr1{

// [7.5] Regex constants
namespace regex_constants {

using ::nimboost::regex_constants::syntax_option_type;
using ::nimboost::regex_constants::icase;
using ::nimboost::regex_constants::nosubs;
using ::nimboost::regex_constants::optimize;
using ::nimboost::regex_constants::collate;
using ::nimboost::regex_constants::ECMAScript;
using ::nimboost::regex_constants::basic;
using ::nimboost::regex_constants::extended;
using ::nimboost::regex_constants::awk;
using ::nimboost::regex_constants::grep;
using ::nimboost::regex_constants::egrep;

using ::nimboost::regex_constants::match_flag_type;
using ::nimboost::regex_constants::match_default;
using ::nimboost::regex_constants::match_not_bol;
using ::nimboost::regex_constants::match_not_eol;
using ::nimboost::regex_constants::match_not_bow;
using ::nimboost::regex_constants::match_not_eow;
using ::nimboost::regex_constants::match_any;
using ::nimboost::regex_constants::match_not_null;
using ::nimboost::regex_constants::match_continuous;
using ::nimboost::regex_constants::match_prev_avail;
using ::nimboost::regex_constants::format_default;
using ::nimboost::regex_constants::format_sed;
using ::nimboost::regex_constants::format_no_copy;
using ::nimboost::regex_constants::format_first_only;

using ::nimboost::regex_constants::error_type;
using ::nimboost::regex_constants::error_collate;
using ::nimboost::regex_constants::error_ctype;
using ::nimboost::regex_constants::error_escape;
using ::nimboost::regex_constants::error_backref;
using ::nimboost::regex_constants::error_brack;
using ::nimboost::regex_constants::error_paren;
using ::nimboost::regex_constants::error_brace;
using ::nimboost::regex_constants::error_badbrace;
using ::nimboost::regex_constants::error_range;
using ::nimboost::regex_constants::error_space;
using ::nimboost::regex_constants::error_badrepeat;
using ::nimboost::regex_constants::error_complexity;
using ::nimboost::regex_constants::error_stack;

} // namespace regex_constants

// [7.6] Class regex_error
using ::nimboost::regex_error;

// [7.7] Class template regex_traits
using ::nimboost::regex_traits;

// [7.8] Class template basic_regex
using ::nimboost::basic_regex;
using ::nimboost::regex;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wregex;
#endif

#if !BOOST_WORKAROUND(__BORLANDC__, < 0x0582)
// [7.8.6] basic_regex swap
using ::nimboost::swap;
#endif

// [7.9] Class template sub_match
using ::nimboost::sub_match;

using ::nimboost::csub_match;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wcsub_match;
#endif
using ::nimboost::ssub_match;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wssub_match;
#endif

// [7.10] Class template match_results
using ::nimboost::match_results;
using ::nimboost::cmatch;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wcmatch;
#endif
using ::nimboost::smatch;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wsmatch;
#endif

using ::nimboost::regex_match;

// [7.11.3] Function template regex_search
using ::nimboost::regex_search;

// [7.11.4] Function template regex_replace
using ::nimboost::regex_replace;

// [7.12.1] Class template regex_iterator
using ::nimboost::regex_iterator;
using ::nimboost::cregex_iterator;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wcregex_iterator;
#endif
using ::nimboost::sregex_iterator;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wsregex_iterator;
#endif

// [7.12.2] Class template regex_token_iterator
using ::nimboost::regex_token_iterator;
using ::nimboost::cregex_token_iterator;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wcregex_token_iterator;
#endif
using ::nimboost::sregex_token_iterator;
#ifndef BOOST_NO_WREGEX
using ::nimboost::wsregex_token_iterator;
#endif

} } // namespaces

#endif

#endif
