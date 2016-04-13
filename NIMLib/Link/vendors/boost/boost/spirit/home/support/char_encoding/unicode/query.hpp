/*=============================================================================
    Copyright (c) 2001-2011 Joel de Guzman

    Distributed under the Boost Software License, Version 1.0. (See accompanying
    file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

    Autogenerated by MultiStageTable.py (Unicode multi-stage
    table builder) (c) Peter Kankowski, 2008
==============================================================================*/
#if !defined(BOOST_SPIRIT_UNICODE_QUERY_FEBRUARY_2_2010)
#define BOOST_SPIRIT_UNICODE_QUERY_FEBRUARY_2_2010

#include <boost/cstdint.hpp>

# include "category_table.hpp"
# include "script_table.hpp"
# include "lowercase_table.hpp"
# include "uppercase_table.hpp"

namespace nimboost { namespace spirit { namespace ucd
{
    // This header provides Basic (Level 1) Unicode Support
    // See http://unicode.org/reports/tr18/ for details

    struct properties
    {
        // bit pattern: xxMMMCCC
        // MMM: major_category
        // CCC: category

        enum major_category
        {
            letter,
            mark,
            number,
            separator,
            other,
            punctuation,
            symbol
        };

        enum category
        {
            uppercase_letter = 0,   // [Lu] an uppercase letter
            lowercase_letter,       // [Ll] a lowercase letter
            titlecase_letter,       // [Lt] a digraphic character, with first part uppercase
            modifier_letter,        // [Lm] a modifier letter
            other_letter,           // [Lo] other letters, including syllables and ideographs

            nonspacing_mark = 8,    // [Mn] a nonspacing combining mark (zero advance width)
            enclosing_mark,         // [Me] an enclosing combining mark
            spacing_mark,           // [Mc] a spacing combining mark (positive advance width)

            decimal_number = 16,    // [Nd] a decimal digit
            letter_number,          // [Nl] a letterlike numeric character
            other_number,           // [No] a numeric character of other type

            space_separator = 24,   // [Zs] a space character (of various non-zero widths)
            line_separator,         // [Zl] U+2028 LINE SEPARATOR only
            paragraph_separator,    // [Zp] U+2029 PARAGRAPH SEPARATOR only

            control = 32,           // [Cc] a C0 or C1 control code
            format,                 // [Cf] a format control character
            private_use,            // [Co] a private-use character
            surrogate,              // [Cs] a surrogate code point
            unassigned,             // [Cn] a reserved unassigned code point or a noncharacter

            dash_punctuation = 40,  // [Pd] a dash or hyphen punctuation mark
            open_punctuation,       // [Ps] an opening punctuation mark (of a pair)
            close_punctuation,      // [Pe] a closing punctuation mark (of a pair)
            connector_punctuation,  // [Pc] a connecting punctuation mark, like a tie
            other_punctuation,      // [Po] a punctuation mark of other type
            initial_punctuation,    // [Pi] an initial quotation mark
            final_punctuation,      // [Pf] a final quotation mark

            math_symbol = 48,       // [Sm] a symbol of primarily mathematical use
            currency_symbol,        // [Sc] a currency sign
            modifier_symbol,        // [Sk] a non-letterlike modifier symbol
            other_symbol            // [So] a symbol of other type
        };

        enum derived_properties
        {
            alphabetic = 64,
            uppercase = 128,
            lowercase = 256,
            white_space = 512,
            hex_digit = 1024,
            noncharacter_code_point = 2048,
            default_ignorable_code_point = 4096
        };

        enum script
        {
            arabic = 0,
            imperial_aramaic = 1,
            armenian = 2,
            avestan = 3,
            balinese = 4,
            bamum = 5,
            bengali = 6,
            bopomofo = 7,
            braille = 8,
            buginese = 9,
            buhid = 10,
            canadian_aboriginal = 11,
            carian = 12,
            cham = 13,
            cherokee = 14,
            coptic = 15,
            cypriot = 16,
            cyrillic = 17,
            devanagari = 18,
            deseret = 19,
            egyptian_hieroglyphs = 20,
            ethiopic = 21,
            georgian = 22,
            glagolitic = 23,
            gothic = 24,
            greek = 25,
            gujarati = 26,
            gurmukhi = 27,
            hangul = 28,
            han = 29,
            hanunoo = 30,
            hebrew = 31,
            hiragana = 32,
            katakana_or_hiragana = 33,
            old_italic = 34,
            javanese = 35,
            kayah_li = 36,
            katakana = 37,
            kharoshthi = 38,
            khmer = 39,
            kannada = 40,
            kaithi = 41,
            tai_tham = 42,
            lao = 43,
            latin = 44,
            lepcha = 45,
            limbu = 46,
            linear_b = 47,
            lisu = 48,
            lycian = 49,
            lydian = 50,
            malayalam = 51,
            mongolian = 52,
            meetei_mayek = 53,
            myanmar = 54,
            nko = 55,
            ogham = 56,
            ol_chiki = 57,
            old_turkic = 58,
            oriya = 59,
            osmanya = 60,
            phags_pa = 61,
            inscriptional_pahlavi = 62,
            phoenician = 63,
            inscriptional_parthian = 64,
            rejang = 65,
            runic = 66,
            samaritan = 67,
            old_south_arabian = 68,
            saurashtra = 69,
            shavian = 70,
            sinhala = 71,
            sundanese = 72,
            syloti_nagri = 73,
            syriac = 74,
            tagbanwa = 75,
            tai_le = 76,
            new_tai_lue = 77,
            tamil = 78,
            tai_viet = 79,
            telugu = 80,
            tifinagh = 81,
            tagalog = 82,
            thaana = 83,
            thai = 84,
            tibetan = 85,
            ugaritic = 86,
            vai = 87,
            old_persian = 88,
            cuneiform = 89,
            yi = 90,
            inherited = 91,
            common = 92,
            unknown = 93
        };
    };

    inline properties::category get_category(::nimboost::uint32_t ch)
    {
        return static_cast<properties::category>(detail::category_lookup(ch) & 0x3F);
    }

    inline properties::major_category get_major_category(::nimboost::uint32_t ch)
    {
        return static_cast<properties::major_category>(get_category(ch) >> 3);
    }

    inline bool is_punctuation(::nimboost::uint32_t ch)
    {
        return get_major_category(ch) == properties::punctuation;
    }

    inline bool is_decimal_number(::nimboost::uint32_t ch)
    {
        return get_category(ch) == properties::decimal_number;
    }

    inline bool is_hex_digit(::nimboost::uint32_t ch)
    {
        return (detail::category_lookup(ch) & properties::hex_digit) != 0;
    }

    inline bool is_control(::nimboost::uint32_t ch)
    {
        return get_category(ch) == properties::control;
    }

    inline bool is_alphabetic(::nimboost::uint32_t ch)
    {
        return (detail::category_lookup(ch) & properties::alphabetic) != 0;
    }

    inline bool is_alphanumeric(::nimboost::uint32_t ch)
    {
        return is_decimal_number(ch) || is_alphabetic(ch);
    }

    inline bool is_uppercase(::nimboost::uint32_t ch)
    {
        return (detail::category_lookup(ch) & properties::uppercase) != 0;
    }

    inline bool is_lowercase(::nimboost::uint32_t ch)
    {
        return (detail::category_lookup(ch) & properties::lowercase) != 0;
    }

    inline bool is_white_space(::nimboost::uint32_t ch)
    {
        return (detail::category_lookup(ch) & properties::white_space) != 0;
    }

    inline bool is_blank(::nimboost::uint32_t ch)
    {
        switch (ch)
        {
            case '\n': case '\v': case '\f': case '\r':
                return false;
            default:
                return is_white_space(ch)
                && !(   get_category(ch) == properties::line_separator
                    ||  get_category(ch) == properties::paragraph_separator
                    );
        }
    }

    inline bool is_graph(::nimboost::uint32_t ch)
    {
        return !(   is_white_space(ch)
                ||  get_category(ch) == properties::control
                ||  get_category(ch) == properties::surrogate
                ||  get_category(ch) == properties::unassigned
                );
    }

    inline bool is_print(::nimboost::uint32_t ch)
    {
        return (is_graph(ch) || is_blank(ch)) && !is_control(ch);
    }

    inline bool is_noncharacter_code_point(::nimboost::uint32_t ch)
    {
        return (detail::category_lookup(ch) & properties::noncharacter_code_point) != 0;
    }

    inline bool is_default_ignorable_code_point(::nimboost::uint32_t ch)
    {
        return (detail::category_lookup(ch) & properties::default_ignorable_code_point) != 0;
    }

    inline properties::script get_script(::nimboost::uint32_t ch)
    {
        return static_cast<properties::script>(detail::script_lookup(ch) & 0x7F);
    }

    inline ::nimboost::uint32_t to_lowercase(::nimboost::uint32_t ch)
    {
        // The table returns 0 to signal that this code maps to itself
        ::nimboost::uint32_t r = detail::lowercase_lookup(ch);
        return (r == 0)? ch : r;
    }

    inline ::nimboost::uint32_t to_uppercase(::nimboost::uint32_t ch)
    {
        // The table returns 0 to signal that this code maps to itself
        ::nimboost::uint32_t r = detail::uppercase_lookup(ch);
        return (r == 0)? ch : r;
    }
}}}

#endif
