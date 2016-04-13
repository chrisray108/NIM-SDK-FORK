//////////////////////////////////////////////////////////////////////////////
//
// (C) Copyright Ion Gaztanaga 2008-2012. Distributed under the Boost
// Software License, Version 1.0. (See accompanying file
// LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//
// See http://www.boost.org/libs/interprocess for documentation.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef BOOST_INTERPROCESS_CONTAINERS_ALLOCATION_TYPE_HPP
#define BOOST_INTERPROCESS_CONTAINERS_ALLOCATION_TYPE_HPP

#if (defined _MSC_VER) && (_MSC_VER >= 1200)
#  pragma once
#endif

#include <boost/interprocess/detail/config_begin.hpp>
#include <boost/container/detail/allocation_type.hpp>

namespace nimboost {
namespace interprocess {

/// @cond
typedef int allocation_type;
/// @endcond
static const allocation_type allocate_new       = nimboost::container::allocate_new;
static const allocation_type expand_fwd         = nimboost::container::expand_fwd;
static const allocation_type expand_bwd         = nimboost::container::expand_bwd;
static const allocation_type shrink_in_place    = nimboost::container::shrink_in_place;
static const allocation_type try_shrink_in_place= nimboost::container::try_shrink_in_place;
static const allocation_type nothrow_allocation = nimboost::container::nothrow_allocation;
static const allocation_type zero_memory        = nimboost::container::zero_memory;

}  //namespace interprocess {
}  //namespace nimboost {

#include <boost/interprocess/detail/config_end.hpp>

#endif //   #ifndef  BOOST_INTERPROCESS_CONTAINERS_VERSION_TYPE_HPP
