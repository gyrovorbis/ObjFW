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

#import "OFObject.h"

OF_ASSUME_NONNULL_BEGIN

/**
 * @protocol OFMutableArchiveEntry \
 *	     OFMutableArchiveEntry.h ObjFW/OFMutableArchiveEntry.h
 *
 * @brief A class which represents a mutable entry in an archive.
 */
@protocol OFMutableArchiveEntry <OFArchiveEntry>

/**
 * @brief The file name of the entry.
 */
@property (readwrite, copy, nonatomic) OFString *fileName;

/**
 * @brief The compressed size of the entry's file.
 */
@property (readwrite, nonatomic) unsigned long long compressedSize;

/**
 * @brief The uncompressed size of the entry's file.
 */
@property (readwrite, nonatomic) unsigned long long uncompressedSize;
@end

OF_ASSUME_NONNULL_END

#import "OFMutableArchiveEntry.h"
