// Boost.TypeErasure library
//
// Copyright 2011 Steven Watanabe
//
// Distributed under the Boost Software License Version 1.0. (See
// accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)
//
// $Id: any_cast.hpp 80974 2012-10-13 00:02:25Z steven_watanabe $

#ifndef BOOST_TYPE_ERASURE_ANY_CAST_HPP_INCLUDED
#define BOOST_TYPE_ERASURE_ANY_CAST_HPP_INCLUDED

#include <stdexcept>
#include <boost/throw_exception.hpp>
#include <boost/type_traits/add_const.hpp>
#include <boost/type_traits/is_pointer.hpp>
#include <boost/type_traits/remove_cv.hpp>
#include <boost/type_traits/remove_reference.hpp>
#include <boost/type_traits/remove_pointer.hpp>
#include <boost/type_traits/is_void.hpp>
#include <boost/mpl/assert.hpp>
#include <boost/mpl/bool.hpp>
#include <boost/type_erasure/any.hpp>
#include <boost/type_erasure/builtin.hpp>
#include <boost/type_erasure/exception.hpp>
#include <boost/type_erasure/detail/access.hpp>

namespace nimboost {
namespace type_erasure {

namespace detail {

template<class Concept, class T>
void* get_pointer(::nimboost::type_erasure::any<Concept, T>& arg)
{
    return ::nimboost::type_erasure::detail::access::data(arg).data;
}

template<class Concept, class T>
const void* get_pointer(const ::nimboost::type_erasure::any<Concept, T>& arg)
{
    return ::nimboost::type_erasure::detail::access::data(arg).data;
}

template<class Concept, class T>
void* get_pointer(::nimboost::type_erasure::any<Concept, T&>& arg)
{
    return ::nimboost::type_erasure::detail::access::data(arg).data;
}

template<class Concept, class T>
void* get_pointer(const ::nimboost::type_erasure::any<Concept, T&>& arg)
{
    return ::nimboost::type_erasure::detail::access::data(arg).data;
}

template<class Concept, class T>
const void* get_pointer(::nimboost::type_erasure::any<Concept, const T&>& arg)
{
    return ::nimboost::type_erasure::detail::access::data(arg).data;
}

template<class Concept, class T>
const void* get_pointer(const ::nimboost::type_erasure::any<Concept, const T&>& arg)
{
    return ::nimboost::type_erasure::detail::access::data(arg).data;
}

template<class T, class Concept, class Tag>
bool check_any_cast(const any<Concept, Tag>&, ::nimboost::mpl::true_)
{
    return true;
}

template<class T, class Concept, class Tag>
bool check_any_cast(const any<Concept, Tag>& arg, ::nimboost::mpl::false_)
{
    typedef typename ::nimboost::remove_cv<
        typename ::nimboost::remove_reference<Tag>::type
    >::type tag_type;
    return ::nimboost::type_erasure::detail::access::table(arg)
        .template find<typeid_<tag_type> >()() == typeid(T);
}

template<class T, class Concept, class Tag>
bool check_any_cast(const any<Concept, Tag>& arg)
{
    return ::nimboost::type_erasure::detail::check_any_cast<T>(
        arg, ::nimboost::is_void<typename ::nimboost::remove_reference<T>::type>());
}

}

/**
 * Attempts to extract the object that @c arg holds.
 * If casting to a pointer fails, \any_cast returns
 * a null pointer.  Casting to @c void* always succeeds
 * and returns the address of stored object.
 *
 * \pre if @c arg is a pointer, @c T must be a pointer type.
 * \pre @c Concept must contain @ref typeid_<tt>&lt;Tag&gt;</tt>.
 *
 * \throws bad_any_cast if @c arg doesn't contain
 *         an object of type @c T and we're casting
 *         to a value or reference.
 */
template<class T, class Concept, class Tag>
T any_cast(any<Concept, Tag>& arg)
{
    if(::nimboost::type_erasure::detail::check_any_cast<T>(arg)) {
        return *static_cast<
            typename ::nimboost::remove_reference<
                typename ::nimboost::add_const<T>::type
            >::type*
        >(::nimboost::type_erasure::detail::get_pointer(arg));
    } else {
        BOOST_THROW_EXCEPTION(::nimboost::type_erasure::bad_any_cast());
    }
}

/** \overload */
template<class T, class Concept, class Tag>
T any_cast(const any<Concept, Tag>& arg)
{
    if(::nimboost::type_erasure::detail::check_any_cast<T>(arg)) {
        return *static_cast<
            typename ::nimboost::remove_reference<
                typename ::nimboost::add_const<T>::type
            >::type*
        >(::nimboost::type_erasure::detail::get_pointer(arg));
    } else {
        BOOST_THROW_EXCEPTION(::nimboost::type_erasure::bad_any_cast());
    }
}

/** \overload */
template<class T, class Concept, class Tag>
T any_cast(any<Concept, Tag>* arg)
{
    BOOST_MPL_ASSERT((::nimboost::is_pointer<T>));
    if(::nimboost::type_erasure::detail::check_any_cast<
        typename ::nimboost::remove_pointer<T>::type>(*arg)) {
        return static_cast<
            typename ::nimboost::remove_pointer<T>::type*>(
                ::nimboost::type_erasure::detail::get_pointer(*arg));
    } else {
        return 0;
    }
}

/** \overload */
template<class T, class Concept, class Tag>
T any_cast(const any<Concept, Tag>* arg)
{
    BOOST_MPL_ASSERT((::nimboost::is_pointer<T>));
    if(::nimboost::type_erasure::detail::check_any_cast<
        typename ::nimboost::remove_pointer<T>::type>(*arg)) {
        return static_cast<
            typename ::nimboost::remove_pointer<T>::type*>(
                ::nimboost::type_erasure::detail::get_pointer(*arg));
    } else {
        return 0;
    }
}

}
}

#endif
