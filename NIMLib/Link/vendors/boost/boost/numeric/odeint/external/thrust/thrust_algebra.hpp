/*
 [auto_generated]
 boost/numeric/odeint/external/thrust/thrust_algebra.hpp

 [begin_description]
 An algebra for thrusts device_vectors.
 [end_description]

 Copyright 2009-2011 Karsten Ahnert
 Copyright 2009-2011 Mario Mulansky

 Distributed under the Boost Software License, Version 1.0.
 (See accompanying file LICENSE_1_0.txt or
 copy at http://www.boost.org/LICENSE_1_0.txt)
 */


#ifndef BOOST_NUMERIC_ODEINT_EXTERNAL_THRUST_THRUST_ALGEBRA_HPP_INCLUDED
#define BOOST_NUMERIC_ODEINT_EXTERNAL_THRUST_THRUST_ALGEBRA_HPP_INCLUDED


#include <thrust/device_vector.h>
#include <thrust/for_each.h>
#include <thrust/iterator/zip_iterator.h>

#include <boost/range.hpp>

namespace nimboost {
namespace numeric {
namespace odeint {



/** ToDO extend until for_each14 for rk78 */

/*
 * The const versions are needed for boost.range to work, i.e.
 * it allows you to do
 * for_each1( make_pair( vec1.begin() , vec1.begin() + 10 ) , op );
 */

struct thrust_algebra
{
    template< class StateType , class Operation >
    static void for_each1( StateType &s , Operation op )
    {
        thrust::for_each( nimboost::begin(s) , nimboost::begin(s) , op );
    }

    template< class StateType1 , class StateType2 , class Operation >
    static void for_each2( StateType1 &s1 , StateType2 &s2 , Operation op )
    {
        thrust::for_each(
                thrust::make_zip_iterator( thrust::make_tuple( nimboost::begin(s1) ,
                        nimboost::begin(s2) ) ) ,
                        thrust::make_zip_iterator( thrust::make_tuple( nimboost::end(s1) ,
                                nimboost::end(s2) ) ) ,
                                op);
    }

    template< class StateType1 , class StateType2 , class StateType3 , class Operation >
    static void for_each3( StateType1 &s1 , StateType2 &s2 , StateType3 &s3 , Operation op )
    {
        thrust::for_each(
                thrust::make_zip_iterator( thrust::make_tuple( nimboost::begin(s1) ,
                        nimboost::begin(s2) ,
                        nimboost::begin(s3) ) ) ,
                        thrust::make_zip_iterator( thrust::make_tuple( nimboost::end(s1) ,
                                nimboost::end(s2) ,
                                nimboost::end(s3) ) ) ,
                                op);
    }

    template< class StateType1 , class StateType2 , class StateType3 , class StateType4 ,
    class Operation >
    static void for_each4( StateType1 &s1 , StateType2 &s2 , StateType3 &s3 , StateType4 &s4 ,
            Operation op )
    {
        thrust::for_each(
                thrust::make_zip_iterator( thrust::make_tuple( nimboost::begin(s1) ,
                        nimboost::begin(s2) ,
                        nimboost::begin(s3) ,
                        nimboost::begin(s4) ) ) ,
                        thrust::make_zip_iterator( thrust::make_tuple( nimboost::end(s1) ,
                                nimboost::end(s2) ,
                                nimboost::end(s3) ,
                                nimboost::end(s4) ) ) ,
                                op);
    }

    template< class StateType1 , class StateType2 , class StateType3 ,
    class StateType4 , class StateType5 ,class Operation >
    static void for_each5( StateType1 &s1 , StateType2 &s2 , StateType3 &s3 , StateType4 &s4 ,
            StateType5 &s5 , Operation op )
    {
        thrust::for_each(
                thrust::make_zip_iterator( thrust::make_tuple( nimboost::begin(s1) ,
                        nimboost::begin(s2) ,
                        nimboost::begin(s3) ,
                        nimboost::begin(s4) ,
                        nimboost::begin(s5) ) ) ,
                        thrust::make_zip_iterator( thrust::make_tuple( nimboost::end(s1) ,
                                nimboost::end(s2) ,
                                nimboost::end(s3) ,
                                nimboost::end(s4) ,
                                nimboost::end(s5) ) ) ,
                                op);
    }

    template< class StateType1 , class StateType2 , class StateType3 ,
    class StateType4 , class StateType5 , class StateType6 , class Operation >
    static void for_each6( StateType1 &s1 , StateType2 &s2 , StateType3 &s3 , StateType4 &s4 ,
            StateType5 &s5 , StateType6 &s6 , Operation op )
    {
        thrust::for_each(
                thrust::make_zip_iterator( thrust::make_tuple( nimboost::begin(s1) ,
                        nimboost::begin(s2) ,
                        nimboost::begin(s3) ,
                        nimboost::begin(s4) ,
                        nimboost::begin(s5) ,
                        nimboost::begin(s6) ) ) ,
                        thrust::make_zip_iterator( thrust::make_tuple( nimboost::end(s1) ,
                                nimboost::end(s2) ,
                                nimboost::end(s3) ,
                                nimboost::end(s4) ,
                                nimboost::end(s5) ,
                                nimboost::end(s6) ) ) ,
                                op);
    }

    template< class StateType1 , class StateType2 , class StateType3 , class StateType4 ,
    class StateType5 , class StateType6 , class StateType7 , class Operation >
    static void for_each7( StateType1 &s1 , StateType2 &s2 , StateType3 &s3 , StateType4 &s4 ,
            StateType5 &s5 , StateType6 &s6 , StateType7 &s7 , Operation op )
    {
        thrust::for_each(
                thrust::make_zip_iterator( thrust::make_tuple( nimboost::begin(s1) ,
                        nimboost::begin(s2) ,
                        nimboost::begin(s3) ,
                        nimboost::begin(s4) ,
                        nimboost::begin(s5) ,
                        nimboost::begin(s6) ,
                        nimboost::begin(s7) ) ) ,
                        thrust::make_zip_iterator( thrust::make_tuple( nimboost::end(s1) ,
                                nimboost::end(s2) ,
                                nimboost::end(s3) ,
                                nimboost::end(s4) ,
                                nimboost::end(s5) ,
                                nimboost::end(s6) ,
                                nimboost::end(s7) ) ) ,
                                op);
    }

    template< class StateType1 , class StateType2 , class StateType3 , class StateType4 ,
    class StateType5 , class StateType6 , class StateType7 , class StateType8 , class Operation >
    static void for_each8( StateType1 &s1 , StateType2 &s2 , StateType3 &s3 , StateType4 &s4 ,
            StateType5 &s5 , StateType6 &s6 , StateType7 &s7 , StateType8 &s8 , Operation op )
    {
        thrust::for_each(
                thrust::make_zip_iterator( thrust::make_tuple( nimboost::begin(s1) ,
                        nimboost::begin(s2) ,
                        nimboost::begin(s3) ,
                        nimboost::begin(s4) ,
                        nimboost::begin(s5) ,
                        nimboost::begin(s6) ,
                        nimboost::begin(s7) ,
                        nimboost::begin(s8) ) ) ,
                thrust::make_zip_iterator( thrust::make_tuple( nimboost::end(s1) ,
                        nimboost::end(s2) ,
                        nimboost::end(s3) ,
                        nimboost::end(s4) ,
                        nimboost::end(s5) ,
                        nimboost::end(s6) ,
                        nimboost::end(s7) ,
                        nimboost::end(s8) ) ) ,
                op);
    }


    template< class Value , class S , class Red >
    Value reduce( const S &s , Red red , Value init)
    {
        return thrust::reduce( nimboost::begin( s ) , nimboost::end( s ) , init , red );
    }




};


} // odeint
} // numeric
} // boost



#endif // BOOST_NUMERIC_ODEINT_EXTERNAL_THRUST_THRUST_ALGEBRA_HPP_INCLUDED
