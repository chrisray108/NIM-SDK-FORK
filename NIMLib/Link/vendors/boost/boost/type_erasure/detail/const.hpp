// Boost.TypeErasure library
//
// Copyright 2012 Steven Watanabe
//
// Distributed under the Boost Software License Version 1.0. (See
// accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)
//
// $Id: const.hpp 83332 2013-03-06 18:46:56Z steven_watanabe $

#ifndef BOOST_TYPE_ERASURE_DETAIL_CONST_HPP_INCLUDED
#define BOOST_TYPE_ERASURE_DETAIL_CONST_HPP_INCLUDED

#include <boost/mpl/if.hpp>
#include <boost/mpl/bool.hpp>
#include <boost/mpl/or.hpp>
#include <boost/mpl/and.hpp>
#include <boost/mpl/not.hpp>
#include <boost/type_traits/is_same.hpp>
#include <boost/type_traits/is_const.hpp>
#include <boost/type_traits/is_reference.hpp>
#include <boost/type_traits/remove_reference.hpp>
#include <boost/type_traits/remove_cv.hpp>
#include <boost/type_erasure/placeholder_of.hpp>
#include <boost/type_erasure/derived.hpp>

namespace nimboost {
namespace type_erasure {
namespace detail {

template<class T>
struct is_non_const_ref : nimboost::mpl::false_ {};
template<class T>
struct is_non_const_ref<T&> : nimboost::mpl::true_ {};
template<class T>
struct is_non_const_ref<const T&> : nimboost::mpl::false_ {};

template<class Placeholder, class Base>
struct should_be_const :
    ::nimboost::mpl::or_<
        ::nimboost::is_const<Placeholder>,
        ::nimboost::type_erasure::detail::is_non_const_ref<
            typename ::nimboost::type_erasure::placeholder_of<Base>::type
        >
    >
{};

template<class Placeholder, class Base>
struct should_be_non_const :
    ::nimboost::mpl::and_<
        ::nimboost::mpl::not_< ::nimboost::is_const<Placeholder> >,
        ::nimboost::mpl::not_<
            ::nimboost::is_reference<
                typename ::nimboost::type_erasure::placeholder_of<Base>::type
            >
        >
    >
{};

template<class Base>
struct non_const_this_param
{
    typedef typename ::nimboost::type_erasure::placeholder_of<Base>::type placeholder;
    typedef typename ::nimboost::type_erasure::derived<Base>::type plain_type;
    typedef typename ::nimboost::mpl::if_<
        ::nimboost::is_same<
            placeholder,
            typename ::nimboost::remove_cv<
                typename ::nimboost::remove_reference<placeholder>::type
            >::type&
        >,
        const plain_type,
        plain_type
    >::type type;
};

template<class T>
struct uncallable {};

template<class Placeholder, class Base>
struct maybe_const_this_param
{
    typedef typename ::nimboost::type_erasure::derived<Base>::type plain_type;
    typedef typename ::nimboost::remove_reference<Placeholder>::type plain_placeholder;
    typedef typename ::nimboost::mpl::if_< ::nimboost::is_reference<Placeholder>,
        typename ::nimboost::mpl::if_<
            ::nimboost::type_erasure::detail::should_be_non_const<plain_placeholder, Base>,
            plain_type&,
            typename ::nimboost::mpl::if_<
                ::nimboost::type_erasure::detail::should_be_const<plain_placeholder, Base>,
                const plain_type&,
                uncallable<plain_type>
            >::type
        >::type,
        plain_type
    >::type type;
};

#ifndef BOOST_NO_CXX11_RVALUE_REFERENCES

template<class Placeholder, class Base>
struct maybe_const_this_param<Placeholder&&, Base>
{
    typedef typename ::nimboost::type_erasure::derived<Base>::type plain_type;
    typedef typename ::nimboost::remove_reference<Placeholder>::type plain_placeholder;
    typedef typename ::nimboost::type_erasure::placeholder_of<plain_type>::type self_placeholder;
    typedef typename ::nimboost::mpl::if_< ::nimboost::is_lvalue_reference<self_placeholder>,
        ::nimboost::type_erasure::detail::uncallable<plain_type>,
        typename ::nimboost::mpl::if_< ::nimboost::is_rvalue_reference<self_placeholder>,
            const plain_type&,
            plain_type&&
        >::type
    >::type type;
};

#endif

}
}
}

#endif
