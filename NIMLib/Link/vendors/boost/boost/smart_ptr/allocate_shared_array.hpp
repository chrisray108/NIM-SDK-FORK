/*
 * Copyright (c) 2012 Glen Joseph Fernandes
 * glenfe at live dot com
 *
 * Distributed under the Boost Software License,
 * Version 1.0. (See accompanying file LICENSE_1_0.txt
 * or copy at http://boost.org/LICENSE_1_0.txt)
 */
#ifndef BOOST_SMART_PTR_ALLOCATE_SHARED_ARRAY_HPP
#define BOOST_SMART_PTR_ALLOCATE_SHARED_ARRAY_HPP

#include <boost/smart_ptr/shared_ptr.hpp>
#include <boost/smart_ptr/detail/allocate_array_helper.hpp>
#include <boost/smart_ptr/detail/array_deleter.hpp>
#include <boost/smart_ptr/detail/array_traits.hpp>
#include <boost/smart_ptr/detail/sp_if_array.hpp>
#if !defined(BOOST_NO_CXX11_HDR_INITIALIZER_LIST)
#include <initializer_list>
#endif

namespace nimboost {
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_array<T>::type
    allocate_shared(const A& allocator, std::size_t size) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        T1* p1 = 0;
        T2* p2 = 0;
        std::size_t n1 = size * nimboost::detail::array_total<T1>::size;
        nimboost::detail::allocate_array_helper<A, T2[]> a1(allocator, n1, &p2);
        nimboost::detail::array_deleter<T2[]> d1(n1);
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[]>* D2;
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->init(p2);
        return nimboost::shared_ptr<T>(s1, p1);
    }
#if !defined(BOOST_NO_CXX11_VARIADIC_TEMPLATES) && !defined(BOOST_NO_CXX11_RVALUE_REFERENCES)
    template<typename T, typename A, typename... Args>
    inline typename nimboost::detail::sp_if_array<T>::type
    allocate_shared(const A& allocator, std::size_t size, Args&&... args) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        T1* p1 = 0;
        T2* p2 = 0;
        std::size_t n1 = size * nimboost::detail::array_total<T1>::size;
        nimboost::detail::allocate_array_helper<A, T2[]> a1(allocator, n1, &p2);
        nimboost::detail::array_deleter<T2[]> d1(n1);
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[]>* D2;
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->init(p2, nimboost::detail::sp_forward<Args>(args)...);
        return nimboost::shared_ptr<T>(s1, p1);
    }
    template<typename T, typename A, typename... Args>
    inline typename nimboost::detail::sp_if_size_array<T>::type
    allocate_shared(const A& allocator, Args&&... args) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        enum {
            N = nimboost::detail::array_total<T>::size
        };
        T1* p1 = 0;
        T2* p2 = 0;
        nimboost::detail::allocate_array_helper<A, T2[N]> a1(allocator, &p2);
        nimboost::detail::array_deleter<T2[N]> d1;
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[N]>* D2;
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->init(p2, nimboost::detail::sp_forward<Args>(args)...);
        return nimboost::shared_ptr<T>(s1, p1);
    }
#endif
#if !defined(BOOST_NO_CXX11_UNIFIED_INITIALIZATION_SYNTAX)
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_size_array<T>::type
    allocate_shared(const A& allocator, const T& list) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        typedef const T2 T3;
        enum {
            N = nimboost::detail::array_total<T>::size
        };
        T1* p1 = 0;
        T2* p2 = 0;
        T3* p3 = 0;
        nimboost::detail::allocate_array_helper<A, T2[N]> a1(allocator, &p2);
        nimboost::detail::array_deleter<T2[N]> d1;
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[N]>* D2;
        p3 = reinterpret_cast<T3*>(list);
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->init_list(p2, p3);
        return nimboost::shared_ptr<T>(s1, p1);
    }
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_array<T>::type
    allocate_shared(const A& allocator, std::size_t size,
        const typename nimboost::detail::array_inner<T>::type& list) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        typedef const T2 T3;
        enum {
            M = nimboost::detail::array_total<T1>::size
        };
        T1* p1 = 0;
        T2* p2 = 0;
        T3* p3 = 0;
        std::size_t n1 = M * size;
        nimboost::detail::allocate_array_helper<A, T2[]> a1(allocator, n1, &p2);
        nimboost::detail::array_deleter<T2[]> d1(n1);
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[]>* D2;
        p3 = reinterpret_cast<T3*>(list);
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->template init_list<M>(p2, p3);
        return nimboost::shared_ptr<T>(s1, p1);
    }
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_size_array<T>::type
    allocate_shared(const A& allocator,
        const typename nimboost::detail::array_inner<T>::type& list) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        typedef const T2 T3;
        enum {
            M = nimboost::detail::array_total<T1>::size,
            N = nimboost::detail::array_total<T>::size
        };
        T1* p1 = 0;
        T2* p2 = 0;
        T3* p3 = 0;
        nimboost::detail::allocate_array_helper<A, T2[N]> a1(allocator, &p2);
        nimboost::detail::array_deleter<T2[N]> d1;
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[N]>* D2;
        p3 = reinterpret_cast<T3*>(list);
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->template init_list<M>(p2, p3);
        return nimboost::shared_ptr<T>(s1, p1);
    }
#if !defined(BOOST_NO_CXX11_HDR_INITIALIZER_LIST)
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_array<T>::type
    allocate_shared(const A& allocator,
        std::initializer_list<typename nimboost::detail::array_inner<T>::type> list) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        typedef const T2 T3;
        T1* p1 = 0;
        T2* p2 = 0;
        T3* p3 = 0;
        std::size_t n1 = list.size() * nimboost::detail::array_total<T1>::size;
        nimboost::detail::allocate_array_helper<A, T2[]> a1(allocator, n1, &p2);
        nimboost::detail::array_deleter<T2[]> d1(n1);
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[]>* D2;
        p3 = reinterpret_cast<T3*>(list.begin());
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->init_list(p2, p3);
        return nimboost::shared_ptr<T>(s1, p1);
    }
#endif
#if !defined(BOOST_NO_CXX11_RVALUE_REFERENCES)
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_array<T>::type
    allocate_shared(const A& allocator, std::size_t size,
        typename nimboost::detail::array_base<T>::type&& value) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        T1* p1 = 0;
        T2* p2 = 0;
        std::size_t n1 = size * nimboost::detail::array_total<T1>::size;
        nimboost::detail::allocate_array_helper<A, T2[]> a1(allocator, n1, &p2);
        nimboost::detail::array_deleter<T2[]> d1(n1);
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[]>* D2;
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->init(p2, nimboost::detail::sp_forward<T2>(value));
        return nimboost::shared_ptr<T>(s1, p1);
    }
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_size_array<T>::type
    allocate_shared(const A& allocator,
        typename nimboost::detail::array_base<T>::type&& value) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        enum {
            N = nimboost::detail::array_total<T>::size
        };
        T1* p1 = 0;
        T2* p2 = 0;
        nimboost::detail::allocate_array_helper<A, T2[N]> a1(allocator, &p2);
        nimboost::detail::array_deleter<T2[N]> d1;
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[N]>* D2;
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->init(p2, nimboost::detail::sp_forward<T2>(value));
        return nimboost::shared_ptr<T>(s1, p1);
    }
#endif
#endif
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_array<T>::type
    allocate_shared_noinit(const A& allocator, std::size_t size) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        T1* p1 = 0;
        T2* p2 = 0;
        std::size_t n1 = size * nimboost::detail::array_total<T1>::size;
        nimboost::detail::allocate_array_helper<A, T2[]> a1(allocator, n1, &p2);
        nimboost::detail::array_deleter<T2[]> d1(n1);
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[]>* D2;
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->noinit(p2);
        return nimboost::shared_ptr<T>(s1, p1);
    }
    template<typename T, typename A>
    inline typename nimboost::detail::sp_if_size_array<T>::type
    allocate_shared_noinit(const A& allocator) {
        typedef typename nimboost::detail::array_inner<T>::type T1;
        typedef typename nimboost::detail::array_base<T1>::type T2;
        enum {
            N = nimboost::detail::array_total<T>::size
        };
        T1* p1 = 0;
        T2* p2 = 0;
        nimboost::detail::allocate_array_helper<A, T2[N]> a1(allocator, &p2);
        nimboost::detail::array_deleter<T2[N]> d1;
        nimboost::shared_ptr<T> s1(p1, d1, a1);
        typedef nimboost::detail::array_deleter<T2[N]>* D2;
        p1 = reinterpret_cast<T1*>(p2);
        D2 d2 = static_cast<D2>(s1._internal_get_untyped_deleter());
        d2->noinit(p2);
        return nimboost::shared_ptr<T>(s1, p1);
    }
}

#endif
