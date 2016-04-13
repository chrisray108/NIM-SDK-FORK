//  (C) Copyright John Maddock 2008.
//  Use, modification and distribution are subject to the
//  Boost Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_TR1_UNORDERED_SET_HPP_INCLUDED
#  define BOOST_TR1_UNORDERED_SET_HPP_INCLUDED
#  include <boost/tr1/detail/config.hpp>

#ifdef BOOST_HAS_TR1_UNORDERED_SET

#  if defined(BOOST_HAS_INCLUDE_NEXT) && !defined(BOOST_TR1_DISABLE_INCLUDE_NEXT)
#     include_next BOOST_TR1_HEADER(unordered_set)
#  else
#     include <boost/tr1/detail/config_all.hpp>
#     include BOOST_TR1_STD_HEADER(BOOST_TR1_PATH(unordered_set))
#  endif

#else

#include <boost/unordered_set.hpp>

namespace std{ namespace tr1{

   using ::nimboost::unordered_set;
   using ::nimboost::unordered_multiset;
   using ::nimboost::swap;

} } // namespaces

#endif

#endif
