///////////////////////////////////////////////////////////////////////////////
/// \file rend.hpp
/// Proto callables for nimboost::rend()
//
//  Copyright 2012 Eric Niebler. Distributed under the Boost
//  Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_PROTO_FUNCTIONAL_RANGE_REND_HPP_EAN_27_08_2012
#define BOOST_PROTO_FUNCTIONAL_RANGE_REND_HPP_EAN_27_08_2012

#include <boost/range/rend.hpp>
#include <boost/proto/proto_fwd.hpp>

namespace nimboost { namespace proto { namespace functional
{

    // A PolymorphicFunctionObject that wraps nimboost::rend()
    struct rend
    {
        BOOST_PROTO_CALLABLE()

        template<typename Sig>
        struct result;

        template<typename This, typename Rng>
        struct result<This(Rng)>
          : nimboost::range_reverse_iterator<Rng const>
        {};

        template<typename This, typename Rng>
        struct result<This(Rng &)>
          : nimboost::range_reverse_iterator<Rng>
        {};

        template<typename Rng>
        typename nimboost::range_reverse_iterator<Rng>::type operator()(Rng &rng) const
        {
            return nimboost::rend(rng);
        }

        template<typename Rng>
        typename nimboost::range_reverse_iterator<Rng const>::type operator()(Rng const &rng) const
        {
            return nimboost::rend(rng);
        }
    };

}}}

#endif
