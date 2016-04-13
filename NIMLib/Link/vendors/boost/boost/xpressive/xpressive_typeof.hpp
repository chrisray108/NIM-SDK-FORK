///////////////////////////////////////////////////////////////////////////////
/// \file xpressive_typeof.hpp
/// Type registrations so that xpressive can be used with the Boost.Typeof library.
//
//  Copyright 2008 Eric Niebler. Distributed under the Boost
//  Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_XPRESSIVE_XPRESSIVE_TYPEOF_H
#define BOOST_XPRESSIVE_XPRESSIVE_TYPEOF_H

// MS compatible compilers support #pragma once
#if defined(_MSC_VER) && (_MSC_VER >= 1020)
# pragma once
#endif

#include <boost/config.hpp>
#include <boost/typeof/typeof.hpp>
#ifndef BOOST_NO_STD_LOCALE
# include <boost/typeof/std/locale.hpp>
#endif
#include <boost/proto/proto_typeof.hpp>
#include <boost/xpressive/detail/detail_fwd.hpp>

#include BOOST_TYPEOF_INCREMENT_REGISTRATION_GROUP()

BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::mpl::bool_, (bool))

///////////////////////////////////////////////////////////////////////////////
// Misc.
//
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::set_initializer)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::keeper_tag)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::modifier_tag)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::lookahead_tag)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::lookbehind_tag)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::check_tag)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::mark_tag)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::word_begin)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::word_end)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::generic_quant_tag, (unsigned int)(unsigned int))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::basic_regex, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::word_boundary, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::value, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::reference, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::local, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::placeholder, (typename)(int)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::tracking_ptr, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::regex_impl, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::let_, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::action_arg, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::named_mark, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::sub_match, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::nested_results, (typename))

///////////////////////////////////////////////////////////////////////////////
// Placeholders
//
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::mark_placeholder)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::posix_charset_placeholder)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::assert_bol_placeholder)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::assert_eol_placeholder)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::logical_newline_placeholder)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::self_placeholder)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::assert_word_placeholder, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::range_placeholder, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::attribute_placeholder, (typename))

///////////////////////////////////////////////////////////////////////////////
// Matchers
//
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::epsilon_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::true_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::end_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::independent_end_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::any_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::assert_bos_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::assert_eos_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::mark_begin_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::mark_end_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::repeat_begin_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::alternate_end_matcher)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::attr_end_matcher)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::assert_bol_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::assert_eol_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::literal_matcher, (typename)(typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::string_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::charset_matcher, (typename)(typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::logical_newline_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::mark_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::repeat_end_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::alternate_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::optional_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::optional_mark_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::simple_repeat_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::regex_byref_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::regex_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::posix_charset_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::assert_word_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::range_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::keeper_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::lookahead_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::lookbehind_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::set_matcher, (typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::predicate_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::action_matcher, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::attr_matcher, (typename)(typename)(typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::attr_begin_matcher, (typename))

///////////////////////////////////////////////////////////////////////////////
// Ops
//
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::push)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::push_back)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::pop)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::push_front)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::pop_back)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::pop_front)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::back)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::front)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::top)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::first)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::second)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::matched)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::length)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::str)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::insert)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::op::make_pair)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::op::as, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::op::static_cast_, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::op::dynamic_cast_, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::op::const_cast_, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::op::construct, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::op::throw_, (typename))

///////////////////////////////////////////////////////////////////////////////
// Modifiers
//
BOOST_TYPEOF_REGISTER_TYPE(nimboost::xpressive::detail::icase_modifier)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::detail::locale_modifier, (typename))

///////////////////////////////////////////////////////////////////////////////
// Traits
//
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::null_regex_traits, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::cpp_regex_traits, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::c_regex_traits, (typename))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::xpressive::regex_traits, (typename)(typename))

#endif
