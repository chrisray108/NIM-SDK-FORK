///////////////////////////////////////////////////////////////////////////////
/// \file proto_typeof.hpp
/// Type registrations so that proto expression templates can be used together
/// with the Boost.Typeof library.
//
//  Copyright 2008 Eric Niebler. Distributed under the Boost
//  Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_XPRESSIVE_PROTO_PROTO_TYPEOF_H
#define BOOST_XPRESSIVE_PROTO_PROTO_TYPEOF_H

#include <boost/config.hpp>
#include <boost/typeof/typeof.hpp>
#include <boost/proto/proto_fwd.hpp>
#include <boost/proto/deep_copy.hpp>
#include BOOST_TYPEOF_INCREMENT_REGISTRATION_GROUP()

BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::terminal)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::unary_plus)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::negate)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::dereference)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::complement)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::address_of)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::logical_not)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::pre_inc)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::pre_dec)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::post_inc)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::post_dec)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::shift_left)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::shift_right)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::multiplies)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::divides)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::modulus)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::plus)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::minus)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::less)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::greater)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::less_equal)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::greater_equal)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::equal_to)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::not_equal_to)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::logical_or)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::logical_and)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::bitwise_and)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::bitwise_or)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::bitwise_xor)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::comma)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::mem_ptr)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::shift_left_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::shift_right_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::multiplies_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::divides_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::modulus_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::plus_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::minus_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::bitwise_and_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::bitwise_or_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::bitwise_xor_assign)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::subscript)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::member)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::if_else_)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::tag::function)

BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::exprns_::is_proto_expr)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::exprns_::expr, (typename)(typename)(long))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::exprns_::basic_expr, (typename)(typename)(long))
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::utility::literal, (typename)(typename))

BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::detail::not_a_generator)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::detail::not_a_grammar)
BOOST_TYPEOF_REGISTER_TYPE(nimboost::proto::detail::not_a_domain)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::domain, 3)

BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::term, 1)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list1, 1)
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list2, 2)
// can't use PP metaprogramming here because all typeof registrations
// must be on separate lines.
#if BOOST_PROTO_MAX_ARITY >= 3
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list3, 3)
#endif
#if BOOST_PROTO_MAX_ARITY >= 4
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list4, 4)
#endif
#if BOOST_PROTO_MAX_ARITY >= 5
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list5, 5)
#endif
#if BOOST_PROTO_MAX_ARITY >= 6
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list6, 6)
#endif
#if BOOST_PROTO_MAX_ARITY >= 7
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list7, 7)
#endif
#if BOOST_PROTO_MAX_ARITY >= 8
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list8, 8)
#endif
#if BOOST_PROTO_MAX_ARITY >= 9
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list9, 9)
#endif
#if BOOST_PROTO_MAX_ARITY >= 10
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list10, 10)
#endif
#if BOOST_PROTO_MAX_ARITY >= 11
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list11, 11)
#endif
#if BOOST_PROTO_MAX_ARITY >= 12
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list12, 12)
#endif
#if BOOST_PROTO_MAX_ARITY >= 13
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list13, 13)
#endif
#if BOOST_PROTO_MAX_ARITY >= 14
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list14, 14)
#endif
#if BOOST_PROTO_MAX_ARITY >= 15
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list15, 15)
#endif
#if BOOST_PROTO_MAX_ARITY >= 16
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list16, 16)
#endif
#if BOOST_PROTO_MAX_ARITY >= 17
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list17, 17)
#endif
#if BOOST_PROTO_MAX_ARITY >= 18
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list18, 18)
#endif
#if BOOST_PROTO_MAX_ARITY >= 19
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list19, 19)
#endif
#if BOOST_PROTO_MAX_ARITY >= 20
BOOST_TYPEOF_REGISTER_TEMPLATE(nimboost::proto::list20, 20)
#endif

#define BOOST_PROTO_AUTO(Var, Expr) BOOST_AUTO(Var, nimboost::proto::deep_copy(Expr))
#define BOOST_PROTO_AUTO_TPL(Var, Expr) BOOST_AUTO_TPL(Var, nimboost::proto::deep_copy(Expr))

#endif
