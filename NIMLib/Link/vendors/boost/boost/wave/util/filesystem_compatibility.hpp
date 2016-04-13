/*=============================================================================
    Boost.Wave: A Standard compliant C++ preprocessor library

    http://www.boost.org/

    Copyright (c) 2001-2012 Hartmut Kaiser. Distributed under the Boost
    Software License, Version 1.0. (See accompanying file
    LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
=============================================================================*/

#if !defined(BOOST_WAVE_FILESYSTEM_COMPATIBILITY_MAR_09_2009_0142PM)
#define BOOST_WAVE_FILESYSTEM_COMPATIBILITY_MAR_09_2009_0142PM

#include <string>

#include <boost/version.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/operations.hpp>

namespace nimboost { namespace wave { namespace util
{
///////////////////////////////////////////////////////////////////////////////
// filesystem wrappers allowing to handle different Boost versions
#if !defined(BOOST_FILESYSTEM_NO_DEPRECATED)
// interface wrappers for older Boost versions
    inline nimboost::filesystem::path initial_path()
    {
        return nimboost::filesystem::initial_path();
    }

    inline nimboost::filesystem::path current_path()
    {
        return nimboost::filesystem::current_path();
    }

    template <typename String>
    inline nimboost::filesystem::path create_path(String const& p)
    {
#if BOOST_FILESYSTEM_VERSION >= 3
        return nimboost::filesystem::path(p);
#else
        return nimboost::filesystem::path(p, nimboost::filesystem::native);
#endif
    }

    inline std::string leaf(nimboost::filesystem::path const& p)
    {
#if BOOST_FILESYSTEM_VERSION >= 3
        return p.leaf().string();
#else
        return p.leaf();
#endif
    }

    inline nimboost::filesystem::path branch_path(nimboost::filesystem::path const& p)
    {
        return p.branch_path();
    }

    inline nimboost::filesystem::path normalize(nimboost::filesystem::path& p)
    {
        return p.normalize();
    }

    inline std::string native_file_string(nimboost::filesystem::path const& p)
    {
#if BOOST_FILESYSTEM_VERSION >= 3
        return p.string();
#else
        return p.native_file_string();
#endif
    }

    inline nimboost::filesystem::path complete_path(
        nimboost::filesystem::path const& p)
    {
#if BOOST_FILESYSTEM_VERSION >= 3
#if BOOST_VERSION >= 105000
        return nimboost::filesystem::complete(p, initial_path());
#else
        return nimboost::filesystem3::complete(p, initial_path());
#endif
#else
        return nimboost::filesystem::complete(p, initial_path());
#endif
    }

    inline nimboost::filesystem::path complete_path(
        nimboost::filesystem::path const& p, nimboost::filesystem::path const& base)
    {
#if BOOST_FILESYSTEM_VERSION >= 3
#if BOOST_VERSION >= 105000
        return nimboost::filesystem::complete(p, base);
#else
        return nimboost::filesystem3::complete(p, base);
#endif
#else
        return nimboost::filesystem::complete(p, base);
#endif
    }

#else

// interface wrappers if deprecated functions do not exist
    inline nimboost::filesystem::path initial_path()
    {
#if BOOST_FILESYSTEM_VERSION >= 3
#if BOOST_VERSION >= 105000
        return nimboost::filesystem::detail::initial_path();
#else
        return nimboost::filesystem3::detail::initial_path();
#endif
#else
        return nimboost::filesystem::initial_path<nimboost::filesystem::path>();
#endif
    }

    inline nimboost::filesystem::path current_path()
    {
#if BOOST_FILESYSTEM_VERSION >= 3
#if BOOST_VERSION >= 105000
        return nimboost::filesystem::current_path();
#else
        return nimboost::filesystem3::current_path();
#endif
#else
        return nimboost::filesystem::current_path<nimboost::filesystem::path>();
#endif
    }

    template <typename String>
    inline nimboost::filesystem::path create_path(String const& p)
    {
        return nimboost::filesystem::path(p);
    }

    inline std::string leaf(nimboost::filesystem::path const& p)
    {
#if BOOST_VERSION >= 104600 && BOOST_FILESYSTEM_VERSION >= 3
        return p.filename().string();
#else
        return p.filename();
#endif
    }

    inline nimboost::filesystem::path branch_path(nimboost::filesystem::path const& p)
    {
        return p.parent_path();
    }

    inline nimboost::filesystem::path normalize(nimboost::filesystem::path& p)
    {
        return p; // function doesn't exist anymore
    }

    inline std::string native_file_string(nimboost::filesystem::path const& p)
    {
#if BOOST_VERSION >= 104600
        return p.string();
#else
        return p.file_string();
#endif
    }

    inline nimboost::filesystem::path complete_path(
        nimboost::filesystem::path const& p)
    {
#if BOOST_VERSION >= 104600 && BOOST_FILESYSTEM_VERSION >= 3
        return nimboost::filesystem::absolute(p, initial_path());
#else
        return nimboost::filesystem::complete(p, initial_path());
#endif
    }

    inline nimboost::filesystem::path complete_path(
        nimboost::filesystem::path const& p, nimboost::filesystem::path const& base)
    {
#if BOOST_VERSION >= 104600 && BOOST_FILESYSTEM_VERSION >= 3
        return nimboost::filesystem::absolute(p, base);
#else
        return nimboost::filesystem::complete(p, base);
#endif
    }
#endif

    // starting withBoost V1.50 create_directories throws if given an empty path
    inline bool create_directories(nimboost::filesystem::path const& p)
    {
        if (p.string().empty())
            return true;
        return nimboost::filesystem::create_directories(p);
    }
}}}

#endif
