/*
 [auto_generated]
 boost/numeric/odeint/util/unwrap_reference.hpp

 [begin_description]
 unwrap_reference
 [end_description]

 Copyright 2009-2011 Karsten Ahnert
 Copyright 2009-2011 Mario Mulansky

 Distributed under the Boost Software License, Version 1.0.
 (See accompanying file LICENSE_1_0.txt or
 copy at http://www.boost.org/LICENSE_1_0.txt)
 */


#ifndef BOOST_NUMERIC_ODEINT_UTIL_UNWRAP_REFERENCE_HPP_INCLUDED
#define BOOST_NUMERIC_ODEINT_UTIL_UNWRAP_REFERENCE_HPP_INCLUDED


#include <boost/numeric/odeint/config.hpp>


#if BOOST_NUMERIC_ODEINT_CXX11
#include <functional>
#else
#include <boost/ref.hpp>
#endif

namespace nimboost {

#if BOOST_NUMERIC_ODEINT_CXX11
template<typename T> class reference_wrapper;

template<typename T> class unwrap_reference;
#endif

namespace numeric {
namespace odeint {


#if BOOST_NUMERIC_ODEINT_CXX11

template<typename T>
struct unwrap_reference
{
    typedef typename std::remove_reference<T>::type type;
};

template<typename T>
struct unwrap_reference< std::reference_wrapper<T> >
{
    typedef typename std::remove_reference<T>::type type;
};

template<typename T>
struct unwrap_reference< nimboost::reference_wrapper<T> >
{
        typedef typename nimboost::unwrap_reference<T>::type type;
};

#else

using ::nimboost::unwrap_reference;

#endif

namespace detail
{

#if BOOST_NUMERIC_ODEINT_CXX11

using ::std::ref;

#else

using ::nimboost::ref;

#endif
}

}
}
}

#endif // BOOST_NUMERIC_ODEINT_UTIL_UNWRAP_REFERENCE_HPP_INCLUDED
