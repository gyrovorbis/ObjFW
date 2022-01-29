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

#import "OFTLSStream.h"

#include <openssl/bio.h>
#include <openssl/ssl.h>

OF_ASSUME_NONNULL_BEGIN

#define OFOpenSSLTLSStreamBufferSize 512

@interface OFOpenSSLTLSStream: OFTLSStream <OFStreamDelegate>
{
	bool _handshakeDone;
	SSL *_SSL;
	BIO *_readBIO, *_writeBIO;
	OFString *_host;
	char _buffer[OFOpenSSLTLSStreamBufferSize];
}
@end

OF_ASSUME_NONNULL_END