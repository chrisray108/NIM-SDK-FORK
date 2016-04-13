/*==============================================================================
    Copyright (c) 2005-2010 Joel de Guzman
    Copyright (c) 2010 Thomas Heller

    Distributed under the Boost Software License, Version 1.0. (See accompanying
    file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
==============================================================================*/
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1, typename Context>
        struct result<This(A0 , A1, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2, typename Context>
        struct result<This(A0 , A1 , A2, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3, typename Context>
        struct result<This(A0 , A1 , A2 , A3, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11 , A12, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11 , A12 const& a12
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx) , nimboost::nimboostphoenix::eval(a12, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11 , A12 , A13, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11 , A12 const& a12 , A13 const& a13
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx) , nimboost::nimboostphoenix::eval(a12, ctx) , nimboost::nimboostphoenix::eval(a13, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11 , A12 , A13 , A14, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11 , A12 const& a12 , A13 const& a13 , A14 const& a14
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx) , nimboost::nimboostphoenix::eval(a12, ctx) , nimboost::nimboostphoenix::eval(a13, ctx) , nimboost::nimboostphoenix::eval(a14, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11 , A12 , A13 , A14 , A15, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11 , A12 const& a12 , A13 const& a13 , A14 const& a14 , A15 const& a15
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx) , nimboost::nimboostphoenix::eval(a12, ctx) , nimboost::nimboostphoenix::eval(a13, ctx) , nimboost::nimboostphoenix::eval(a14, ctx) , nimboost::nimboostphoenix::eval(a15, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15 , typename A16, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11 , A12 , A13 , A14 , A15 , A16, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15 , typename A16, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11 , A12 const& a12 , A13 const& a13 , A14 const& a14 , A15 const& a15 , A16 const& a16
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx) , nimboost::nimboostphoenix::eval(a12, ctx) , nimboost::nimboostphoenix::eval(a13, ctx) , nimboost::nimboostphoenix::eval(a14, ctx) , nimboost::nimboostphoenix::eval(a15, ctx) , nimboost::nimboostphoenix::eval(a16, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15 , typename A16 , typename A17, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11 , A12 , A13 , A14 , A15 , A16 , A17, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15 , typename A16 , typename A17, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11 , A12 const& a12 , A13 const& a13 , A14 const& a14 , A15 const& a15 , A16 const& a16 , A17 const& a17
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx) , nimboost::nimboostphoenix::eval(a12, ctx) , nimboost::nimboostphoenix::eval(a13, ctx) , nimboost::nimboostphoenix::eval(a14, ctx) , nimboost::nimboostphoenix::eval(a15, ctx) , nimboost::nimboostphoenix::eval(a16, ctx) , nimboost::nimboostphoenix::eval(a17, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15 , typename A16 , typename A17 , typename A18, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11 , A12 , A13 , A14 , A15 , A16 , A17 , A18, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15 , typename A16 , typename A17 , typename A18, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11 , A12 const& a12 , A13 const& a13 , A14 const& a14 , A15 const& a15 , A16 const& a16 , A17 const& a17 , A18 const& a18
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx) , nimboost::nimboostphoenix::eval(a12, ctx) , nimboost::nimboostphoenix::eval(a13, ctx) , nimboost::nimboostphoenix::eval(a14, ctx) , nimboost::nimboostphoenix::eval(a15, ctx) , nimboost::nimboostphoenix::eval(a16, ctx) , nimboost::nimboostphoenix::eval(a17, ctx) , nimboost::nimboostphoenix::eval(a18, ctx)
                );
        }
    
    
    
    
    
    
    
        template <typename This, typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15 , typename A16 , typename A17 , typename A18 , typename A19, typename Context>
        struct result<This(A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 , A9 , A10 , A11 , A12 , A13 , A14 , A15 , A16 , A17 , A18 , A19, Context)>
            : detail::result_of::target<A0>
        {
        };
        
        template <typename A0 , typename A1 , typename A2 , typename A3 , typename A4 , typename A5 , typename A6 , typename A7 , typename A8 , typename A9 , typename A10 , typename A11 , typename A12 , typename A13 , typename A14 , typename A15 , typename A16 , typename A17 , typename A18 , typename A19, typename Context>
        typename detail::result_of::target<A0>::type
        operator()(
            A0 const&
          , A1 const& a1 , A2 const& a2 , A3 const& a3 , A4 const& a4 , A5 const& a5 , A6 const& a6 , A7 const& a7 , A8 const& a8 , A9 const& a9 , A10 const& a10 , A11 const& a11 , A12 const& a12 , A13 const& a13 , A14 const& a14 , A15 const& a15 , A16 const& a16 , A17 const& a17 , A18 const& a18 , A19 const& a19
          , Context const & ctx
        ) const
        {
            return
                typename detail::result_of::target<A0>::type(
                    nimboost::nimboostphoenix::eval(a1, ctx) , nimboost::nimboostphoenix::eval(a2, ctx) , nimboost::nimboostphoenix::eval(a3, ctx) , nimboost::nimboostphoenix::eval(a4, ctx) , nimboost::nimboostphoenix::eval(a5, ctx) , nimboost::nimboostphoenix::eval(a6, ctx) , nimboost::nimboostphoenix::eval(a7, ctx) , nimboost::nimboostphoenix::eval(a8, ctx) , nimboost::nimboostphoenix::eval(a9, ctx) , nimboost::nimboostphoenix::eval(a10, ctx) , nimboost::nimboostphoenix::eval(a11, ctx) , nimboost::nimboostphoenix::eval(a12, ctx) , nimboost::nimboostphoenix::eval(a13, ctx) , nimboost::nimboostphoenix::eval(a14, ctx) , nimboost::nimboostphoenix::eval(a15, ctx) , nimboost::nimboostphoenix::eval(a16, ctx) , nimboost::nimboostphoenix::eval(a17, ctx) , nimboost::nimboostphoenix::eval(a18, ctx) , nimboost::nimboostphoenix::eval(a19, ctx)
                );
        }
