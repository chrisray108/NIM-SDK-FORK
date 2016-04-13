// Boost.TypeErasure library
//
// Copyright 2012 Steven Watanabe
//
// Distributed under the Boost Software License Version 1.0. (See
// accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)
//
// $Id: check_map.hpp 80883 2012-10-06 01:28:13Z steven_watanabe $

#ifndef BOOST_TYPE_ERASURE_DETAIL_CHECK_MAP_HPP_INCLUDED
#define BOOST_TYPE_ERASURE_DETAIL_CHECK_MAP_HPP_INCLUDED

#include <boost/mpl/not.hpp>
#include <boost/mpl/or.hpp>
#include <boost/mpl/bool.hpp>
#include <boost/mpl/set.hpp>
#include <boost/mpl/has_key.hpp>
#include <boost/mpl/find_if.hpp>
#include <boost/mpl/end.hpp>
#include <boost/type_traits/is_same.hpp>
#include <boost/type_erasure/detail/get_placeholders.hpp>
#include <boost/type_erasure/deduced.hpp>
#include <boost/type_erasure/static_binding.hpp>

namespace nimboost {
namespace type_erasure {
namespace detail {

template<class T>
struct is_deduced : nimboost::mpl::false_ {};
template<class T>
struct is_deduced< ::nimboost::type_erasure::deduced<T> > : nimboost::mpl::true_ {};

// returns true if Map has a key for every non-deduced placeholder in Concept
template<class Concept, class Map>
struct check_map {
    typedef typename normalize_concept<Concept>::basic basic_components;
    
    // Every non-deduced placeholder referenced in this
    // map is indirectly deduced.
    typedef typename ::nimboost::type_erasure::detail::get_placeholder_normalization_map<
        Concept>::type placeholder_subs;
    typedef typename ::nimboost::mpl::fold<
        placeholder_subs,
        ::nimboost::mpl::set0<>,
        ::nimboost::mpl::insert<
            ::nimboost::mpl::_1,
            ::nimboost::mpl::second< ::nimboost::mpl::_2>
        >
    >::type indirect_deduced_placeholders;

    typedef typename ::nimboost::mpl::fold<
        basic_components,
        ::nimboost::mpl::set0<>,
        ::nimboost::type_erasure::detail::get_placeholders<
            ::nimboost::mpl::_2,
            ::nimboost::mpl::_1
        >
    >::type placeholders;
    typedef typename ::nimboost::is_same<
        typename ::nimboost::mpl::find_if<
            placeholders,
            ::nimboost::mpl::not_<
                ::nimboost::mpl::or_<
                    ::nimboost::type_erasure::detail::is_deduced< ::nimboost::mpl::_1>,
                    ::nimboost::mpl::has_key<Map, ::nimboost::mpl::_1>,
                    ::nimboost::mpl::has_key<indirect_deduced_placeholders, ::nimboost::mpl::_1>
                >
            >
        >::type,
        typename ::nimboost::mpl::end<placeholders>::type
    >::type type;
};

template<class Concept, class Map>
struct check_map<Concept, ::nimboost::type_erasure::static_binding<Map> > :
    check_map<Concept, Map>
{};

}
}
}

#endif
