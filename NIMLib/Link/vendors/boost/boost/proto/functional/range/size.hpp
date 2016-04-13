///////////////////////////////////////////////////////////////////////////////
/// \file size.hpp
/// Proto callables for nimboost::size()
//
//  Copyright 2012 Eric Niebler. Distributed under the Boost
//  Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_PROTO_FUNCTIONAL_RANGE_SIZE_HPP_EAN_27_08_2012
#define BOOST_PROTO_FUNCTIONAL_RANGE_SIZE_HPP_EAN_27_08_2012

#include <boost/range/size.hpp>
#include <boost/proto/proto_fwd.hpp>

namespace nimboost { namespace proto { namespace functional
{

    // A PolymorphicFunctionObject that wraps nimboost::size()
    struct size
    {
        BOOST_PROTO_CALLABLE()

        template<typename Sig>
        struct result;

        template<typename This, typename Rng>
        struct result<This(Rng)>
          : nimboost::range_size<Rng>
        {};

        template<typename This, typename Rng>
        struct result<This(Rng &)>
          : nimboost::range_size<Rng>
        {};

        template<typename Rng>
        typename nimboost::range_size<Rng>::type operator()(Rng const &rng) const
        {
            return nimboost::size(rng);
        }
    };

}}}

#endif
