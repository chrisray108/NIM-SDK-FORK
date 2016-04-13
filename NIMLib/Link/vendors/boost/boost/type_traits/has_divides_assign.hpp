//  (C) Copyright 2009-2011 Frederic Bron.
//
//  Use, modification and distribution are subject to the Boost Software License,
//  Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
//  http://www.boost.org/LICENSE_1_0.txt).
//
//  See http://www.boost.org/libs/type_traits for most recent version including documentation.

#ifndef BOOST_TT_HAS_DIVIDES_ASSIGN_HPP_INCLUDED
#define BOOST_TT_HAS_DIVIDES_ASSIGN_HPP_INCLUDED

#define BOOST_TT_TRAIT_NAME has_divides_assign
#define BOOST_TT_TRAIT_OP /=
#define BOOST_TT_FORBIDDEN_IF\
   ::nimboost::type_traits::ice_or<\
      /* Lhs==fundamental and Lhs==const and Rhs==fundamental */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_fundamental< Lhs_nocv >::value,\
         ::nimboost::is_const< Lhs_noref >::value,\
         ::nimboost::is_fundamental< Rhs_nocv >::value\
      >::value,\
      /* Lhs==pointer and (Rhs==fundamental or Rhs==pointer) */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_pointer< Lhs_noref >::value,\
         ::nimboost::type_traits::ice_or<\
            ::nimboost::is_fundamental< Rhs_nocv >::value,\
            ::nimboost::is_pointer< Rhs_noref >::value\
         >::value\
      >::value,\
      /* Rhs==pointer and (Lhs==fundamental or Lhs==pointer) */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_pointer< Rhs_noref >::value,\
         ::nimboost::type_traits::ice_or<\
            ::nimboost::is_fundamental< Lhs_nocv >::value,\
            ::nimboost::is_pointer< Lhs_noref >::value\
         >::value\
      >::value\
   >::value


#include <boost/type_traits/detail/has_binary_operator.hpp>

#undef BOOST_TT_TRAIT_NAME
#undef BOOST_TT_TRAIT_OP
#undef BOOST_TT_FORBIDDEN_IF

#endif
