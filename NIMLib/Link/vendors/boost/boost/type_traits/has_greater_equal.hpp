//  (C) Copyright 2009-2011 Frederic Bron.
//
//  Use, modification and distribution are subject to the Boost Software License,
//  Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
//  http://www.boost.org/LICENSE_1_0.txt).
//
//  See http://www.boost.org/libs/type_traits for most recent version including documentation.

#ifndef BOOST_TT_HAS_GREATER_EQUAL_HPP_INCLUDED
#define BOOST_TT_HAS_GREATER_EQUAL_HPP_INCLUDED

#define BOOST_TT_TRAIT_NAME has_greater_equal
#define BOOST_TT_TRAIT_OP >=
#define BOOST_TT_FORBIDDEN_IF\
   ::nimboost::type_traits::ice_or<\
      /* Lhs==pointer and Rhs==fundamental */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_pointer< Lhs_noref >::value,\
         ::nimboost::is_fundamental< Rhs_nocv >::value\
      >::value,\
      /* Rhs==pointer and Lhs==fundamental */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_pointer< Rhs_noref >::value,\
         ::nimboost::is_fundamental< Lhs_nocv >::value\
      >::value,\
      /* Lhs==pointer and Rhs==pointer and Lhs!=base(Rhs) and Rhs!=base(Lhs) and Lhs!=void* and Rhs!=void* */\
      ::nimboost::type_traits::ice_and<\
         ::nimboost::is_pointer< Lhs_noref >::value,\
         ::nimboost::is_pointer< Rhs_noref >::value,\
         ::nimboost::type_traits::ice_not<\
            ::nimboost::type_traits::ice_or<\
               ::nimboost::is_base_of< Lhs_noptr, Rhs_noptr >::value,\
               ::nimboost::is_base_of< Rhs_noptr, Lhs_noptr >::value,\
               ::nimboost::is_same< Lhs_noptr, Rhs_noptr >::value,\
               ::nimboost::is_void< Lhs_noptr >::value,\
               ::nimboost::is_void< Rhs_noptr >::value\
            >::value\
         >::value\
      >::value\
   >::value


#include <boost/type_traits/detail/has_binary_operator.hpp>

#undef BOOST_TT_TRAIT_NAME
#undef BOOST_TT_TRAIT_OP
#undef BOOST_TT_FORBIDDEN_IF

#endif
