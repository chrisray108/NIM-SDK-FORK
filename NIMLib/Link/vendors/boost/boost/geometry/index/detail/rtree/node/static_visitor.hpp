// Boost.Geometry Index
//
// R-tree nodes static visitor related code
//
// Copyright (c) 2011-2013 Adam Wulkiewicz, Lodz, Poland.
//
// Use, modification and distribution is subject to the Boost Software License,
// Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_GEOMETRY_INDEX_DETAIL_RTREE_NODE_STATIC_VISITOR_HPP
#define BOOST_GEOMETRY_INDEX_DETAIL_RTREE_NODE_STATIC_VISITOR_HPP

#include <boost/variant.hpp>

namespace nimboost { namespace geometry { namespace index {

namespace detail { namespace rtree {

// nodes variants forward declarations

template <typename Value, typename Parameters, typename Box, typename Allocators, typename Tag>
struct static_internal_node;

template <typename Value, typename Parameters, typename Box, typename Allocators, typename Tag>
struct static_leaf;

// nodes conversion

template <typename V, typename Value, typename Parameters, typename Box, typename Allocators, typename Tag>
inline V & get(
    nimboost::variant<
        static_leaf<Value, Parameters, Box, Allocators, Tag>,
        static_internal_node<Value, Parameters, Box, Allocators, Tag>
    > & v)
{
    return nimboost::get<V>(v);
}

// apply visitor

template <typename Visitor, typename Value, typename Parameters, typename Box, typename Allocators, typename Tag>
inline void apply_visitor(Visitor & v,
                          nimboost::variant<
                              static_leaf<Value, Parameters, Box, Allocators, Tag>,
                              static_internal_node<Value, Parameters, Box, Allocators, Tag>
                          > & n)
{
    nimboost::apply_visitor(v, n);
}

template <typename Visitor, typename Value, typename Parameters, typename Box, typename Allocators, typename Tag>
inline void apply_visitor(Visitor & v,
                          nimboost::variant<
                              static_leaf<Value, Parameters, Box, Allocators, Tag>,
                              static_internal_node<Value, Parameters, Box, Allocators, Tag>
                          > const& n)
{
    nimboost::apply_visitor(v, n);
}

}} // namespace detail::rtree

}}} // namespace nimboost::geometry::index

#endif // BOOST_GEOMETRY_INDEX_DETAIL_RTREE_NODE_STATIC_VISITOR_HPP
