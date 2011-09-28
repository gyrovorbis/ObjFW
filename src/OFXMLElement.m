/*
 * Copyright (c) 2008, 2009, 2010, 2011
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

#include <string.h>
#include <assert.h>

#import "OFXMLElement.h"
#import "OFString.h"
#import "OFArray.h"
#import "OFDictionary.h"
#import "OFDataArray.h"
#import "OFXMLAttribute.h"
#import "OFXMLParser.h"
#import "OFXMLElementBuilder.h"
#import "OFAutoreleasePool.h"

#import "OFInvalidArgumentException.h"
#import "OFInvalidFormatException.h"
#import "OFMalformedXMLException.h"
#import "OFNotImplementedException.h"
#import "OFUnboundNamespaceException.h"

#import "macros.h"

/* References for static linking */
void _references_to_categories_of_OFXMLElement(void)
{
	_OFXMLElement_Serialization_reference = 1;
}

@interface OFXMLElement_OFXMLElementBuilderDelegate: OFObject
{
@public
	OFXMLElement *element;
}
@end

@implementation OFXMLElement_OFXMLElementBuilderDelegate
- (void)elementBuilder: (OFXMLElementBuilder*)builder
       didBuildElement: (OFXMLElement*)element_
{
	/*
	 * Make sure we don't take whitespaces before or after the root element
	 * into account.
	 */
	if ([element_ name] != nil) {
		assert(element == nil);
		element = [element_ retain];
	}
}

- (void)dealloc
{
	[element release];

	[super dealloc];
}
@end

@implementation OFXMLElement
+ elementWithName: (OFString*)name
{
	return [[[self alloc] initWithName: name] autorelease];
}

+ elementWithName: (OFString*)name
      stringValue: (OFString*)stringValue
{
	return [[[self alloc] initWithName: name
			       stringValue: stringValue] autorelease];
}

+ elementWithName: (OFString*)name
	namespace: (OFString*)ns
{
	return [[[self alloc] initWithName: name
				 namespace: ns] autorelease];
}

+ elementWithName: (OFString*)name
	namespace: (OFString*)ns
      stringValue: (OFString*)stringValue
{
	return [[[self alloc] initWithName: name
				 namespace: ns
			       stringValue: stringValue] autorelease];
}

+ elementWithCharacters: (OFString*)characters
{
	return [[[self alloc] initWithCharacters: characters] autorelease];
}

+ elementWithCDATA: (OFString*)CDATA
{
	return [[[self alloc] initWithCDATA: CDATA] autorelease];
}

+ elementWithComment: (OFString*)comment
{
	return [[[self alloc] initWithComment: comment] autorelease];
}

+ elementWithElement: (OFXMLElement*)element
{
	return [[[self alloc] initWithElement: element] autorelease];
}

+ elementWithXMLString: (OFString*)string
{
	return [[[self alloc] initWithXMLString: string] autorelease];
}

+ elementWithFile: (OFString*)path
{
	return [[[self alloc] initWithFile: path] autorelease];
}

- init
{
	Class c = isa;
	[self release];
	@throw [OFNotImplementedException exceptionWithClass: c
						    selector: _cmd];
}

- initWithName: (OFString*)name_
{
	return [self initWithName: name_
			namespace: nil
		      stringValue: nil];
}

- initWithName: (OFString*)name_
   stringValue: (OFString*)stringValue
{
	return [self initWithName: name_
			namespace: nil
		      stringValue: stringValue];
}

- initWithName: (OFString*)name_
     namespace: (OFString*)ns_
{
	return [self initWithName: name_
			namespace: ns_
		      stringValue: nil];
}

- initWithName: (OFString*)name_
     namespace: (OFString*)ns_
   stringValue: (OFString*)stringValue
{
	self = [super init];

	@try {
		if (name_ == nil)
			@throw [OFInvalidArgumentException
			    exceptionWithClass: isa
				      selector: _cmd];

		name = [name_ copy];
		ns = [ns_ copy];

		namespaces = [[OFMutableDictionary alloc]
		    initWithKeysAndObjects:
		    @"http://www.w3.org/XML/1998/namespace", @"xml",
		    @"http://www.w3.org/2000/xmlns/", @"xmlns", nil];

		if (stringValue != nil)
			[self setStringValue: stringValue];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithCharacters: (OFString*)characters_
{
	self = [super init];

	@try {
		if (characters_ == nil)
			@throw [OFInvalidArgumentException
			    exceptionWithClass: isa
				      selector: _cmd];

		characters = [characters_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithCDATA: (OFString*)CDATA_
{
	self = [super init];

	@try {
		if (CDATA_ == nil)
			@throw [OFInvalidArgumentException
			    exceptionWithClass: isa
				      selector: _cmd];

		CDATA = [CDATA_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithComment: (OFString*)comment_
{
	self = [super init];

	@try {
		if (comment_ == nil)
			@throw [OFInvalidArgumentException
			    exceptionWithClass: isa
				      selector: _cmd];

		comment = [comment_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithElement: (OFXMLElement*)element
{
	self = [super init];

	@try {
		if (element == nil)
			@throw [OFInvalidArgumentException
			    exceptionWithClass: isa
				      selector: _cmd];

		name = [element->name copy];
		ns = [element->ns copy];
		defaultNamespace = [element->defaultNamespace copy];
		attributes = [element->attributes mutableCopy];
		namespaces = [element->namespaces mutableCopy];
		children = [element->children mutableCopy];
		characters = [element->characters copy];
		CDATA = [element->CDATA copy];
		comment = [element->comment copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithXMLString: (OFString*)string
{
	OFAutoreleasePool *pool;
	OFXMLParser *parser;
	OFXMLElementBuilder *builder;
	OFXMLElement_OFXMLElementBuilderDelegate *delegate;
	Class c;

	c = isa;
	[self release];

	if (string == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	pool = [[OFAutoreleasePool alloc] init];

	parser = [OFXMLParser parser];
	builder = [OFXMLElementBuilder elementBuilder];
	delegate = [[[OFXMLElement_OFXMLElementBuilderDelegate alloc] init]
	    autorelease];

	[parser setDelegate: builder];
	[builder setDelegate: delegate];

	[parser parseString: string];

	if (![parser finishedParsing])
		@throw [OFMalformedXMLException exceptionWithClass: c
							    parser: parser];

	self = [delegate->element retain];

	[pool release];

	return self;
}

- initWithFile: (OFString*)path
{
	OFAutoreleasePool *pool;
	OFXMLParser *parser;
	OFXMLElementBuilder *builder;
	OFXMLElement_OFXMLElementBuilderDelegate *delegate;
	Class c;

	c = isa;
	[self release];

	pool = [[OFAutoreleasePool alloc] init];

	parser = [OFXMLParser parser];
	builder = [OFXMLElementBuilder elementBuilder];
	delegate = [[[OFXMLElement_OFXMLElementBuilderDelegate alloc] init]
	    autorelease];

	[parser setDelegate: builder];
	[builder setDelegate: delegate];

	[parser parseFile: path];

	if (![parser finishedParsing])
		@throw [OFMalformedXMLException exceptionWithClass: c
							    parser: parser];

	self = [delegate->element retain];

	[pool release];

	return self;
}

- initWithSerialization: (OFXMLElement*)element
{
	self = [super init];

	@try {
		OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
		OFXMLElement *attributesElement, *namespacesElement;
		OFXMLElement *childrenElement;

		if (![[element name] isEqual: [self className]] ||
		    ![[element namespace] isEqual: OF_SERIALIZATION_NS])
			@throw [OFInvalidArgumentException
			    exceptionWithClass: isa
				      selector: _cmd];

		name = [[[element attributeForName: @"name"] stringValue] copy];
		ns = [[[element attributeForName: @"namespace"] stringValue]
		    copy];
		defaultNamespace = [[[element attributeForName:
		    @"defaultNamespace"] stringValue] copy];
		characters = [[[element
		    elementForName: @"characters"
			 namespace: OF_SERIALIZATION_NS] stringValue] copy];
		CDATA = [[[element
		    elementForName: @"CDATA"
			 namespace: OF_SERIALIZATION_NS] stringValue] copy];
		comment = [[[element
		    elementForName: @"comment"
			 namespace: OF_SERIALIZATION_NS] stringValue] copy];

		attributesElement = [[[element
		    elementForName: @"attributes"
			 namespace: OF_SERIALIZATION_NS] elementsForNamespace:
		    OF_SERIALIZATION_NS] firstObject];
		namespacesElement = [[[element
		    elementForName: @"namespaces"
			 namespace: OF_SERIALIZATION_NS] elementsForNamespace:
		    OF_SERIALIZATION_NS] firstObject];
		childrenElement = [[[element
		    elementForName: @"children"
			 namespace: OF_SERIALIZATION_NS] elementsForNamespace:
		    OF_SERIALIZATION_NS] firstObject];

		attributes = [[attributesElement objectByDeserializing] copy];
		namespaces = [[namespacesElement objectByDeserializing] copy];
		children = [[childrenElement objectByDeserializing] copy];

		if (!((name != nil || ns != nil || defaultNamespace != nil ||
		    [attributes count] > 0 || [namespaces count] > 0 ||
		    [children count] > 0) ^ (characters != nil) ^
		    (CDATA != nil) ^ (comment != nil)))
			@throw [OFInvalidArgumentException
			    exceptionWithClass: isa
				      selector: _cmd];

		[pool release];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)setName: (OFString*)name_
{
	if (name == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	OF_SETTER(name, name_, YES, YES)
}

- (OFString*)name
{
	return [[name copy] autorelease];
}

- (void)setNamespace: (OFString*)ns_
{
	if (name == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	OF_SETTER(ns, ns_, YES, YES)
}

- (OFString*)namespace
{
	return [[ns copy] autorelease];
}

- (OFArray*)attributes
{
	return [[attributes copy] autorelease];
}

- (void)setChildren: (OFArray*)children_
{
	OFMutableArray *new = [children_ mutableCopy];
	[children release];
	children = new;
}

- (OFArray*)children
{
	return [[children copy] autorelease];
}

- (void)setStringValue: (OFString*)stringValue
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];

	[self setChildren: [OFArray arrayWithObject:
	    [OFXMLElement elementWithCharacters: stringValue]]];

	[pool release];
}

- (OFString*)stringValue
{
	OFAutoreleasePool *pool;
	OFMutableString *ret;
	OFXMLElement **cArray;
	size_t i, count = [children count];

	if (count == 0)
		return @"";

	ret = [OFMutableString string];
	cArray = [children cArray];
	pool = [[OFAutoreleasePool alloc] init];

	for (i = 0; i < count; i++) {
		if (cArray[i]->characters != nil)
			[ret appendString: cArray[i]->characters];
		else if (cArray[i]->CDATA != nil)
			[ret appendString: cArray[i]->CDATA];
		else if (cArray[i]->comment == nil) {
			[ret appendString: [cArray[i] stringValue]];
			[pool releaseObjects];
		}
	}

	[ret makeImmutable];

	[pool release];

	return ret;
}

- (OFString*)_XMLStringWithParent: (OFXMLElement*)parent
		       namespaces: (OFDictionary*)allNamespaces
		      indentation: (unsigned int)indentation
			    level: (size_t)level
{
	OFAutoreleasePool *pool, *pool2;
	char *cString;
	size_t length, i, j, attributesCount;
	OFString *prefix, *parentPrefix;
	OFXMLAttribute **attributesCArray;
	OFString *ret;
	OFString *defaultNS;

	if (characters != nil)
		return [characters stringByXMLEscaping];

	if (CDATA != nil)
		return [OFString stringWithFormat: @"<![CDATA[%@]]>", CDATA];

	if (comment != nil) {
		if (indentation > 0 && level > 0) {
			char *whitespaces = [self
			    allocMemoryWithSize: (level * indentation) + 1];
			memset(whitespaces, ' ', level * indentation);
			whitespaces[level * indentation] = 0;

			@try {
				ret = [OFString
				    stringWithFormat: @"%s<!--%@-->",
						      whitespaces, comment];
			} @finally {
				[self freeMemory: whitespaces];
			}
		} else
			ret = [OFString stringWithFormat: @"<!--%@-->",
							  comment];

		return ret;
	}

	pool = [[OFAutoreleasePool alloc] init];

	parentPrefix = [allNamespaces objectForKey:
	    (parent != nil && parent->ns != nil ? parent->ns : (OFString*)@"")];

	/* Add the namespaces of the current element */
	if (allNamespaces != nil) {
		OFEnumerator *keyEnumerator = [namespaces keyEnumerator];
		OFEnumerator *objectEnumerator = [namespaces objectEnumerator];
		OFMutableDictionary *tmp;
		id key, object;

		tmp = [[allNamespaces mutableCopy] autorelease];

		while ((key = [keyEnumerator nextObject]) != nil &&
		    (object = [objectEnumerator nextObject]) != nil)
			[tmp setObject: object
				forKey: key];

		allNamespaces = tmp;
	} else
		allNamespaces = namespaces;

	prefix = [allNamespaces objectForKey:
	    (ns != nil ? ns : (OFString*)@"")];

	if (parent != nil && parent->ns != nil && parentPrefix == nil)
		defaultNS = parent->ns;
	else if (parent != nil && parent->defaultNamespace != nil)
		defaultNS = parent->defaultNamespace;
	else
		defaultNS = defaultNamespace;

	i = 0;
	length = [name UTF8StringLength] + 3 + (level * indentation);
	cString = [self allocMemoryWithSize: length];

	memset(cString + i, ' ', level * indentation);
	i += level * indentation;

	/* Start of tag */
	cString[i++] = '<';

	if (prefix != nil && ![ns isEqual: defaultNS]) {
		length += [prefix UTF8StringLength] + 1;
		@try {
			cString = [self resizeMemory: cString
					      toSize: length];
		} @catch (id e) {
			[self freeMemory: cString];
			@throw e;
		}

		memcpy(cString + i, [prefix UTF8String],
		    [prefix UTF8StringLength]);
		i += [prefix UTF8StringLength];
		cString[i++] = ':';
	}

	memcpy(cString + i, [name UTF8String], [name UTF8StringLength]);
	i += [name UTF8StringLength];

	/* xmlns if necessary */
	if (prefix == nil && ((ns != nil && ![ns isEqual: defaultNS]) ||
	    (ns == nil && defaultNS != nil))) {
		length += [ns UTF8StringLength] + 9;
		@try {
			cString = [self resizeMemory: cString
					      toSize: length];
		} @catch (id e) {
			[self freeMemory: cString];
			@throw e;
		}

		memcpy(cString + i, " xmlns='", 8);
		i += 8;
		memcpy(cString + i, [ns UTF8String], [ns UTF8StringLength]);
		i += [ns UTF8StringLength];
		cString[i++] = '\'';
	}

	/* Attributes */
	attributesCArray = [attributes cArray];
	attributesCount = [attributes count];

	pool2 = [[OFAutoreleasePool alloc] init];
	for (j = 0; j < attributesCount; j++) {
		OFString *attributeName = [attributesCArray[j] name];
		OFString *attributePrefix = nil;
		OFString *tmp =
		    [[attributesCArray[j] stringValue] stringByXMLEscaping];

		if ([attributesCArray[j] namespace] != nil &&
		    (attributePrefix = [allNamespaces objectForKey:
		    [attributesCArray[j] namespace]]) == nil)
			@throw [OFUnboundNamespaceException
			    exceptionWithClass: isa
				     namespace: [attributesCArray[j]
						    namespace]];

		length += [attributeName UTF8StringLength] +
		    (attributePrefix != nil ?
		    [attributePrefix UTF8StringLength] + 1 : 0) +
		    [tmp UTF8StringLength] + 4;

		@try {
			cString = [self resizeMemory: cString
					      toSize: length];
		} @catch (id e) {
			[self freeMemory: cString];
			@throw e;
		}

		cString[i++] = ' ';
		if (attributePrefix != nil) {
			memcpy(cString + i, [attributePrefix UTF8String],
			    [attributePrefix UTF8StringLength]);
			i += [attributePrefix UTF8StringLength];
			cString[i++] = ':';
		}
		memcpy(cString + i, [attributeName UTF8String],
		    [attributeName UTF8StringLength]);
		i += [attributeName UTF8StringLength];
		cString[i++] = '=';
		cString[i++] = '\'';
		memcpy(cString + i, [tmp UTF8String], [tmp UTF8StringLength]);
		i += [tmp UTF8StringLength];
		cString[i++] = '\'';

		[pool2 releaseObjects];
	}

	/* Childen */
	if (children != nil) {
		OFXMLElement **childrenCArray = [children cArray];
		size_t childrenCount = [children count];
		OFDataArray *tmp = [OFDataArray dataArray];
		BOOL indent;

		if (indentation > 0) {
			indent = YES;

			for (j = 0; j < childrenCount; j++) {
				if (childrenCArray[j]->characters != nil ||
				    childrenCArray[j]->CDATA != nil) {
					indent = NO;
					break;
				}
			}
		} else
			indent = NO;

		for (j = 0; j < childrenCount; j++) {
			OFString *child;

			if (indent)
				[tmp addItem: "\n"];

			child = [childrenCArray[j]
			    _XMLStringWithParent: self
				      namespaces: allNamespaces
				     indentation: (indent ? indentation : 0)
					   level: level + 1];

			[tmp addNItems: [child UTF8StringLength]
			    fromCArray: [child UTF8String]];
		}

		if (indent)
			[tmp addItem: "\n"];

		length += [tmp count] + [name UTF8StringLength] + 2 +
		    (indent ? level * indentation : 0);
		@try {
			cString = [self resizeMemory: cString
					      toSize: length];
		} @catch (id e) {
			[self freeMemory: cString];
			@throw e;
		}

		cString[i++] = '>';

		memcpy(cString + i, [tmp cArray], [tmp count]);
		i += [tmp count];

		if (indent) {
			memset(cString + i, ' ', level * indentation);
			i += level * indentation;
		}

		cString[i++] = '<';
		cString[i++] = '/';
		if (prefix != nil) {
			length += [prefix UTF8StringLength] + 1;
			@try {
				cString = [self resizeMemory: cString
						      toSize: length];
			} @catch (id e) {
				[self freeMemory: cString];
				@throw e;
			}

			memcpy(cString + i, [prefix UTF8String],
			    [prefix UTF8StringLength]);
			i += [prefix UTF8StringLength];
			cString[i++] = ':';
		}
		memcpy(cString + i, [name UTF8String], [name UTF8StringLength]);
		i += [name UTF8StringLength];
	} else
		cString[i++] = '/';

	cString[i++] = '>';
	assert(i == length);

	[pool release];

	@try {
		ret = [OFString stringWithUTF8String: cString
					      length: length];
	} @finally {
		[self freeMemory: cString];
	}
	return ret;
}

- (OFString*)XMLString
{
	return [self _XMLStringWithParent: nil
			       namespaces: nil
			      indentation: 0
				    level: 0];
}

- (OFString*)XMLStringWithIndentation: (unsigned int)indentation
{
	return [self _XMLStringWithParent: nil
			       namespaces: nil
			      indentation: indentation
				    level: 0];
}

- (OFXMLElement*)XMLElementBySerializing
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFXMLElement *element;

	element = [OFXMLElement elementWithName: [self className]
				      namespace: OF_SERIALIZATION_NS];

	if (name != nil)
		[element addAttributeWithName: @"name"
				  stringValue: name];

	if (ns != nil)
		[element addAttributeWithName: @"namespace"
				  stringValue: ns];

	if (defaultNamespace != nil)
		[element addAttributeWithName: @"defaultNamespace"
				  stringValue: defaultNamespace];

	if (attributes != nil) {
		OFXMLElement *attributesElement;

		attributesElement =
		    [OFXMLElement elementWithName: @"attributes"
					namespace: OF_SERIALIZATION_NS];
		[attributesElement addChild:
		    [attributes XMLElementBySerializing]];
		[element addChild: attributesElement];
	}

	if (namespaces != nil) {
		OFXMLElement *namespacesElement;

		namespacesElement =
		    [OFXMLElement elementWithName: @"namespaces"
					namespace: OF_SERIALIZATION_NS];
		[namespacesElement addChild:
		    [namespaces XMLElementBySerializing]];
		[element addChild: namespacesElement];
	}

	if (children != nil) {
		OFXMLElement *childrenElement;

		childrenElement =
		    [OFXMLElement elementWithName: @"children"
					namespace: OF_SERIALIZATION_NS];
		[childrenElement addChild: [children XMLElementBySerializing]];
		[element addChild: childrenElement];
	}

	if (characters != nil)
		[element addChild:
		    [OFXMLElement elementWithName: @"characters"
					namespace: OF_SERIALIZATION_NS
				      stringValue: characters]];

	if (CDATA != nil) {
		OFXMLElement *CDATAElement =
		    [OFXMLElement elementWithName: @"CDATA"
					namespace: OF_SERIALIZATION_NS];
		[CDATAElement addChild: [OFXMLElement elementWithCDATA: CDATA]];
		[element addChild: CDATAElement];
	}

	if (comment != nil)
		[element addChild:
		    [OFXMLElement elementWithName: @"comment"
					namespace: OF_SERIALIZATION_NS
				      stringValue: comment]];

	[element retain];
	[pool release];
	[element autorelease];

	return element;
}

- (void)addAttribute: (OFXMLAttribute*)attribute
{
	if (name == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	if (attributes == nil)
		attributes = [[OFMutableArray alloc] init];

	if ([self attributeForName: attribute->name
			 namespace: attribute->ns] == nil)
		[attributes addObject: attribute];
}

- (void)addAttributeWithName: (OFString*)name_
		 stringValue: (OFString*)stringValue
{
	[self addAttributeWithName: name_
			 namespace: nil
		       stringValue: stringValue];
}

- (void)addAttributeWithName: (OFString*)name_
		   namespace: (OFString*)ns_
		 stringValue: (OFString*)stringValue
{
	OFAutoreleasePool *pool;

	if (name == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	pool = [[OFAutoreleasePool alloc] init];
	[self addAttribute: [OFXMLAttribute attributeWithName: name_
						    namespace: ns_
						  stringValue: stringValue]];
	[pool release];
}

- (OFXMLAttribute*)attributeForName: (OFString*)attributeName
{
	OFXMLAttribute **cArray = [attributes cArray];
	size_t i, count = [attributes count];

	for (i = 0; i < count; i++)
		if (cArray[i]->ns == nil &&
		    [cArray[i]->name isEqual: attributeName])
			return cArray[i];

	return nil;
}

- (OFXMLAttribute*)attributeForName: (OFString*)attributeName
			  namespace: (OFString*)attributeNS
{
	OFXMLAttribute **cArray;
	size_t i, count;

	if (attributeNS == nil)
		return [self attributeForName: attributeName];

	cArray = [attributes cArray];
	count = [attributes count];

	for (i = 0; i < count; i++)
		if ([cArray[i]->ns isEqual: attributeNS] &&
		    [cArray[i]->name isEqual: attributeName])
			return cArray[i];

	return nil;
}

- (void)removeAttributeForName: (OFString*)attributeName
{
	OFXMLAttribute **cArray = [attributes cArray];
	size_t i, count = [attributes count];

	for (i = 0; i < count; i++) {
		if (cArray[i]->ns == nil &&
		    [cArray[i]->name isEqual: attributeName]) {
			[attributes removeObjectAtIndex: i];

			return;
		}
	}
}

- (void)removeAttributeForName: (OFString*)attributeName
		     namespace: (OFString*)attributeNS
{
	OFXMLAttribute **cArray;
	size_t i, count;

	if (attributeNS == nil)
		return [self removeAttributeForName: attributeName];

	cArray = [attributes cArray];
	count = [attributes count];

	for (i = 0; i < count; i++) {
		if ([cArray[i]->ns isEqual: attributeNS] &&
		    [cArray[i]->name isEqual: attributeName]) {
			[attributes removeObjectAtIndex: i];
				return;
		}
	}
}

- (void)setPrefix: (OFString*)prefix
     forNamespace: (OFString*)ns_
{
	if (name == nil || prefix == nil || [prefix isEqual: @""])
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];
	if (ns_ == nil)
		ns_ = @"";

	[namespaces setObject: prefix
		       forKey: ns_];
}

- (void)bindPrefix: (OFString*)prefix
      forNamespace: (OFString*)ns_
{
	[self setPrefix: prefix
	   forNamespace: ns_];
	[self addAttributeWithName: prefix
			 namespace: @"http://www.w3.org/2000/xmlns/"
		       stringValue: ns_];
}

- (OFString*)defaultNamespace
{
	if (name == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	return [[defaultNamespace retain] autorelease];
}

- (void)setDefaultNamespace: (OFString*)ns_
{
	if (name == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	OFString *old = defaultNamespace;
	defaultNamespace = [ns_ copy];
	[old release];
}

- (void)addChild: (OFXMLElement*)child
{
	if (name == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	if (children == nil)
		children = [[OFMutableArray alloc] init];

	[children addObject: child];
}

- (void)removeChild: (OFXMLElement*)child
{
	if (name == nil)
		@throw [OFInvalidArgumentException exceptionWithClass: isa
							     selector: _cmd];

	[children removeObject: child];
}

- (OFXMLElement*)elementForName: (OFString*)elementName
{
	return [[self elementsForName: elementName] firstObject];
}

- (OFXMLElement*)elementForName: (OFString*)elementName
		      namespace: (OFString*)elementNS
{
	return [[self elementsForName: elementName
			    namespace: elementNS] firstObject];
}

- (OFArray*)elements
{
	OFMutableArray *ret = [OFMutableArray array];
	OFXMLElement **cArray = [children cArray];
	size_t i, count = [children count];

	for (i = 0; i < count; i++)
		if (cArray[i]->name != nil)
			[ret addObject: cArray[i]];

	[ret makeImmutable];

	return ret;
}

- (OFArray*)elementsForName: (OFString*)elementName
{
	OFMutableArray *ret = [OFMutableArray array];
	OFXMLElement **cArray = [children cArray];
	size_t i, count = [children count];

	for (i = 0; i < count; i++)
		if (cArray[i]->ns == nil &&
		    [cArray[i]->name isEqual: elementName])
			[ret addObject: cArray[i]];

	[ret makeImmutable];

	return ret;
}

- (OFArray*)elementsForNamespace: (OFString*)elementNS
{
	OFMutableArray *ret = [OFMutableArray array];
	OFXMLElement **cArray = [children cArray];
	size_t i, count = [children count];

	for (i = 0; i < count; i++)
		if (cArray[i]->name != nil &&
		    [cArray[i]->ns isEqual: elementNS])
			[ret addObject: cArray[i]];

	[ret makeImmutable];

	return ret;
}

- (OFArray*)elementsForName: (OFString*)elementName
		  namespace: (OFString*)elementNS
{
	OFMutableArray *ret;
	OFXMLElement **cArray;
	size_t i, count;

	if (elementNS == nil)
		return [self elementsForName: elementName];

	ret = [OFMutableArray array];
	cArray = [children cArray];
	count = [children count];

	for (i = 0; i < count; i++)
		if ([cArray[i]->ns isEqual: elementNS] &&
		    [cArray[i]->name isEqual: elementName])
			[ret addObject: cArray[i]];

	[ret makeImmutable];

	return ret;
}

- (BOOL)isEqual: (id)object
{
	OFXMLElement *otherElement;

	if (![object isKindOfClass: [OFXMLElement class]])
		return NO;

	otherElement = object;

	if (otherElement->name != name && ![otherElement->name isEqual: name])
		return NO;
	if (otherElement->ns != ns && ![otherElement->ns isEqual: ns])
		return NO;
	if (otherElement->defaultNamespace != defaultNamespace &&
	    ![otherElement->defaultNamespace isEqual: defaultNamespace])
		return NO;
	if (otherElement->attributes != attributes &&
	    ![otherElement->attributes isEqual: attributes])
		return NO;
	if (otherElement->namespaces != namespaces &&
	    ![otherElement->namespaces isEqual: namespaces])
		return NO;
	if (otherElement->children != children &&
	    ![otherElement->children isEqual: children])
		return NO;
	if (otherElement->characters != characters &&
	    ![otherElement->characters isEqual: characters])
		return NO;
	if (otherElement->CDATA != CDATA &&
	    ![otherElement->CDATA isEqual: CDATA])
		return NO;
	if (otherElement->comment != comment &&
	    ![otherElement->comment isEqual: comment])
		return NO;

	return YES;
}

- (uint32_t)hash
{
	uint32_t hash;

	OF_HASH_INIT(hash);

	OF_HASH_ADD_HASH(hash, [name hash]);
	OF_HASH_ADD_HASH(hash, [ns hash]);
	OF_HASH_ADD_HASH(hash, [defaultNamespace hash]);
	OF_HASH_ADD_HASH(hash, [attributes hash]);
	OF_HASH_ADD_HASH(hash, [namespaces hash]);
	OF_HASH_ADD_HASH(hash, [children hash]);
	OF_HASH_ADD_HASH(hash, [characters hash]);
	OF_HASH_ADD_HASH(hash, [CDATA hash]);
	OF_HASH_ADD_HASH(hash, [comment hash]);

	OF_HASH_FINALIZE(hash);

	return hash;
}

- copy
{
	return [[isa alloc] initWithElement: self];
}

- (void)dealloc
{
	[name release];
	[ns release];
	[defaultNamespace release];
	[attributes release];
	[namespaces release];
	[children release];
	[characters release];
	[CDATA release];
	[comment release];

	[super dealloc];
}
@end
