//
// placeholders.hpp
// ~~~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2013 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#ifndef BOOST_ASIO_PLACEHOLDERS_HPP
#define BOOST_ASIO_PLACEHOLDERS_HPP

#if defined(_MSC_VER) && (_MSC_VER >= 1200)
# pragma once
#endif // defined(_MSC_VER) && (_MSC_VER >= 1200)

#include <boost/asio/detail/config.hpp>

#if defined(BOOST_ASIO_HAS_BOOST_BIND)
# include <boost/bind/arg.hpp>
#endif // defined(BOOST_ASIO_HAS_BOOST_BIND)

#include <boost/asio/detail/push_options.hpp>

namespace nimboost {
namespace asio {
namespace placeholders {

#if defined(GENERATING_DOCUMENTATION)

/// An argument placeholder, for use with nimboost::bind(), that corresponds to
/// the error argument of a handler for any of the asynchronous functions.
unspecified error;

/// An argument placeholder, for use with nimboost::bind(), that corresponds to
/// the bytes_transferred argument of a handler for asynchronous functions such
/// as nimboost::asio::basic_stream_socket::async_write_some or
/// nimboost::asio::async_write.
unspecified bytes_transferred;

/// An argument placeholder, for use with nimboost::bind(), that corresponds to
/// the iterator argument of a handler for asynchronous functions such as
/// nimboost::asio::basic_resolver::async_resolve.
unspecified iterator;

/// An argument placeholder, for use with nimboost::bind(), that corresponds to
/// the signal_number argument of a handler for asynchronous functions such as
/// nimboost::asio::signal_set::async_wait.
unspecified signal_number;

#elif defined(BOOST_ASIO_HAS_BOOST_BIND)
# if defined(__BORLANDC__) || defined(__GNUC__)

inline nimboost::arg<1> error()
{
  return nimboost::arg<1>();
}

inline nimboost::arg<2> bytes_transferred()
{
  return nimboost::arg<2>();
}

inline nimboost::arg<2> iterator()
{
  return nimboost::arg<2>();
}

inline nimboost::arg<2> signal_number()
{
  return nimboost::arg<2>();
}

# else

namespace detail
{
  template <int Number>
  struct placeholder
  {
    static nimboost::arg<Number>& get()
    {
      static nimboost::arg<Number> result;
      return result;
    }
  };
}

#  if defined(BOOST_ASIO_MSVC) && (BOOST_ASIO_MSVC < 1400)

static nimboost::arg<1>& error
  = nimboost::asio::placeholders::detail::placeholder<1>::get();
static nimboost::arg<2>& bytes_transferred
  = nimboost::asio::placeholders::detail::placeholder<2>::get();
static nimboost::arg<2>& iterator
  = nimboost::asio::placeholders::detail::placeholder<2>::get();
static nimboost::arg<2>& signal_number
  = nimboost::asio::placeholders::detail::placeholder<2>::get();

#  else

namespace
{
  nimboost::arg<1>& error
    = nimboost::asio::placeholders::detail::placeholder<1>::get();
  nimboost::arg<2>& bytes_transferred
    = nimboost::asio::placeholders::detail::placeholder<2>::get();
  nimboost::arg<2>& iterator
    = nimboost::asio::placeholders::detail::placeholder<2>::get();
  nimboost::arg<2>& signal_number
    = nimboost::asio::placeholders::detail::placeholder<2>::get();
} // namespace

#  endif
# endif
#endif

} // namespace placeholders
} // namespace asio
} // namespace nimboost

#include <boost/asio/detail/pop_options.hpp>

#endif // BOOST_ASIO_PLACEHOLDERS_HPP
