//  (C) Copyright 2009-2011 Frederic Bron.
//
//  Use, modification and distribution are subject to the Boost Software License,
//  Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
//  http://www.boost.org/LICENSE_1_0.txt).
//
//  See http://www.boost.org/libs/type_traits for most recent version including documentation.

#ifndef BOOST_TT_HAS_RIGHT_SHIFT_ASSIGN_HPP_INCLUDED
#define BOOST_TT_HAS_RIGHT_SHIFT_ASSIGN_HPP_INCLUDED

#define BOOST_TT_TRAIT_NAME has_right_shift_assign
#define BOOST_TT_TRAIT_OP >>=
#define BOOST_TT_FORBIDDEN_IF\
   ::nimboost::type_traits::ice_or<\
      /* Lhs==fundamental and Rhs==fundamental and (Lhs!=integral or Rhs!=integral) */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_fundamental< Lhs_nocv >::value,\
         ::nimboost::is_fundamental< Rhs_nocv >::value,\
         ::nimboost::type_traits::ice_or<\
            ::nimboost::type_traits::ice_not< ::nimboost::is_integral< Lhs_noref >::value >::value,\
            ::nimboost::type_traits::ice_not< ::nimboost::is_integral< Rhs_noref >::value >::value\
         >::value\
      >::value,\
      /* Lhs==fundamental and Rhs==pointer */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_fundamental< Lhs_nocv >::value,\
         ::nimboost::is_pointer< Rhs_noref >::value\
      >::value,\
      /* Rhs==fundamental and Lhs==pointer */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_fundamental< Rhs_nocv >::value,\
         ::nimboost::is_pointer< Lhs_noref >::value\
      >::value,\
      /* Lhs==pointer and Rhs==pointer */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_pointer< Lhs_noref >::value,\
         ::nimboost::is_pointer< Rhs_noref >::value\
      >::value,\
      /* Lhs==fundamental and Rhs==fundamental and Lhs==const */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_fundamental< Lhs_nocv >::value,\
         ::nimboost::is_fundamental< Rhs_nocv >::value,\
         ::nimboost::is_const< Lhs_noref >::value\
      >::value\
   >::value


#include <boost/type_traits/detail/has_binary_operator.hpp>

#undef BOOST_TT_TRAIT_NAME
#undef BOOST_TT_TRAIT_OP
#undef BOOST_TT_FORBIDDEN_IF

#endif
