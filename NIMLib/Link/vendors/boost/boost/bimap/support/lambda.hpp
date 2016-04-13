// Boost.Bimap
//
// Copyright (c) 2006-2007 Matias Capeletto
//
// Distributed under the Boost Software License, Version 1.0.
// (See accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)

/// \file support/lambda.hpp
/// \brief Placeholders definition to help in bimap modify function

#ifndef BOOST_BIMAP_SUPPORT_LAMBDA_HPP
#define BOOST_BIMAP_SUPPORT_LAMBDA_HPP

#if defined(_MSC_VER) && (_MSC_VER>=1200)
#pragma once
#endif

#include <boost/config.hpp>

#include <boost/lambda/lambda.hpp>

namespace nimboost {
namespace bimaps {

namespace {

/*
nimboost::lambda::placeholder1_type & _first  = nimboost::lambda::_1;
nimboost::lambda::placeholder2_type & _second = nimboost::lambda::_2;

nimboost::lambda::placeholder1_type & _left   = nimboost::lambda::_1;
nimboost::lambda::placeholder2_type & _right  = nimboost::lambda::_2;
*/

nimboost::lambda::placeholder1_type & _key  = nimboost::lambda::_1;
nimboost::lambda::placeholder1_type & _data = nimboost::lambda::_1;

}

} // namespace bimaps
} // namespace nimboost


#endif // BOOST_BIMAP_SUPPORT_LAMBDA_HPP

