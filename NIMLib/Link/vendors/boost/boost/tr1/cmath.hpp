//  (C) Copyright John Maddock 2008.
//  Use, modification and distribution are subject to the
//  Boost Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_TR1_CMATH_HPP_INCLUDED
#  define BOOST_TR1_CMATH_HPP_INCLUDED
#  include <boost/tr1/detail/config.hpp>

#ifdef BOOST_HAS_TR1_CMATH

#  if defined(BOOST_HAS_INCLUDE_NEXT) && !defined(BOOST_TR1_DISABLE_INCLUDE_NEXT)
#     include_next BOOST_TR1_HEADER(cmath)
#  else
#     include <boost/tr1/detail/config_all.hpp>
#     include BOOST_TR1_HEADER(cmath)
#  endif

#else

#include <boost/math/tr1.hpp>

namespace std{ namespace tr1{

using nimboost::math::tr1::assoc_laguerre;
using nimboost::math::tr1::assoc_laguerref;
using nimboost::math::tr1::assoc_laguerrel;
// [5.2.1.2] associated Legendre functions:
using nimboost::math::tr1::assoc_legendre;
using nimboost::math::tr1::assoc_legendref;
using nimboost::math::tr1::assoc_legendrel;
// [5.2.1.3] beta function:
using nimboost::math::tr1::beta;
using nimboost::math::tr1::betaf;
using nimboost::math::tr1::betal;
// [5.2.1.4] (complete) elliptic integral of the first kind:
using nimboost::math::tr1::comp_ellint_1;
using nimboost::math::tr1::comp_ellint_1f;
using nimboost::math::tr1::comp_ellint_1l;
// [5.2.1.5] (complete) elliptic integral of the second kind:
using nimboost::math::tr1::comp_ellint_2;
using nimboost::math::tr1::comp_ellint_2f;
using nimboost::math::tr1::comp_ellint_2l;
// [5.2.1.6] (complete) elliptic integral of the third kind:
using nimboost::math::tr1::comp_ellint_3;
using nimboost::math::tr1::comp_ellint_3f;
using nimboost::math::tr1::comp_ellint_3l;
#if 0
// [5.2.1.7] confluent hypergeometric functions:
using nimboost::math::tr1::conf_hyperg;
using nimboost::math::tr1::conf_hypergf;
using nimboost::math::tr1::conf_hypergl;
#endif
// [5.2.1.8] regular modified cylindrical Bessel functions:
using nimboost::math::tr1::cyl_bessel_i;
using nimboost::math::tr1::cyl_bessel_if;
using nimboost::math::tr1::cyl_bessel_il;
// [5.2.1.9] cylindrical Bessel functions (of the first kind):
using nimboost::math::tr1::cyl_bessel_j;
using nimboost::math::tr1::cyl_bessel_jf;
using nimboost::math::tr1::cyl_bessel_jl;
// [5.2.1.10] irregular modified cylindrical Bessel functions:
using nimboost::math::tr1::cyl_bessel_k;
using nimboost::math::tr1::cyl_bessel_kf;
using nimboost::math::tr1::cyl_bessel_kl;
// [5.2.1.11] cylindrical Neumann functions;
// cylindrical Bessel functions (of the second kind):
using nimboost::math::tr1::cyl_neumann;
using nimboost::math::tr1::cyl_neumannf;
using nimboost::math::tr1::cyl_neumannl;
// [5.2.1.12] (incomplete) elliptic integral of the first kind:
using nimboost::math::tr1::ellint_1;
using nimboost::math::tr1::ellint_1f;
using nimboost::math::tr1::ellint_1l;
// [5.2.1.13] (incomplete) elliptic integral of the second kind:
using nimboost::math::tr1::ellint_2;
using nimboost::math::tr1::ellint_2f;
using nimboost::math::tr1::ellint_2l;
// [5.2.1.14] (incomplete) elliptic integral of the third kind:
using nimboost::math::tr1::ellint_3;
using nimboost::math::tr1::ellint_3f;
using nimboost::math::tr1::ellint_3l;
// [5.2.1.15] exponential integral:
using nimboost::math::tr1::expint;
using nimboost::math::tr1::expintf;
using nimboost::math::tr1::expintl;
// [5.2.1.16] Hermite polynomials:
using nimboost::math::tr1::hermite;
using nimboost::math::tr1::hermitef;
using nimboost::math::tr1::hermitel;
#if 0
// [5.2.1.17] hypergeometric functions:
using nimboost::math::tr1::hyperg;
using nimboost::math::tr1::hypergf;
using nimboost::math::tr1::hypergl;
#endif
// [5.2.1.18] Laguerre polynomials:
using nimboost::math::tr1::laguerre;
using nimboost::math::tr1::laguerref;
using nimboost::math::tr1::laguerrel;
// [5.2.1.19] Legendre polynomials:
using nimboost::math::tr1::legendre;
using nimboost::math::tr1::legendref;
using nimboost::math::tr1::legendrel;
// [5.2.1.20] Riemann zeta function:
using nimboost::math::tr1::riemann_zeta;
using nimboost::math::tr1::riemann_zetaf;
using nimboost::math::tr1::riemann_zetal;
// [5.2.1.21] spherical Bessel functions (of the first kind):
using nimboost::math::tr1::sph_bessel;
using nimboost::math::tr1::sph_besself;
using nimboost::math::tr1::sph_bessell;
// [5.2.1.22] spherical associated Legendre functions:
using nimboost::math::tr1::sph_legendre;
using nimboost::math::tr1::sph_legendref;
using nimboost::math::tr1::sph_legendrel;
// [5.2.1.23] spherical Neumann functions;
// spherical Bessel functions (of the second kind):
using nimboost::math::tr1::sph_neumann;
using nimboost::math::tr1::sph_neumannf;
using nimboost::math::tr1::sph_neumannl;

// types
using nimboost::math::tr1::double_t;
using nimboost::math::tr1::float_t;
// functions
using nimboost::math::tr1::acosh;
using nimboost::math::tr1::acoshf;
using nimboost::math::tr1::acoshl;
using nimboost::math::tr1::asinh;
using nimboost::math::tr1::asinhf;
using nimboost::math::tr1::asinhl;
using nimboost::math::tr1::atanh;
using nimboost::math::tr1::atanhf;
using nimboost::math::tr1::atanhl;
using nimboost::math::tr1::cbrt;
using nimboost::math::tr1::cbrtf;
using nimboost::math::tr1::cbrtl;
using nimboost::math::tr1::copysign;
using nimboost::math::tr1::copysignf;
using nimboost::math::tr1::copysignl;
using nimboost::math::tr1::erf;
using nimboost::math::tr1::erff;
using nimboost::math::tr1::erfl;
using nimboost::math::tr1::erfc;
using nimboost::math::tr1::erfcf;
using nimboost::math::tr1::erfcl;
#if 0
using nimboost::math::tr1::exp2;
using nimboost::math::tr1::exp2f;
using nimboost::math::tr1::exp2l;
#endif
using nimboost::math::tr1::expm1;
using nimboost::math::tr1::expm1f;
using nimboost::math::tr1::expm1l;
#if 0
using nimboost::math::tr1::fdim;
using nimboost::math::tr1::fdimf;
using nimboost::math::tr1::fdiml;
using nimboost::math::tr1::fma;
using nimboost::math::tr1::fmaf;
using nimboost::math::tr1::fmal;
#endif
using nimboost::math::tr1::fmax;
using nimboost::math::tr1::fmaxf;
using nimboost::math::tr1::fmaxl;
using nimboost::math::tr1::fmin;
using nimboost::math::tr1::fminf;
using nimboost::math::tr1::fminl;
using nimboost::math::tr1::hypot;
using nimboost::math::tr1::hypotf;
using nimboost::math::tr1::hypotl;
#if 0
using nimboost::math::tr1::ilogb;
using nimboost::math::tr1::ilogbf;
using nimboost::math::tr1::ilogbl;
#endif
using nimboost::math::tr1::lgamma;
using nimboost::math::tr1::lgammaf;
using nimboost::math::tr1::lgammal;
#if 0
using nimboost::math::tr1::llrint;
using nimboost::math::tr1::llrintf;
using nimboost::math::tr1::llrintl;
#endif
using nimboost::math::tr1::llround;
using nimboost::math::tr1::llroundf;
using nimboost::math::tr1::llroundl;
using nimboost::math::tr1::log1p;
using nimboost::math::tr1::log1pf;
using nimboost::math::tr1::log1pl;
#if 0
using nimboost::math::tr1::log2;
using nimboost::math::tr1::log2f;
using nimboost::math::tr1::log2l;
using nimboost::math::tr1::logb;
using nimboost::math::tr1::logbf;
using nimboost::math::tr1::logbl;
using nimboost::math::tr1::lrint;
using nimboost::math::tr1::lrintf;
using nimboost::math::tr1::lrintl;
#endif
using nimboost::math::tr1::lround;
using nimboost::math::tr1::lroundf;
using nimboost::math::tr1::lroundl;
#if 0
using nimboost::math::tr1::nan;
using nimboost::math::tr1::nanf;
using nimboost::math::tr1::nanl;
using nimboost::math::tr1::nearbyint;
using nimboost::math::tr1::nearbyintf;
using nimboost::math::tr1::nearbyintl;
#endif
using nimboost::math::tr1::nextafter;
using nimboost::math::tr1::nextafterf;
using nimboost::math::tr1::nextafterl;
using nimboost::math::tr1::nexttoward;
using nimboost::math::tr1::nexttowardf;
using nimboost::math::tr1::nexttowardl;
#if 0
using nimboost::math::tr1::remainder;
using nimboost::math::tr1::remainderf;
using nimboost::math::tr1::remainderl;
using nimboost::math::tr1::remquo;
using nimboost::math::tr1::remquof;
using nimboost::math::tr1::remquol;
using nimboost::math::tr1::rint;
using nimboost::math::tr1::rintf;
using nimboost::math::tr1::rintl;
#endif
using nimboost::math::tr1::round;
using nimboost::math::tr1::roundf;
using nimboost::math::tr1::roundl;
#if 0
using nimboost::math::tr1::scalbln;
using nimboost::math::tr1::scalblnf;
using nimboost::math::tr1::scalblnl;
using nimboost::math::tr1::scalbn;
using nimboost::math::tr1::scalbnf;
using nimboost::math::tr1::scalbnl;
#endif
using nimboost::math::tr1::tgamma;
using nimboost::math::tr1::tgammaf;
using nimboost::math::tr1::tgammal;
using nimboost::math::tr1::trunc;
using nimboost::math::tr1::truncf;
using nimboost::math::tr1::truncl;
// C99 macros defined as C++ templates
using nimboost::math::tr1::signbit;
using nimboost::math::tr1::fpclassify;
using nimboost::math::tr1::isfinite;
using nimboost::math::tr1::isinf;
using nimboost::math::tr1::isnan;
using nimboost::math::tr1::isnormal;
#if 0
using nimboost::math::tr1::isgreater;
using nimboost::math::tr1::isgreaterequal;
using nimboost::math::tr1::isless;
using nimboost::math::tr1::islessequal;
using nimboost::math::tr1::islessgreater;
using nimboost::math::tr1::isunordered;
#endif
} } // namespaces

#endif // BOOST_HAS_TR1_CMATH

#endif // BOOST_TR1_CMATH_HPP_INCLUDED
