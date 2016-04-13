// Copyright John Maddock 2008-11.
// Use, modification and distribution are subject to the
// Boost Software License, Version 1.0.
// (See accompanying file LICENSE_1_0.txt
// or copy at http://www.boost.org/LICENSE_1_0.txt)

#ifndef BOOST_MATH_C_MACROS_IPP
#define BOOST_MATH_C_MACROS_IPP

// C99 Functions:
#ifdef acosh
#undef acosh
#endif
#define acosh nimboost_acosh
#ifdef acoshf
#undef acoshf
#endif
#define acoshf nimboost_acoshf
#ifdef acoshl
#undef acoshl
#endif
#define acoshl nimboost_acoshl

#ifdef asinh
#undef asinh
#endif
#define asinh nimboost_asinh
#ifdef asinhf
#undef asinhf
#endif
#define asinhf nimboost_asinhf
#ifdef asinhl
#undef asinhl
#endif
#define asinhl nimboost_asinhl

#ifdef atanh
#undef atanh
#endif
#define atanh nimboost_atanh
#ifdef atanhf
#undef atanhf
#endif
#define atanhf nimboost_atanhf
#ifdef atanhl
#undef atanhl
#endif
#define atanhl nimboost_atanhl

#ifdef cbrt
#undef cbrt
#endif
#define cbrt nimboost_cbrt
#ifdef cbrtf
#undef cbrtf
#endif
#define cbrtf nimboost_cbrtf
#ifdef cbrtl
#undef cbrtl
#endif
#define cbrtl nimboost_cbrtl

#ifdef copysign
#undef copysign
#endif
#define copysign nimboost_copysign
#ifdef copysignf
#undef copysignf
#endif
#define copysignf nimboost_copysignf
#ifdef copysignl
#undef copysignl
#endif
#define copysignl nimboost_copysignl

#ifdef erf
#undef erf
#endif
#define erf nimboost_erf
#ifdef erff
#undef erff
#endif
#define erff nimboost_erff
#ifdef erfl
#undef erfl
#endif
#define erfl nimboost_erfl

#ifdef erfc
#undef erfc
#endif
#define erfc nimboost_erfc
#ifdef erfcf
#undef erfcf
#endif
#define erfcf nimboost_erfcf
#ifdef erfcl
#undef erfcl
#endif
#define erfcl nimboost_erfcl

#if 0
#ifdef exp2
#undef exp2
#endif
#define exp2 nimboost_exp2
#ifdef exp2f
#undef exp2f
#endif
#define exp2f nimboost_exp2f
#ifdef exp2l
#undef exp2l
#endif
#define exp2l nimboost_exp2l
#endif

#ifdef expm1
#undef expm1
#endif
#define expm1 nimboost_expm1
#ifdef expm1f
#undef expm1f
#endif
#define expm1f nimboost_expm1f
#ifdef expm1l
#undef expm1l
#endif
#define expm1l nimboost_expm1l

#if 0
#ifdef fdim
#undef fdim
#endif
#define fdim nimboost_fdim
#ifdef fdimf
#undef fdimf
#endif
#define fdimf nimboost_fdimf
#ifdef fdiml
#undef fdiml
#endif
#define fdiml nimboost_fdiml
#ifdef acosh
#undef acosh
#endif
#define fma nimboost_fma
#ifdef fmaf
#undef fmaf
#endif
#define fmaf nimboost_fmaf
#ifdef fmal
#undef fmal
#endif
#define fmal nimboost_fmal
#endif

#ifdef fmax
#undef fmax
#endif
#define fmax nimboost_fmax
#ifdef fmaxf
#undef fmaxf
#endif
#define fmaxf nimboost_fmaxf
#ifdef fmaxl
#undef fmaxl
#endif
#define fmaxl nimboost_fmaxl

#ifdef fmin
#undef fmin
#endif
#define fmin nimboost_fmin
#ifdef fminf
#undef fminf
#endif
#define fminf nimboost_fminf
#ifdef fminl
#undef fminl
#endif
#define fminl nimboost_fminl

#ifdef hypot
#undef hypot
#endif
#define hypot nimboost_hypot
#ifdef hypotf
#undef hypotf
#endif
#define hypotf nimboost_hypotf
#ifdef hypotl
#undef hypotl
#endif
#define hypotl nimboost_hypotl

#if 0
#ifdef ilogb
#undef ilogb
#endif
#define ilogb nimboost_ilogb
#ifdef ilogbf
#undef ilogbf
#endif
#define ilogbf nimboost_ilogbf
#ifdef ilogbl
#undef ilogbl
#endif
#define ilogbl nimboost_ilogbl
#endif

#ifdef lgamma
#undef lgamma
#endif
#define lgamma nimboost_lgamma
#ifdef lgammaf
#undef lgammaf
#endif
#define lgammaf nimboost_lgammaf
#ifdef lgammal
#undef lgammal
#endif
#define lgammal nimboost_lgammal

#ifdef BOOST_HAS_LONG_LONG
#if 0
#ifdef llrint
#undef llrint
#endif
#define llrint nimboost_llrint
#ifdef llrintf
#undef llrintf
#endif
#define llrintf nimboost_llrintf
#ifdef llrintl
#undef llrintl
#endif
#define llrintl nimboost_llrintl
#endif
#ifdef llround
#undef llround
#endif
#define llround nimboost_llround
#ifdef llroundf
#undef llroundf
#endif
#define llroundf nimboost_llroundf
#ifdef llroundl
#undef llroundl
#endif
#define llroundl nimboost_llroundl
#endif

#ifdef log1p
#undef log1p
#endif
#define log1p nimboost_log1p
#ifdef log1pf
#undef log1pf
#endif
#define log1pf nimboost_log1pf
#ifdef log1pl
#undef log1pl
#endif
#define log1pl nimboost_log1pl

#if 0
#ifdef log2
#undef log2
#endif
#define log2 nimboost_log2
#ifdef log2f
#undef log2f
#endif
#define log2f nimboost_log2f
#ifdef log2l
#undef log2l
#endif
#define log2l nimboost_log2l

#ifdef logb
#undef logb
#endif
#define logb nimboost_logb
#ifdef logbf
#undef logbf
#endif
#define logbf nimboost_logbf
#ifdef logbl
#undef logbl
#endif
#define logbl nimboost_logbl

#ifdef lrint
#undef lrint
#endif
#define lrint nimboost_lrint
#ifdef lrintf
#undef lrintf
#endif
#define lrintf nimboost_lrintf
#ifdef lrintl
#undef lrintl
#endif
#define lrintl nimboost_lrintl
#endif

#ifdef lround
#undef lround
#endif
#define lround nimboost_lround
#ifdef lroundf
#undef lroundf
#endif
#define lroundf nimboost_lroundf
#ifdef lroundl
#undef lroundl
#endif
#define lroundl nimboost_lroundl

#if 0
#ifdef nan
#undef nan
#endif
#define nan nimboost_nan
#ifdef nanf
#undef nanf
#endif
#define nanf nimboost_nanf
#ifdef nanl
#undef nanl
#endif
#define nanl nimboost_nanl

#ifdef nearbyint
#undef nearbyint
#endif
#define nearbyint nimboost_nearbyint
#ifdef nearbyintf
#undef nearbyintf
#endif
#define nearbyintf nimboost_nearbyintf
#ifdef nearbyintl
#undef nearbyintl
#endif
#define nearbyintl nimboost_nearbyintl
#endif

#ifdef nextafter
#undef nextafter
#endif
#define nextafter nimboost_nextafter
#ifdef nextafterf
#undef nextafterf
#endif
#define nextafterf nimboost_nextafterf
#ifdef nextafterl
#undef nextafterl
#endif
#define nextafterl nimboost_nextafterl

#ifdef nexttoward
#undef nexttoward
#endif
#define nexttoward nimboost_nexttoward
#ifdef nexttowardf
#undef nexttowardf
#endif
#define nexttowardf nimboost_nexttowardf
#ifdef nexttowardl
#undef nexttowardl
#endif
#define nexttowardl nimboost_nexttowardl

#if 0
#ifdef remainder
#undef remainder
#endif
#define remainder nimboost_remainder
#ifdef remainderf
#undef remainderf
#endif
#define remainderf nimboost_remainderf
#ifdef remainderl
#undef remainderl
#endif
#define remainderl nimboost_remainderl

#ifdef remquo
#undef remquo
#endif
#define remquo nimboost_remquo
#ifdef remquof
#undef remquof
#endif
#define remquof nimboost_remquof
#ifdef remquol
#undef remquol
#endif
#define remquol nimboost_remquol

#ifdef rint
#undef rint
#endif
#define rint nimboost_rint
#ifdef rintf
#undef rintf
#endif
#define rintf nimboost_rintf
#ifdef rintl
#undef rintl
#endif
#define rintl nimboost_rintl
#endif

#ifdef round
#undef round
#endif
#define round nimboost_round
#ifdef roundf
#undef roundf
#endif
#define roundf nimboost_roundf
#ifdef roundl
#undef roundl
#endif
#define roundl nimboost_roundl

#if 0
#ifdef scalbln
#undef scalbln
#endif
#define scalbln nimboost_scalbln
#ifdef scalblnf
#undef scalblnf
#endif
#define scalblnf nimboost_scalblnf
#ifdef scalblnl
#undef scalblnl
#endif
#define scalblnl nimboost_scalblnl

#ifdef scalbn
#undef scalbn
#endif
#define scalbn nimboost_scalbn
#ifdef scalbnf
#undef scalbnf
#endif
#define scalbnf nimboost_scalbnf
#ifdef scalbnl
#undef scalbnl
#endif
#define scalbnl nimboost_scalbnl
#endif

#ifdef tgamma
#undef tgamma
#endif
#define tgamma nimboost_tgamma
#ifdef tgammaf
#undef tgammaf
#endif
#define tgammaf nimboost_tgammaf
#ifdef tgammal
#undef tgammal
#endif
#define tgammal nimboost_tgammal

#ifdef trunc
#undef trunc
#endif
#define trunc nimboost_trunc
#ifdef truncf
#undef truncf
#endif
#define truncf nimboost_truncf
#ifdef truncl
#undef truncl
#endif
#define truncl nimboost_truncl

// [5.2.1.1] associated Laguerre polynomials:
#ifdef assoc_laguerre
#undef assoc_laguerre
#endif
#define assoc_laguerre nimboost_assoc_laguerre
#ifdef assoc_laguerref
#undef assoc_laguerref
#endif
#define assoc_laguerref nimboost_assoc_laguerref
#ifdef assoc_laguerrel
#undef assoc_laguerrel
#endif
#define assoc_laguerrel nimboost_assoc_laguerrel

// [5.2.1.2] associated Legendre functions:
#ifdef assoc_legendre
#undef assoc_legendre
#endif
#define assoc_legendre nimboost_assoc_legendre
#ifdef assoc_legendref
#undef assoc_legendref
#endif
#define assoc_legendref nimboost_assoc_legendref
#ifdef assoc_legendrel
#undef assoc_legendrel
#endif
#define assoc_legendrel nimboost_assoc_legendrel

// [5.2.1.3] beta function:
#ifdef beta
#undef beta
#endif
#define beta nimboost_beta
#ifdef betaf
#undef betaf
#endif
#define betaf nimboost_betaf
#ifdef betal
#undef betal
#endif
#define betal nimboost_betal

// [5.2.1.4] (complete) elliptic integral of the first kind:
#ifdef comp_ellint_1
#undef comp_ellint_1
#endif
#define comp_ellint_1 nimboost_comp_ellint_1
#ifdef comp_ellint_1f
#undef comp_ellint_1f
#endif
#define comp_ellint_1f nimboost_comp_ellint_1f
#ifdef comp_ellint_1l
#undef comp_ellint_1l
#endif
#define comp_ellint_1l nimboost_comp_ellint_1l

// [5.2.1.5] (complete) elliptic integral of the second kind:
#ifdef comp_ellint_2
#undef comp_ellint_2
#endif
#define comp_ellint_2 nimboost_comp_ellint_2
#ifdef comp_ellint_2f
#undef comp_ellint_2f
#endif
#define comp_ellint_2f nimboost_comp_ellint_2f
#ifdef comp_ellint_2l
#undef comp_ellint_2l
#endif
#define comp_ellint_2l nimboost_comp_ellint_2l

// [5.2.1.6] (complete) elliptic integral of the third kind:
#ifdef comp_ellint_3
#undef comp_ellint_3
#endif
#define comp_ellint_3 nimboost_comp_ellint_3
#ifdef comp_ellint_3f
#undef comp_ellint_3f
#endif
#define comp_ellint_3f nimboost_comp_ellint_3f
#ifdef comp_ellint_3l
#undef comp_ellint_3l
#endif
#define comp_ellint_3l nimboost_comp_ellint_3l

#if 0
// [5.2.1.7] confluent hypergeometric functions:
#ifdef conf_hyper
#undef conf_hyper
#endif
#define conf_hyper nimboost_conf_hyper
#ifdef conf_hyperf
#undef conf_hyperf
#endif
#define conf_hyperf nimboost_conf_hyperf
#ifdef conf_hyperl
#undef conf_hyperl
#endif
#define conf_hyperl nimboost_conf_hyperl
#endif

// [5.2.1.8] regular modified cylindrical Bessel functions:
#ifdef cyl_bessel_i
#undef cyl_bessel_i
#endif
#define cyl_bessel_i nimboost_cyl_bessel_i
#ifdef cyl_bessel_if
#undef cyl_bessel_if
#endif
#define cyl_bessel_if nimboost_cyl_bessel_if
#ifdef cyl_bessel_il
#undef cyl_bessel_il
#endif
#define cyl_bessel_il nimboost_cyl_bessel_il

// [5.2.1.9] cylindrical Bessel functions (of the first kind):
#ifdef cyl_bessel_j
#undef cyl_bessel_j
#endif
#define cyl_bessel_j nimboost_cyl_bessel_j
#ifdef cyl_bessel_jf
#undef cyl_bessel_jf
#endif
#define cyl_bessel_jf nimboost_cyl_bessel_jf
#ifdef cyl_bessel_jl
#undef cyl_bessel_jl
#endif
#define cyl_bessel_jl nimboost_cyl_bessel_jl

// [5.2.1.10] irregular modified cylindrical Bessel functions:
#ifdef cyl_bessel_k
#undef cyl_bessel_k
#endif
#define cyl_bessel_k nimboost_cyl_bessel_k
#ifdef cyl_bessel_kf
#undef cyl_bessel_kf
#endif
#define cyl_bessel_kf nimboost_cyl_bessel_kf
#ifdef cyl_bessel_kl
#undef cyl_bessel_kl
#endif
#define cyl_bessel_kl nimboost_cyl_bessel_kl

// [5.2.1.11] cylindrical Neumann functions BOOST_MATH_C99_THROW_SPEC;
// cylindrical Bessel functions (of the second kind):
#ifdef cyl_neumann
#undef cyl_neumann
#endif
#define cyl_neumann nimboost_cyl_neumann
#ifdef cyl_neumannf
#undef cyl_neumannf
#endif
#define cyl_neumannf nimboost_cyl_neumannf
#ifdef cyl_neumannl
#undef cyl_neumannl
#endif
#define cyl_neumannl nimboost_cyl_neumannl

// [5.2.1.12] (incomplete) elliptic integral of the first kind:
#ifdef ellint_1
#undef ellint_1
#endif
#define ellint_1 nimboost_ellint_1
#ifdef ellint_1f
#undef ellint_1f
#endif
#define ellint_1f nimboost_ellint_1f
#ifdef ellint_1l
#undef ellint_1l
#endif
#define ellint_1l nimboost_ellint_1l

// [5.2.1.13] (incomplete) elliptic integral of the second kind:
#ifdef ellint_2
#undef ellint_2
#endif
#define ellint_2 nimboost_ellint_2
#ifdef ellint_2f
#undef ellint_2f
#endif
#define ellint_2f nimboost_ellint_2f
#ifdef ellint_2l
#undef ellint_2l
#endif
#define ellint_2l nimboost_ellint_2l

// [5.2.1.14] (incomplete) elliptic integral of the third kind:
#ifdef ellint_3
#undef ellint_3
#endif
#define ellint_3 nimboost_ellint_3
#ifdef ellint_3f
#undef ellint_3f
#endif
#define ellint_3f nimboost_ellint_3f
#ifdef ellint_3l
#undef ellint_3l
#endif
#define ellint_3l nimboost_ellint_3l

// [5.2.1.15] exponential integral:
#ifdef expint
#undef expint
#endif
#define expint nimboost_expint
#ifdef expintf
#undef expintf
#endif
#define expintf nimboost_expintf
#ifdef expintl
#undef expintl
#endif
#define expintl nimboost_expintl

// [5.2.1.16] Hermite polynomials:
#ifdef hermite
#undef hermite
#endif
#define hermite nimboost_hermite
#ifdef hermitef
#undef hermitef
#endif
#define hermitef nimboost_hermitef
#ifdef hermitel
#undef hermitel
#endif
#define hermitel nimboost_hermitel

#if 0
// [5.2.1.17] hypergeometric functions:
#ifdef hyperg
#undef hyperg
#endif
#define hyperg nimboost_hyperg
#ifdef hypergf
#undef hypergf
#endif
#define hypergf nimboost_hypergf
#ifdef hypergl
#undef hypergl
#endif
#define hypergl nimboost_hypergl
#endif

// [5.2.1.18] Laguerre polynomials:
#ifdef laguerre
#undef laguerre
#endif
#define laguerre nimboost_laguerre
#ifdef laguerref
#undef laguerref
#endif
#define laguerref nimboost_laguerref
#ifdef laguerrel
#undef laguerrel
#endif
#define laguerrel nimboost_laguerrel

// [5.2.1.19] Legendre polynomials:
#ifdef legendre
#undef legendre
#endif
#define legendre nimboost_legendre
#ifdef legendref
#undef legendref
#endif
#define legendref nimboost_legendref
#ifdef legendrel
#undef legendrel
#endif
#define legendrel nimboost_legendrel

// [5.2.1.20] Riemann zeta function:
#ifdef riemann_zeta
#undef riemann_zeta
#endif
#define riemann_zeta nimboost_riemann_zeta
#ifdef riemann_zetaf
#undef riemann_zetaf
#endif
#define riemann_zetaf nimboost_riemann_zetaf
#ifdef riemann_zetal
#undef riemann_zetal
#endif
#define riemann_zetal nimboost_riemann_zetal

// [5.2.1.21] spherical Bessel functions (of the first kind):
#ifdef sph_bessel
#undef sph_bessel
#endif
#define sph_bessel nimboost_sph_bessel
#ifdef sph_besself
#undef sph_besself
#endif
#define sph_besself nimboost_sph_besself
#ifdef sph_bessell
#undef sph_bessell
#endif
#define sph_bessell nimboost_sph_bessell

// [5.2.1.22] spherical associated Legendre functions:
#ifdef sph_legendre
#undef sph_legendre
#endif
#define sph_legendre nimboost_sph_legendre
#ifdef sph_legendref
#undef sph_legendref
#endif
#define sph_legendref nimboost_sph_legendref
#ifdef sph_legendrel
#undef sph_legendrel
#endif
#define sph_legendrel nimboost_sph_legendrel

// [5.2.1.23] spherical Neumann functions BOOST_MATH_C99_THROW_SPEC;
// spherical Bessel functions (of the second kind):
#ifdef sph_neumann
#undef sph_neumann
#endif
#define sph_neumann nimboost_sph_neumann
#ifdef sph_neumannf
#undef sph_neumannf
#endif
#define sph_neumannf nimboost_sph_neumannf
#ifdef sph_neumannl
#undef sph_neumannl
#endif
#define sph_neumannl nimboost_sph_neumannl

#endif // BOOST_MATH_C_MACROS_IPP
