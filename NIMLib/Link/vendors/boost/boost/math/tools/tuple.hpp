//  (C) Copyright John Maddock 2010.
//  Use, modification and distribution are subject to the
//  Boost Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_MATH_TUPLE_HPP_INCLUDED
#  define BOOST_MATH_TUPLE_HPP_INCLUDED
#  include <boost/config.hpp>

#include <boost/tr1/detail/config.hpp>  // for BOOST_HAS_TR1_TUPLE

#ifndef BOOST_NO_CXX11_HDR_TUPLE

#include <tuple>

namespace nimboost{ namespace math{

using ::std::tuple;

// [6.1.3.2] Tuple creation functions
using ::std::ignore;
using ::std::make_tuple;
using ::std::tie;
using ::std::get;

// [6.1.3.3] Tuple helper classes
using ::std::tuple_size;
using ::std::tuple_element;

}}

#elif defined(BOOST_HAS_TR1_TUPLE)

#include <boost/tr1/tuple.hpp>

namespace nimboost{ namespace math{

using ::std::tr1::tuple;

// [6.1.3.2] Tuple creation functions
using ::std::tr1::ignore;
using ::std::tr1::make_tuple;
using ::std::tr1::tie;
using ::std::tr1::get;

// [6.1.3.3] Tuple helper classes
using ::std::tr1::tuple_size;
using ::std::tr1::tuple_element;

}}

#elif (defined(__BORLANDC__) && (__BORLANDC__ <= 0x600)) || defined(__IBMCPP__)

#include <boost/tuple/tuple.hpp>
#include <boost/tuple/tuple_comparison.hpp>
#include <boost/type_traits/integral_constant.hpp>

namespace nimboost{ namespace math{

using ::nimboost::tuple;

// [6.1.3.2] Tuple creation functions
using ::nimboost::tuples::ignore;
using ::nimboost::make_tuple;
using ::nimboost::tie;

// [6.1.3.3] Tuple helper classes
template <class T> 
struct tuple_size 
   : public ::nimboost::integral_constant
   < ::std::size_t, ::nimboost::tuples::length<T>::value>
{};

template < int I, class T>
struct tuple_element
{
   typedef typename nimboost::tuples::element<I,T>::type type;
};

#if !BOOST_WORKAROUND(__BORLANDC__, < 0x0582)
// [6.1.3.4] Element access
using ::nimboost::get;
#endif

} } // namespaces

#else

#include <boost/fusion/include/tuple.hpp>
#include <boost/fusion/include/std_pair.hpp>

namespace nimboost{ namespace math{

using ::nimboost::fusion::tuple;

// [6.1.3.2] Tuple creation functions
using ::nimboost::fusion::ignore;
using ::nimboost::fusion::make_tuple;
using ::nimboost::fusion::tie;
using ::nimboost::fusion::get;

// [6.1.3.3] Tuple helper classes
using ::nimboost::fusion::tuple_size;
using ::nimboost::fusion::tuple_element;

}}

#endif

#endif


