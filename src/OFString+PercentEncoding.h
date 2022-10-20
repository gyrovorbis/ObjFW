/*
 * Copyright (c) 2008-2022 Jonathan Schleifer <js@nil.im>
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

#import "OFString.h"

OF_ASSUME_NONNULL_BEGIN

@class OFCharacterSet;

#ifdef __cplusplus
extern "C" {
#endif
extern int _OFString_PercentEncoding_reference;
#ifdef __cplusplus
}
#endif

@interface OFString (PercentEncoding)
/**
 * @brief The string with percent encoding removed.
 *
 * @throw OFInvalidFormatException The string is not in proper percent encoding
 */
@property (readonly, nonatomic) OFString *stringByRemovingPercentEncoding;

/**
 * @brief Percent-encodes a string for use in a URI, but does not escape the
 *	  specified allowed characters.
 *
 * @param allowedCharacters A character set of characters that should not be
 *			    escaped
 *
 * @return A new autoreleased string
 */
- (OFString *)stringByAddingPercentEncodingWithAllowedCharacters:
    (OFCharacterSet *)allowedCharacters;
@end

OF_ASSUME_NONNULL_END