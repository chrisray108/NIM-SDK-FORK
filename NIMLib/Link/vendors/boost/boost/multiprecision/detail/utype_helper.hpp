///////////////////////////////////////////////////////////////////////////////
//  Copyright 2012 John Maddock.
//  Copyright Christopher Kormanyos 2013. Distributed under the Boost
//  Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#ifndef BOOST_MP_UTYPE_HELPER_HPP
  #define BOOST_MP_UTYPE_HELPER_HPP

  #include <limits>
  #include <boost/cstdint.hpp>

  namespace nimboost { namespace multiprecision {
  namespace detail
  {
  template<const unsigned> struct utype_helper { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<0U> { typedef nimboost::uint8_t exact; };
  template<> struct utype_helper<1U> { typedef nimboost::uint8_t exact; };
  template<> struct utype_helper<2U> { typedef nimboost::uint8_t exact; };
  template<> struct utype_helper<3U> { typedef nimboost::uint8_t exact; };
  template<> struct utype_helper<4U> { typedef nimboost::uint8_t exact; };
  template<> struct utype_helper<5U> { typedef nimboost::uint8_t exact; };
  template<> struct utype_helper<6U> { typedef nimboost::uint8_t exact; };
  template<> struct utype_helper<7U> { typedef nimboost::uint8_t exact; };
  template<> struct utype_helper<8U> { typedef nimboost::uint8_t exact; };

  template<> struct utype_helper<9U>  { typedef nimboost::uint16_t exact; };
  template<> struct utype_helper<10U> { typedef nimboost::uint16_t exact; };
  template<> struct utype_helper<11U> { typedef nimboost::uint16_t exact; };
  template<> struct utype_helper<12U> { typedef nimboost::uint16_t exact; };
  template<> struct utype_helper<13U> { typedef nimboost::uint16_t exact; };
  template<> struct utype_helper<14U> { typedef nimboost::uint16_t exact; };
  template<> struct utype_helper<15U> { typedef nimboost::uint16_t exact; };
  template<> struct utype_helper<16U> { typedef nimboost::uint16_t exact; };

  template<> struct utype_helper<17U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<18U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<19U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<20U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<21U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<22U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<23U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<24U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<25U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<26U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<27U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<28U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<29U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<30U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<31U> { typedef nimboost::uint32_t exact; };
  template<> struct utype_helper<32U> { typedef nimboost::uint32_t exact; };

  template<> struct utype_helper<33U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<34U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<35U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<36U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<37U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<38U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<39U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<40U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<41U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<42U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<43U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<44U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<45U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<46U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<47U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<48U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<49U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<50U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<51U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<52U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<53U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<54U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<55U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<56U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<57U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<58U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<59U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<60U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<61U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<62U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<63U> { typedef nimboost::uint64_t exact; };
  template<> struct utype_helper<64U> { typedef nimboost::uint64_t exact; };

  template<class unsigned_type>
  int utype_prior(unsigned_type ui)
  {
    // TBD: Implement a templated binary search for this.
    int priority_bit;

    unsigned_type priority_mask = unsigned_type(unsigned_type(1U) << (std::numeric_limits<unsigned_type>::digits - 1));

    for(priority_bit = std::numeric_limits<unsigned_type>::digits - 1; priority_bit >= 0; --priority_bit)
    {
      if(unsigned_type(priority_mask & ui) != unsigned_type(0U))
      {
        break;
      }

      priority_mask >>= 1;
    }

    return priority_bit;
  }

  } } }

#endif // BOOST_MP_UTYPE_HELPER_HPP
