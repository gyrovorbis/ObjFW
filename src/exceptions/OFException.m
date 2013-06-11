/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013
 *   Jonathan Schleifer <js@webkeks.org>
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

#include <stdlib.h>

#ifdef HAVE_DLFCN_H
# include <dlfcn.h>
#endif

#import "OFException.h"
#import "OFString.h"
#import "OFArray.h"

#import "autorelease.h"

struct _Unwind_Context;
typedef enum {
	_URC_OK		  = 0,
	_URC_END_OF_STACK = 5
}_Unwind_Reason_Code;

struct backtrace_ctx {
	void **backtrace;
	uint_fast8_t i;
};

extern _Unwind_Reason_Code _Unwind_Backtrace(
    _Unwind_Reason_Code(*)(struct _Unwind_Context*, void*), void*);
extern uintptr_t _Unwind_GetIP(struct _Unwind_Context*);

static _Unwind_Reason_Code
backtrace_callback(struct _Unwind_Context *ctx, void *data)
{
	struct backtrace_ctx *bt = data;

	if (bt->i < OF_BACKTRACE_SIZE) {
		bt->backtrace[bt->i++] = (void*)_Unwind_GetIP(ctx);
		return _URC_OK;
	}

	return _URC_END_OF_STACK;
}

@implementation OFException
+ (instancetype)exceptionWithClass: (Class)class
{
	return [[[self alloc] initWithClass: class] autorelease];
}

- init
{
	@try {
		[self doesNotRecognizeSelector: _cmd];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	abort();
}

- initWithClass: (Class)class
{
	struct backtrace_ctx ctx;

	self = [super init];

	_inClass = class;

	ctx.backtrace = _backtrace;
	ctx.i = 0;
	_Unwind_Backtrace(backtrace_callback, &ctx);

	return self;
}

- (Class)inClass
{
	return _inClass;
}

- (OFString*)description
{
	return [OFString stringWithFormat:
	    @"An exception of class %@ occurred in class %@!",
	    object_getClass(self), _inClass];
}

- (OFArray*)backtrace
{
	OFMutableArray *backtrace = [OFMutableArray array];
	void *pool = objc_autoreleasePoolPush();
	uint_fast8_t i;

	for (i = 0; i < OF_BACKTRACE_SIZE && _backtrace[i] != NULL; i++) {
#ifdef HAVE_DLFCN_H
		Dl_info info;

		if (dladdr(_backtrace[i], &info)) {
			ptrdiff_t offset = (char*)_backtrace[i] -
			    (char*)info.dli_saddr;

			if (info.dli_sname == NULL)
				info.dli_sname = "??";

			[backtrace addObject:
			    [OFString stringWithFormat: @"%p <%s+%td> at %s",
							_backtrace[i],
							info.dli_sname, offset,
							info.dli_fname]];
		} else
#endif
			[backtrace addObject:
			    [OFString stringWithFormat: @"%p", _backtrace[i]]];
	}

	objc_autoreleasePoolPop(pool);

	[backtrace makeImmutable];

	return backtrace;
}
@end
