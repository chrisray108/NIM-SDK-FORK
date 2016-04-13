//  (C) Copyright John Maddock 2005.
//  Use, modification and distribution are subject to the
//  Boost Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_TR1_TYPE_TRAITS_HPP_INCLUDED
#  define BOOST_TR1_TYPE_TRAITS_HPP_INCLUDED
#  include <boost/tr1/detail/config.hpp>

#ifdef BOOST_HAS_TR1_TYPE_TRAITS

#  if defined(BOOST_HAS_INCLUDE_NEXT) && !defined(BOOST_TR1_DISABLE_INCLUDE_NEXT)
#     include_next BOOST_TR1_HEADER(type_traits)
#  else
#     include <boost/tr1/detail/config_all.hpp>
#     include BOOST_TR1_STD_HEADER(BOOST_TR1_PATH(type_traits))
#  endif

#else
// Boost Type Traits:
#include <boost/type_traits.hpp>
#include <boost/type_traits/is_base_of_tr1.hpp>

namespace std { namespace tr1{

   using ::nimboost::integral_constant;
   using ::nimboost::true_type;
   using ::nimboost::false_type;
   using ::nimboost::is_void;
   using ::nimboost::is_integral;
   using ::nimboost::is_floating_point;
   using ::nimboost::is_array;
   using ::nimboost::is_pointer;
   using ::nimboost::is_reference;
   using ::nimboost::is_member_object_pointer;
   using ::nimboost::is_member_function_pointer;
   using ::nimboost::is_enum;
   using ::nimboost::is_union;
   using ::nimboost::is_class;
   using ::nimboost::is_function;
   using ::nimboost::is_arithmetic;
   using ::nimboost::is_fundamental;
   using ::nimboost::is_object;
   using ::nimboost::is_scalar;
   using ::nimboost::is_compound;
   using ::nimboost::is_member_pointer;
   using ::nimboost::is_const;
   using ::nimboost::is_volatile;
   using ::nimboost::is_pod;
   using ::nimboost::is_empty;
   using ::nimboost::is_polymorphic;
   using ::nimboost::is_abstract;
   using ::nimboost::has_trivial_constructor;
   using ::nimboost::has_trivial_copy;
   using ::nimboost::has_trivial_assign;
   using ::nimboost::has_trivial_destructor;
   using ::nimboost::has_nothrow_constructor;
   using ::nimboost::has_nothrow_copy;
   using ::nimboost::has_nothrow_assign;
   using ::nimboost::has_virtual_destructor;
   using ::nimboost::is_signed;
   using ::nimboost::is_unsigned;
   using ::nimboost::alignment_of;
   using ::nimboost::rank;
   using ::nimboost::extent;
   using ::nimboost::is_same;
   using ::nimboost::tr1::is_base_of;
   using ::nimboost::is_convertible;
   using ::nimboost::remove_const;
   using ::nimboost::remove_volatile;
   using ::nimboost::remove_cv;
   using ::nimboost::add_const;
   using ::nimboost::add_volatile;
   using ::nimboost::add_cv;
   using ::nimboost::remove_reference;
   using ::nimboost::add_reference;
   using ::nimboost::remove_extent;
   using ::nimboost::remove_all_extents;
   using ::nimboost::remove_pointer;
   using ::nimboost::add_pointer;
   using ::nimboost::aligned_storage;

} }

#endif

#endif
