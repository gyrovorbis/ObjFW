/*
 * Copyright (c) 2008-2021 Jonathan Schleifer <js@nil.im>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include "config.h"

#import "OFString.h"

#import "common.h"

const OFChar16 of_iso_8859_3_table[] = {
	0x00A0, 0x0126, 0x02D8, 0x00A3, 0x00A4, 0xFFFF, 0x0124, 0x00A7,
	0x00A8, 0x0130, 0x015E, 0x011E, 0x0134, 0x00AD, 0xFFFF, 0x017B,
	0x00B0, 0x0127, 0x00B2, 0x00B3, 0x00B4, 0x00B5, 0x0125, 0x00B7,
	0x00B8, 0x0131, 0x015F, 0x011F, 0x0135, 0x00BD, 0xFFFF, 0x017C,
	0x00C0, 0x00C1, 0x00C2, 0xFFFF, 0x00C4, 0x010A, 0x0108, 0x00C7,
	0x00C8, 0x00C9, 0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE, 0x00CF,
	0xFFFF, 0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x0120, 0x00D6, 0x00D7,
	0x011C, 0x00D9, 0x00DA, 0x00DB, 0x00DC, 0x016C, 0x015C, 0x00DF,
	0x00E0, 0x00E1, 0x00E2, 0xFFFF, 0x00E4, 0x010B, 0x0109, 0x00E7,
	0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF,
	0xFFFF, 0x00F1, 0x00F2, 0x00F3, 0x00F4, 0x0121, 0x00F6, 0x00F7,
	0x011D, 0x00F9, 0x00FA, 0x00FB, 0x00FC, 0x016D, 0x015D, 0x02D9
};
const size_t of_iso_8859_3_table_offset =
    256 - (sizeof(of_iso_8859_3_table) / sizeof(*of_iso_8859_3_table));

static const unsigned char page0[] = {
	0xA0, 0x00, 0x00, 0xA3, 0xA4, 0x00, 0x00, 0xA7,
	0xA8, 0x00, 0x00, 0x00, 0x00, 0xAD, 0x00, 0x00,
	0xB0, 0x00, 0xB2, 0xB3, 0xB4, 0xB5, 0x00, 0xB7,
	0xB8, 0x00, 0x00, 0x00, 0x00, 0xBD, 0x00, 0x00,
	0xC0, 0xC1, 0xC2, 0x00, 0xC4, 0x00, 0x00, 0xC7,
	0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF,
	0x00, 0xD1, 0xD2, 0xD3, 0xD4, 0x00, 0xD6, 0xD7,
	0x00, 0xD9, 0xDA, 0xDB, 0xDC, 0x00, 0x00, 0xDF,
	0xE0, 0xE1, 0xE2, 0x00, 0xE4, 0x00, 0x00, 0xE7,
	0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF,
	0x00, 0xF1, 0xF2, 0xF3, 0xF4, 0x00, 0xF6, 0xF7,
	0x00, 0xF9, 0xFA, 0xFB, 0xFC, 0x00, 0x00, 0x00
};
static const uint8_t page0Start = 0xA0;

static const unsigned char page1[] = {
	0xC6, 0xE6, 0xC5, 0xE5, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0xD8, 0xF8, 0xAB, 0xBB,
	0xD5, 0xF5, 0x00, 0x00, 0xA6, 0xB6, 0xA1, 0xB1,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0xA9, 0xB9, 0x00, 0x00, 0xAC, 0xBC, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0xDE, 0xFE, 0xAA, 0xBA,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0xDD, 0xFD, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0xAF, 0xBF
};
static const uint8_t page1Start = 0x08;

static const unsigned char page2[] = {
	0xA2, 0xFF
};
static const uint8_t page2Start = 0xD8;

bool
of_unicode_to_iso_8859_3(const OFUnichar *input, unsigned char *output,
    size_t length, bool lossy)
{
	for (size_t i = 0; i < length; i++) {
		OFUnichar c = input[i];

		if OF_UNLIKELY (c > 0x7F) {
			uint8_t idx;

			if OF_UNLIKELY (c > 0xFFFF) {
				if (lossy) {
					output[i] = '?';
					continue;
				} else
					return false;
			}

			switch (c >> 8) {
			CASE_MISSING_IS_KEEP(0)
			CASE_MISSING_IS_ERROR(1)
			CASE_MISSING_IS_ERROR(2)
			default:
				if (lossy) {
					output[i] = '?';
					continue;
				} else
					return false;
			}
		} else
			output[i] = (unsigned char)c;
	}

	return true;
}
