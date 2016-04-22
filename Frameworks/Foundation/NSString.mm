//******************************************************************************
//
// Copyright (c) 2015 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#include "Starboard.h"
#include "StubReturn.h"
#include <Foundation/NSError.h>
#include <Foundation/NSString.h>
#include <Foundation/NSLocale.h>
#include <Foundation/NSMutableData.h>
#include <Foundation/NSMutableDictionary.h>
#include <Foundation/NSRegularExpression.h>
#include <CoreFoundation/CoreFoundation.h>

#include "ForFoundationOnly.h"
#include "LoggingNative.h"
#include "NSStringPlaceholder.h"
#include "NSRaise.h"
#include "CFFoundationInternal.h"
#include "BridgeHelpers.h"
#include "NSStringInternal.h"

#include <vector>
#include <memory>
#include <string>

static const wchar_t* TAG = L"NSString";

NSString* const NSParseErrorException = @"NSParseErrorException";
NSString* const NSCharacterConversionException = @"NSCharacterConversionException";

id error(id obj, char* buf, const char* error, ...) {
    TraceError(TAG, L"propertyListFromStrings error: %hs", buf);

    return nil;
}

static unichar SwapWord(unichar c) {
    return (c >> 8) | ((c & 0xFF) << 8);
}

static unichar PickWord(unichar c) {
    return c;
}

@implementation NSString

/**
 @Status Interoperable
*/
+ ALLOC_PLACEHOLDER_SUBCLASS_WITH_ZONE(NSString, NSStringPlaceholder);

/**
 @Status Interoperable
*/
+ (instancetype)stringWithString:(NSString*)str {
    return [[[self alloc] initWithString:str] autorelease];
}

/**
 @Status Interoperable
*/
- (NSString*)stringByAppendingString:(NSString*)str {
    NSMutableString* mutableCopy = [self mutableCopy];
    [mutableCopy appendString:str];
    return [mutableCopy autorelease];
}

/**
 @Status Caveat
 @Notes Positional formatting is not supported.
*/
- (NSString*)stringByAppendingFormat:(NSString*)formatStr, ... {
    va_list reader;
    va_start(reader, formatStr);

    NSString* formattedString = [[NSString alloc] initWithFormat:formatStr arguments:reader];
    return [self stringByAppendingString:formattedString];
}

/**
 @Status Stub
*/
- (NSString*)stringByAbbreviatingWithTildeInPath {
    UNIMPLEMENTED();
    return [[self copy] autorelease];
}

/**
 @Status Interoperable
*/
+ (NSString*)string {
    return @"";
}

/**
 @Status Interoperable
*/
+ (instancetype)stringWithFormat:(NSString*)formatStr, ... {
    va_list reader;
    va_start(reader, formatStr);

    NSString* objRet = [[self alloc] initWithFormat:formatStr arguments:reader];
    va_end(reader);

    return [objRet autorelease];
}

/**
 @Status Interoperable
*/
+ (instancetype)stringWithCString:(const char*)str {
    return [[[self alloc] initWithCString:str] autorelease];
}

/**
 @Status Caveat
 @Notes Limited encodings available
*/
+ (instancetype)stringWithCString:(const char*)str encoding:(NSStringEncoding)encoding {
    return [[[self alloc] initWithCString:str encoding:encoding] autorelease];
}

/**
 @Status Interoperable
*/
+ (instancetype)stringWithUTF8String:(const char*)str {
    return [[[self alloc] initWithUTF8String:str] autorelease];
}

/**
 @Status Interoperable
*/
+ (instancetype)stringWithCString:(const char*)str length:(NSUInteger)length {
    return [[[self alloc] initWithCString:str length:length] autorelease];
}

/**
 @Status Interoperable
*/
+ (instancetype)stringWithCharacters:(const unichar*)bytes length:(unsigned)length {
    return [[[self alloc] initWithCharacters:bytes length:length] autorelease];
}

/**
 @Status Interoperable
*/
- (id)initWithCoder:(NSCoder*)coder {
    NSString* str = [coder decodeObjectForKey:@"NS.string"];

    if (str != nil) {
        return [self initWithString:str];
    } else {
        return [self init];
    }
}

/**
 @Status Interoperable
*/
- (instancetype)init {
    self = [super init];
    return self;
}

/**
 @Status Interoperable
*/
- (instancetype)initWithCString:(const char*)cStr {
    return [self initWithCString:cStr length:strlen(cStr)];
}

/**
 @Status Interoperable
*/
- (instancetype)initWithCString:(const char*)cStr length:(NSUInteger)length {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Interoperable
*/
- (instancetype)initWithUTF8String:(const char*)utf8str {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Interoperable
*/
- (instancetype)initWithFormat:(NSString*)formatStr, ... {
    va_list reader;
    va_start(reader, formatStr);

    self = [self initWithFormat:formatStr arguments:reader];
    va_end(reader);

    return self;
}

/**
 @Status Interoperable
*/
- (instancetype)initWithFormat:(id)formatStr arguments:(va_list)pReader {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Interoperable
*/
- (instancetype)initWithString:(NSString*)otherStr {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Caveat
 @Notes Limited encodings available
*/
- (instancetype)initWithData:(NSData*)data encoding:(NSStringEncoding)encoding {
    return [self initWithBytes:[data bytes] length:[data length] encoding:encoding];
}

/**
 @Status Caveat
 @Notes Limited encodings available
*/
- (instancetype)initWithBytes:(const void*)bytes length:(unsigned)length encoding:(NSStringEncoding)encoding {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Caveat
 @Notes Limited encodings available.  CRT types must match when freeWhenDone=YES
*/
- (instancetype)initWithBytesNoCopy:(void*)bytes
                             length:(unsigned)length
                           encoding:(NSStringEncoding)encoding
                       freeWhenDone:(BOOL)freeWhenDone {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Interoperable
*/
- (instancetype)initWithCharacters:(const WORD*)bytes length:(NSUInteger)length {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Caveat
 @Notes CRT types must match when freeWhenDone=YES
*/
- (instancetype)initWithCharactersNoCopy:(unichar*)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Caveat
 @Notes Limited encodings available
*/
- (instancetype)initWithCString:(const char*)bytes encoding:(NSStringEncoding)encoding {
    // Derived classes are required to implement this initializer.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Interoperable
*/
- (instancetype)initWithContentsOfFile:(NSString*)path {
    if (path == nil) {
        TraceVerbose(TAG, L"NSString: path = nil!");
        return nil;
    }

    const char* fileName = (const char*)[path UTF8String];
    TraceVerbose(TAG, L"NSString:opening %hs", fileName);

    EbrFile* fpIn = EbrFopen(fileName, "rb");
    if (!fpIn) {
        TraceVerbose(TAG, L"Couldn't open file %hs", fileName);
        return nil;
    }

    WORD type = 0;
    NSStringEncoding encoding = NSASCIIStringEncoding;
    EbrFread(&type, 1, 2, fpIn);

    if (type == 0xFEFF) {
        encoding = NSUnicodeStringEncoding;
    } else if (type == 0xFFFE) {
        encoding = NSUnicodeStringEncoding;
        assert(0);
        *((char*)0xBAADF00D) = 0;
    } else {
        EbrFseek(fpIn, 0, SEEK_SET);
    }

    int cur = EbrFseek(fpIn, 0, SEEK_CUR);
    EbrFseek(fpIn, 0, SEEK_END);
    int len = EbrFtell(fpIn);
    EbrFseek(fpIn, cur, SEEK_SET);
    std::vector<char> bytes(len);

    len = EbrFread(&(bytes[0]), 1, len, fpIn);
    EbrFclose(fpIn);

    NSData* data = [[NSData alloc] initWithBytesNoCopy:bytes.data() length:len freeWhenDone:FALSE];
    NSString* ret = [self initWithData:data encoding:encoding];
    [data release];

    return ret;
}

/**
 @Status Caveat
 @Notes Limited encodings available.
*/
- (instancetype)initWithContentsOfFile:(NSString*)path encoding:(NSStringEncoding)encoding error:(NSError**)errorRet {
    if (path == nil) {
        TraceVerbose(TAG, L"initWithContentsOfFile: path = nil!");
        return nil;
    }

    const char* fileName = (const char*)[path UTF8String];
    TraceVerbose(TAG, L"NSString:opening %hs", fileName);

    EbrFile* fpIn = EbrFopen(fileName, "rb");
    if (!fpIn) {
        TraceVerbose(TAG, L"Couldn't open file %hs", fileName);
        if (errorRet) {
            *errorRet = [NSError errorWithDomain:@"File not found" code:100 userInfo:nil];
        }
        return nil;
    }

    if (encoding == NSUnicodeStringEncoding) {
        WORD type = 0;
        EbrFread(&type, 1, 2, fpIn);

        if (type == 0xFEFF) {
        } else if (type == 0xFFFE) {
            assert(0);
            *((char*)0xBAADF00D) = 0;
        } else {
            EbrFseek(fpIn, 0, SEEK_SET);
        }
    }

    int cur = EbrFseek(fpIn, 0, SEEK_CUR);
    EbrFseek(fpIn, 0, SEEK_END);
    int len = EbrFtell(fpIn);
    EbrFseek(fpIn, cur, SEEK_SET);

    std::vector<char> bytes(len);

    len = EbrFread(&(bytes[0]), 1, len, fpIn);
    EbrFclose(fpIn);

    NSData* data = [[NSData alloc] initWithBytesNoCopy:bytes.data() length:len freeWhenDone:FALSE];
    NSString* ret = [self initWithData:data encoding:encoding];
    [data release];

    return ret;
}

/**
 @Status Interoperable
*/
- (unichar)characterAtIndex:(unsigned)index {
    // NSString is a class cluster "interface". A concrete implementation (default or derived) MUST implement this.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Interoperable
*/
- (unsigned)length {
    // NSString is a class cluster "interface". A concrete implementation (default or derived) MUST implement this.
    return NSInvalidAbstractInvocationReturn();
}

/**
 @Status Interoperable
*/
+ (NSStringEncoding)defaultCStringEncoding {
    return static_cast<NSStringEncoding>(CFStringConvertEncodingToNSStringEncoding(__CFStringGetEightBitStringEncoding()));
}

/**
 @Status Caveat
 @Notes atomically parameter not supported
*/
- (BOOL)writeToFile:(NSString*)file atomically:(BOOL)atomically encoding:(NSStringEncoding)encoding error:(NSError**)err {
    if (!file) {
        TraceVerbose(TAG, L"WriteToFile: nil!");
        return NO;
    }

    const char* fileName = (const char*)[file UTF8String];
    TraceVerbose(TAG, L"NSString: writing %hs", fileName);

    EbrFile* fpOut = EbrFopen(fileName, "wb");
    if (!fpOut) {
        if (err) {
            assert(0); //  Write NSError
        }
        TraceVerbose(TAG, L"Couldn't open file %hs", fileName);
        return NO;
    }

    switch (encoding) {
        case NSUTF8StringEncoding:
        case NSASCIIStringEncoding: {
            int len = [self length];
            for (int i = 0; i < len; i++) {
                WORD out = [self characterAtIndex:i];

                EbrFwrite(&out, 1, 1, fpOut);
            }
            break;
        }

        case NSUnicodeStringEncoding: {
            int len = [self length];

            EbrFputc(0xFF, fpOut);
            EbrFputc(0xFE, fpOut);
            for (int i = 0; i < len; i++) {
                WORD out = [self characterAtIndex:i];

                EbrFwrite(&out, 2, 1, fpOut);
            }
            break;
        }

        default:
            assert(0);
    }

    EbrFclose(fpOut);

    return YES;
}

/**
 @Status Interoperable
 @Notes
*/
- (unsigned)lengthOfBytesUsingEncoding:(NSStringEncoding)encoding {
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    CFIndex numBytes = 0;
    unsigned originalLength = [self length];
    unsigned convertedLength =
        __CFStringEncodeByteStream(static_cast<CFStringRef>(self), 0, originalLength, false, cfEncoding, 0, nullptr, 0, &numBytes);

    return (convertedLength != originalLength) ? 0 : numBytes;
}

/**
 @Status Caveat
 @Notes Limited encodings available
*/
+ (instancetype)stringWithContentsOfFile:(NSString*)path encoding:(NSStringEncoding)encoding error:(NSError**)errorRet {
    NSString* ret = [[self alloc] initWithContentsOfFile:path encoding:encoding error:errorRet];

    return [ret autorelease];
}

/**
 @Status Interoperable
*/
+ (instancetype)stringWithContentsOfURL:(NSURL*)url {
    return [self stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nullptr];
}

/**
 @Status Caveat
 @Notes Limited encodings available
*/
+ (instancetype)stringWithContentsOfURL:(NSURL*)url encoding:(NSStringEncoding)encoding error:(NSError**)errorRet {
    NSString* ret = [self alloc];

    NSData* data = [[NSData alloc] initWithContentsOfURL:url options:0 error:errorRet];

    ret = [[ret initWithData:data encoding:encoding] autorelease];
    [data release];

    return ret;
}

/**
 @Status Interoperable
*/
+ (instancetype)stringWithContentsOfFile:(NSString*)path {
    return [[[self alloc] initWithContentsOfFile:path] autorelease];
}

/**
 @Status Caveat
 @Notes Limited encodings available
*/
+ (instancetype)stringWithContentsOfFile:(NSString*)path usedEncoding:(NSStringEncoding*)usedEncoding error:(NSError**)errorRet {
    return [[[self alloc] initWithContentsOfFile:path encoding:NSASCIIStringEncoding error:errorRet] autorelease];
}

/**
 @Status Caveat
 @Notes Limited encodings available
*/
- (instancetype)initWithContentsOfFile:(NSString*)path usedEncoding:(NSStringEncoding*)usedEncoding error:(NSError**)errorRet {
    if (usedEncoding) {
        *usedEncoding = NSASCIIStringEncoding;
    }

    TraceVerbose(TAG, L"Encoding: ASCII?");
    return [self initWithContentsOfFile:path encoding:NSASCIIStringEncoding error:errorRet];
}

/**
 @Status Interoperable
 @Notes
*/
- (const char*)cStringUsingEncoding:(NSStringEncoding)encoding {
    const char* toReturn = CFStringGetCStringPtr(static_cast<CFStringRef>(self), CFStringConvertNSStringEncodingToEncoding(encoding));

    if (toReturn != nullptr) {
        // Huzzah. Great success. The string is null terminated and in the encoding we want.
        return toReturn;
    } else {
        // Sadness. A conversion is needed. convert to a data and autorelease it to not leak.
        // One key here is that dataUsingEncoding is NOT null terminated. This means an *almost* identical copy of
        // that function is implemented to save the copy.
        int len = [self length];
        NSUInteger numBytes = 0;

        NSStringEncodingConversionOptions options = static_cast<NSStringEncodingConversionOptions>(0);

        [self getBytes:nullptr
                 maxLength:0x7FFFFFF
                usedLength:&numBytes
                  encoding:encoding
                   options:options
                     range:NSMakeRange(0, len)
            remainingRange:nullptr];

        // Figure out how big the null terminator needs to be. Note this is a little inefficient as the null terminator is almost certainly
        // smaller than the maximum single character size.
        NSUInteger bytesToAlloc = numBytes + CFStringGetMaximumSizeForEncoding(1, CFStringConvertNSStringEncodingToEncoding(encoding));

        std::unique_ptr<char[], decltype(&IwFree)> data(static_cast<char*>(IwMalloc(bytesToAlloc)), IwFree);
        [self getBytes:data.get()
                 maxLength:numBytes
                usedLength:nullptr
                  encoding:encoding
                   options:options
                     range:NSMakeRange(0, len)
            remainingRange:nullptr];

        // pad the end with \0s to make sure null terminator is correct size. Note that this assumes \0 or 0 is the null terminator in
        // all encodings.
        memset(&data[numBytes], '\0', bytesToAlloc - numBytes);

        return static_cast<const char*>([[NSData dataWithBytesNoCopy:data.release() length:(bytesToAlloc) freeWhenDone:YES] bytes]);
    }
}

/**
 @Status Interoperable
*/
- (NSStringEncoding)fastestEncoding {
    return static_cast<NSStringEncoding>(
        CFStringConvertEncodingToNSStringEncoding(CFStringGetFastestEncoding(static_cast<CFStringRef>(self))));
}

/**
 @Status Interoperable
*/
- (NSStringEncoding)smallestEncoding {
    return static_cast<NSStringEncoding>(
        CFStringConvertEncodingToNSStringEncoding(CFStringGetSmallestEncoding(static_cast<CFStringRef>(self))));
}

/**
 @Status Interoperable
*/
- (const char*)UTF8String {
    return (const char*)[self cStringUsingEncoding:NSUTF8StringEncoding];
}

/**
 @Status Interoperable
 @Notes
*/
- (BOOL)getBytes:(void*)buffer
       maxLength:(NSUInteger)maxBuf
      usedLength:(NSUInteger*)usedLength
        encoding:(NSStringEncoding)encoding
         options:(NSStringEncodingConversionOptions)options
           range:(NSRange)range
  remainingRange:(NSRangePointer)left {
    CFIndex totalBytesWritten = 0;
    unsigned int numCharsProcessed = 0;
    CFStringEncoding cfStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    BOOL result = true;
    if ([self length] > 0) {
        if (CFStringIsEncodingAvailable(cfStringEncoding)) {
            BOOL lossyOk = ((options & NSStringEncodingConversionAllowLossy) != 0);
            BOOL externalRep = ((options & NSStringEncodingConversionExternalRepresentation) != 0);

            numCharsProcessed = __CFStringEncodeByteStream(static_cast<CFStringRef>(self),
                                                           range.location,
                                                           range.length,
                                                           externalRep,
                                                           cfStringEncoding,
                                                           lossyOk ? (encoding == NSASCIIStringEncoding ? 0xFF : 0x3F) : 0,
                                                           static_cast<unsigned char*>(buffer),
                                                           buffer != nil ? maxBuf : 0,
                                                           &totalBytesWritten);
            if (numCharsProcessed == 0) {
                result = false;
            }
        } else {
            result = false;
        }
    }
    if (usedLength != nil) {
        *usedLength = totalBytesWritten;
    }
    if (left != nil) {
        *left = NSMakeRange(range.location + numCharsProcessed, range.length - numCharsProcessed);
    }
    return result;
}

/**
 @Status Interoperable
*/
- (void)getCharacters:(unsigned short*)dest range:(NSRange)range {
    for (unsigned int i = 0; i < range.length; i++) {
        dest[i] = [self characterAtIndex:(i + range.location)];
    }
}

/**
 @Status Interoperable
*/
- (void)getCharacters:(unsigned short*)dest {
    [self getCharacters:dest range:NSMakeRange(0, [self length])];
}

/**
 @Status Interoperable
*/
- (instancetype)copyWithZone:(NSZone*)zone {
    return [self retain];
}

/**
 @Status Interoperable
*/
- (NSMutableString*)mutableCopyWithZone:(NSZone*)zone {
    return [[NSMutableString alloc] initWithString:self];
}

/**
 @Status Interoperable
*/
- (instancetype)lowercaseString {
    return [self lowercaseStringWithLocale:nil];
}

/**
 @Status Interoperable
*/
- (instancetype)capitalizedString {
    return [self capitalizedStringWithLocale:nil];
}

/**
 @Status Interoperable
*/
- (instancetype)uppercaseString {
    return [self uppercaseStringWithLocale:nil];
}

/**
 @Status Stub
*/
- (instancetype)stringByDeletingPathExtension {
    CFIndex index = _CFStartOfPathExtension2(static_cast<CFStringRef>(self));

    if (index > 0 && IS_SLASH([self characterAtIndex:index])) {
        // strip off a trailing slash if the character before the extension is a slash (meaning ends up as path)
        // special case 0th index though to not convert "/" into ""
        return [self substringToIndex:index - 1];
    } else if (index == 0) {
        // whole string is a path extension. Don't do anything to it unless it ends in a slash and its the not root slash.
        NSUInteger length = [self length];
        if (length > 1 && IS_SLASH([self characterAtIndex:(length - 1)])) {
            return [self substringToIndex:length - 1];
        } else {
            return [self copy];
        }
    } else {
        return [self substringToIndex:index];
    }
}

/**
 @Status Stub
*/
- (instancetype)stringByDeletingLastPathComponent {
    CFIndex index = _CFStartOfLastPathComponent2(static_cast<CFStringRef>(self));

    if (index == 0) {
        if ([self length] > 0 && IS_SLASH([self characterAtIndex:index])) {
            return static_cast<NSString*>(_CFGetSlashStr());
        } else {
            return @"";
        }
    } else if (index == 1) {
        return static_cast<NSString*>(_CFGetSlashStr());
    } else {
        // strip of the trailing slash (where the 2nd to last path component would end)
        return [self substringToIndex:(index - 1)];
    }
}

/**
 @Status Stub
*/
- (instancetype)stringByAppendingPathComponent:(NSString*)pathStr {
    NSMutableString* mutableString = [self mutableCopy];
    _CFAppendPathComponent2(static_cast<CFMutableStringRef>(mutableString), static_cast<CFStringRef>(pathStr));

    return mutableString;
}

/**
 @Status Interoperable
*/
- (instancetype)stringByAppendingPathExtension:(NSString*)extension {
    NSMutableString* mutableString = [self mutableCopy];
    Boolean success = _CFAppendPathExtension2(static_cast<CFMutableStringRef>(mutableString), static_cast<CFStringRef>(extension));

    return success ? mutableString : nil;
}

/**
 @Status Interoperable
*/
- (BOOL)hasSuffix:(NSString*)suffixStr {
    return CFStringHasSuffix(static_cast<CFStringRef>(self), static_cast<CFStringRef>(suffixStr));
}

/**
 @Status Interoperable
*/
- (BOOL)hasPrefix:(NSString*)prefixStr {
    return CFStringHasPrefix(static_cast<CFStringRef>(self), static_cast<CFStringRef>(prefixStr));
}

/**
 @Status Stub
*/
- (instancetype)pathExtension {
    return [self substringFromIndex:_CFStartOfPathExtension2(static_cast<CFStringRef>(self))];
}

/**
 @Status Stub
*/
- (instancetype)lastPathComponent {
    return [self substringFromIndex:_CFStartOfLastPathComponent2(static_cast<CFStringRef>(self))];
}

/**
 @Status Interoperable
*/
- (instancetype)substringToIndex:(NSUInteger)anIndex {
    return static_cast<NSString*>(CFStringCreateWithSubstring(nullptr, static_cast<CFStringRef>(self), CFRange{ 0, anIndex }));
}

/**
 @Status Interoperable
*/
- (instancetype)substringFromIndex:(NSUInteger)anIndex {
    return static_cast<NSString*>(CFStringCreateWithSubstring(nullptr, static_cast<CFStringRef>(self), CFRange{ anIndex, [self length] }));
}

/**
 @Status Interoperable
*/
- (instancetype)substringWithRange:(NSRange)range {
    return static_cast<NSString*>(
        CFStringCreateWithSubstring(nullptr, static_cast<CFStringRef>(self), CFRange{ range.location, range.length }));
}

/**
 @Status Interoperable
*/
- (NSString*)description {
    return self;
}

/**
 @Status Interoperable
*/
- (BOOL)isEqualToString:(NSString*)compStr {
    if (compStr == nil)
        return FALSE;

    if ([compStr isKindOfClass:[NSString class]]) {
        return [self compare:compStr options:static_cast<NSStringCompareOptions>(0) range:NSMakeRange(0, [self length])] == 0;
    } else {
        return [compStr isEqual:self];
    }
}

/**
 @Status Interoperable
 @Notes
*/
- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString*)compStr {
    return [self compare:compStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]];
}

/**
 @Status Interoperable
*/
- (NSComparisonResult)caseInsensitiveCompare:(NSString*)compStr {
    return [self compare:compStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSComparisonResult)localizedCompare:(NSString*)compStr {
    return [self compare:compStr
                 options:static_cast<NSStringCompareOptions>(0)
                   range:NSMakeRange(0, [self length])
                  locale:[NSLocale currentLocale]];
}

/**
 @Status Interoperable
*/
- (NSComparisonResult)compare:(NSString*)compStr {
    return [self compare:compStr options:static_cast<NSStringCompareOptions>(0) range:NSMakeRange(0, [self length])];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSComparisonResult)compare:(NSString*)compStr options:(NSStringCompareOptions)options {
    return [self compare:compStr options:options range:NSMakeRange(0, [self length])];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSComparisonResult)compare:(NSString*)compStrAddr options:(NSStringCompareOptions)options range:(NSRange)range {
    return [self compare:compStrAddr options:options range:range locale:nil];
}

/**
 @Status Interoperable
*/
- (int)intValue {
    char* str = (char*)[self UTF8String];

    return strtol(str, nullptr, 10);
}

/**
 @Status Interoperable
*/
- (NSInteger)integerValue {
    return [self intValue];
}

/**
 @Status Interoperable
*/
- (__int64)longLongValue {
    char* str = (char*)[self UTF8String];

    __int64 ret;
#if defined(WIN32) || defined(WINPHONE)
    ret = _strtoi64(str, nullptr, 10);
#else
    ret = strtoll(str, nullptr, 10);
#endif

    return ret;
}

/**
 @Status Interoperable
*/
- (float)floatValue {
    char* str = (char*)[self UTF8String];

    float ret = (float)strtod(str, nullptr);

    return ret;
}

/**
 @Status Interoperable
*/
- (double)doubleValue {
    char* str = (char*)[self UTF8String];

    double ret = strtod(str, nullptr);

    return ret;
}

/**
 @Status Interoperable
*/
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)charSet {
    NSRange range;
    range = [self rangeOfCharacterFromSet:charSet options:static_cast<NSStringCompareOptions>(0) range:NSMakeRange(0, [self length])];

    return range;
}

/**
 @Status Caveat
 @Notes Only NSCaseInsensitiveSearch, NSBackwardsSearch options supported
*/
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)charSet options:(NSStringCompareOptions)options {
    NSRange range;
    range = [self rangeOfCharacterFromSet:charSet options:options range:NSMakeRange(0, [self length])];

    return range;
}

/**
 @Status Caveat
 @Notes Only NSCaseInsensitiveSearch, NSBackwardsSearch options supported
*/
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)charSet options:(NSStringCompareOptions)options range:(NSRange)range {
    unsigned int length = [self length];

    THROW_NS_IF_FALSE(E_INVALIDARG, (range.length <= length) && (range.location <= (length - range.length)));

    CFRange result{};
    if (CFStringFindCharacterFromSet(static_cast<CFStringRef>(self),
                                     static_cast<CFCharacterSetRef>(charSet),
                                     CFRange{ range.location, range.length },
                                     options,
                                     &result)) {
        return NSMakeRange(result.location, result.length);
    }

    return NSMakeRange(NSNotFound, 0);
}

/**
 @Status Interoperable
*/
- (void)getCString:(char*)buf maxLength:(NSUInteger)maxLength {
    [self getCString:buf maxLength:maxLength encoding:NSASCIIStringEncoding];
}

/**
 @Status Interoperable
*/
- (void)getCString:(char*)buf {
    [self getCString:buf maxLength:0x7FFFFFFF encoding:NSASCIIStringEncoding];
}

/**
 @Status Caveat
 @Notes Limited encodings supported
*/
- (BOOL)getCString:(char*)buf maxLength:(NSUInteger)maxLength encoding:(NSStringEncoding)encoding {
    int len = [self length];
    NSRange usedRange;

    unsigned usedLength = 0;
    [self getBytes:buf
             maxLength:maxLength
            usedLength:&usedLength
              encoding:encoding
               options:static_cast<NSStringEncodingConversionOptions>(0)
                 range:NSMakeRange(0, len)
        remainingRange:&usedRange];
    if (usedLength < maxLength) {
        buf[usedLength] = 0;
    }

    if (usedRange.location == len) {
        return TRUE;
    } else {
        return FALSE;
    }
}

/**
 @Status Interoperable
*/
- (NSArray*)componentsSeparatedByString:(NSString*)separators {
    unsigned int len = [self length];
    NSRange range = [self rangeOfString:separators options:static_cast<NSStringCompareOptions>(0) range:NSMakeRange(0, len)];

    if (range.length == 0) {
        return @[ self ];
    } else {
        NSMutableArray* array = [NSMutableArray array];
        NSRange srange = NSMakeRange(0, len);
        while (true) {
            NSRange trange = NSMakeRange(srange.location, range.location - srange.location);
            [array addObject:[self substringWithRange:trange]];
            srange.location = range.location + range.length;
            srange.length = len - srange.location;
            range = [self rangeOfString:separators options:static_cast<NSStringCompareOptions>(0) range:srange];
            if (range.length == 0) {
                break;
            }
        }

        [array addObject:[self substringWithRange:srange]];
        return array;
    }
}

/**
 @Status Interoperable
*/
- (NSArray*)componentsSeparatedByCharactersInSet:(NSCharacterSet*)set {
    NSMutableArray* result = [NSMutableArray array];
    int length = [self length];
    NSRange search = NSMakeRange(0, [self length]), patWhere;

    do {
        patWhere = [self rangeOfCharacterFromSet:set options:static_cast<NSStringCompareOptions>(0) range:search];

        if (patWhere.length > 0) {
            NSString* piece = [self substringWithRange:NSMakeRange(search.location, patWhere.location - search.location)];

            [result addObject:piece];
            search.location = patWhere.location + patWhere.length;
            search.length = length - search.location;
        }
    } while (patWhere.length > 0);

    [result addObject:[self substringWithRange:search]];

    return result;
}

/**
 @Status Interoperable
*/
- (NSString*)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString*)replacement {
    NSMutableString* ret = [self mutableCopy];
    [ret replaceCharactersInRange:range withString:replacement];

    return [ret autorelease];
}

/**
 @Status Interoperable
*/
- (NSString*)stringByReplacingOccurrencesOfString:(NSString*)target withString:(NSString*)replacement {
    int length = [self length];

    return [self stringByReplacingOccurrencesOfString:target
                                           withString:replacement
                                              options:static_cast<NSStringCompareOptions>(0)
                                                range:NSMakeRange(0, length)];
}

/**
 @Status Caveat
 @Notes Only NSCaseInsensitiveSearch, NSDiacriticInsensitiveSearch, NSNumericSearch, NSBackwardsSearch,
        and NSRegularExpression are supported.
*/
- (NSString*)stringByReplacingOccurrencesOfString:(NSString*)target
                                       withString:(NSString*)replacement
                                          options:(NSStringCompareOptions)options
                                            range:(NSRange)range {
    //  Fastpath - make sure there's something to replace
    if ((options & NSRegularExpressionSearch) == 0) {
        NSRange subrange;

        subrange = [self rangeOfString:target options:options range:range];
        if (subrange.location == NSNotFound) {
            //  Nothing to replace
            return [[self copy] autorelease];
        }
    }

    NSMutableString* mutableCopy = [[self mutableCopy] autorelease];
    [mutableCopy replaceOccurrencesOfString:target withString:replacement options:options range:range];

    return [[[NSString alloc] initWithString:mutableCopy] autorelease];
}

/**
 @Status Interoperable
*/
- (NSString*)stringByTrimmingCharactersInSet:(NSCharacterSet*)charSet {
    int trimStart = 0;
    int trimEnd = [self length];

    for (; trimStart < [self length]; trimStart++) {
        if (![charSet characterIsMember:[self characterAtIndex:trimStart]]) {
            break;
        }
    }

    if (trimStart == [self length]) {
        return @"";
    } else if (trimStart < ([self length] - 1)) {
        for (; trimEnd > 0; trimEnd--) {
            if (![charSet characterIsMember:[self characterAtIndex:(trimEnd - 1)]]) {
                break;
            }
        }
        return [self substringWithRange:NSMakeRange(trimStart, trimEnd - trimStart)];
    } else {
        return [self substringWithRange:NSMakeRange(trimStart, 1)];
    }
}

/**
 @Status Interoperable
*/
- (NSRange)rangeOfString:(NSString*)subStr {
    return [self rangeOfString:subStr options:static_cast<NSStringCompareOptions>(0)];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSRange)rangeOfString:(NSString*)subStr options:(NSStringCompareOptions)options {
    return [self rangeOfString:subStr options:options range:NSMakeRange(0, [self length])];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSRange)rangeOfString:(NSString*)subStr options:(NSStringCompareOptions)options range:(NSRange)range {
    return [self rangeOfString:subStr options:options range:range locale:nil];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSRange)rangeOfString:(NSString*)searchString options:(NSStringCompareOptions)mask range:(NSRange)range locale:(NSLocale*)locale {
    unsigned int findStringLength = [searchString length];
    unsigned int length = [self length];

    THROW_NS_IF_FALSE(E_INVALIDARG, (range.length <= length) && (range.location <= (length - range.length)));

    if ((mask & NSRegularExpressionSearch) != 0) {
        NSRange matchedRange = NSMakeRange(NSNotFound, 0);
        NSRegularExpressionOptions regexOptions = (0 != (mask & NSCaseInsensitiveSearch)) ? NSRegularExpressionCaseInsensitive : 0;
        NSMatchingOptions matchingOptions = (0 != (mask & NSAnchoredSearch)) ? NSMatchingAnchored : 0;
        NSRegularExpression* regularExpression =
            [NSRegularExpression regularExpressionWithPattern:searchString options:regexOptions error:nullptr];
        matchedRange = [regularExpression rangeOfFirstMatchInString:self options:matchingOptions range:range];
        return matchedRange;
    }

    if (range.length == 0 || findStringLength == 0) { // ??? This last item can't be here for correct Unicode compares
        return NSMakeRange(NSNotFound, 0);
    }

    CFRange result{};
    if (CFStringFindWithOptionsAndLocale(static_cast<CFStringRef>(self),
                                         static_cast<CFStringRef>(searchString),
                                         CFRange{ range.location, range.length },
                                         mask,
                                         static_cast<CFLocaleRef>(locale),
                                         &result)) {
        return NSMakeRange(result.location, result.length);
    }

    return NSMakeRange(NSNotFound, 0);
}

/**
 @Status Interoperable
*/
- (BOOL)isAbsolutePath {
    char* pStr = (char*)[self UTF8String];

    if (pStr[0] != '/') {
        return NO;
    } else {
        return YES;
    }
}

/**
 @Status Interoperable
*/
- (NSArray*)pathComponents {
    NSMutableArray* ret = [[[self componentsSeparatedByString:@"/"] mutableCopy] autorelease];

    int count = [ret count];
    for (int i = 0; i < count; i++) {
        id curObj = [ret objectAtIndex:i];

        if ([curObj length] == 0) {
            if (i > 0) {
                [ret removeObjectAtIndex:i];
                i--;
                count--;
                continue;
            } else {
                [ret replaceObjectAtIndex:0 withObject:@"/"];
            }
        }
    }

    return ret;
}

/**
 @Status Interoperable
 @Notes
*/
- (const char*)fileSystemRepresentation {
    unsigned int maxLength = CFStringGetMaximumSizeOfFileSystemRepresentation(static_cast<CFStringRef>(self));

    // NOTE: this is slightly tricky. the NSData object is autoreleased to "leak" the array out of this calling context without actually
    // leaking it forever.
    NSMutableData* data = [NSMutableData dataWithLength:maxLength];

    return ([self getFileSystemRepresentation:(char*)[data bytes] maxLength:[data length]]) ? ((const char*)[data bytes]) : (nullptr);
}

/**
 @Status Interoperable
 @Notes
*/
- (BOOL)getFileSystemRepresentation:(char*)dest maxLength:(NSUInteger)destMax {
    return CFStringGetFileSystemRepresentation(static_cast<CFStringRef>(self), dest, destMax);
}

/**
 @Status Interoperable
*/
+ (NSString*)pathWithComponents:(NSArray*)components {
    int count = [components count];
    char outStr[1024];

    strcpy_s(outStr, sizeof(outStr), "");

    for (int i = 0; i < count; i++) {
        char* curComponent = (char*)[[components objectAtIndex:i] UTF8String];

        strcat_s(outStr, sizeof(outStr), curComponent);
        if (i < count - 1 && strcmp(curComponent, "/") != 0)
            strcat_s(outStr, sizeof(outStr), "/");
    }

    return [self stringWithCString:outStr];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSData*)dataUsingEncoding:(NSStringEncoding)encoding {
    return [self dataUsingEncoding:encoding allowLossyConversion:NO];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSData*)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy {
    int len = [self length];
    NSUInteger numBytes = 0;

    NSStringEncodingConversionOptions options =
        lossy ? (NSStringEncodingConversionAllowLossy) : static_cast<NSStringEncodingConversionOptions>(0);

    [self getBytes:nullptr
             maxLength:0x7FFFFFF
            usedLength:&numBytes
              encoding:encoding
               options:options
                 range:NSMakeRange(0, len)
        remainingRange:nullptr];

    std::unique_ptr<char[], decltype(&IwFree)> data(static_cast<char*>(IwMalloc(numBytes)), IwFree);
    [self getBytes:data.get()
             maxLength:numBytes
            usedLength:nullptr
              encoding:encoding
               options:options
                 range:NSMakeRange(0, len)
        remainingRange:nullptr];

    return [NSData dataWithBytesNoCopy:data.release() length:numBytes freeWhenDone:YES];
}

/**
 @Status Stub
*/
- (NSString*)stringByExpandingTildeInPath {
    UNIMPLEMENTED();
    return self;
}

/**
 @Status Interoperable
*/
- (NSString*)stringByStandardizingPath {
    NSMutableArray* components = [NSMutableArray arrayWithArray:[self componentsSeparatedByString:@"/"]];
    int componentsCount = [components count];
    int lastComponentLen = 0;

    int count = [components count];
    for (int i = 0; i < count; i++) {
        id curObj = [components objectAtIndex:i];
        char* pComponent = (char*)[curObj UTF8String];
        int componentLength = strlen(pComponent);

        if (componentLength == 0) {
            if (i == 0) {
                [components replaceObjectAtIndex:i withObject:@"/"];
                lastComponentLen = componentLength;
                continue;
            }

            if (lastComponentLen == 0) {
                [components removeObjectAtIndex:i];
                i--;
                count--;
                lastComponentLen = componentLength;
                continue;
            }
        }
        lastComponentLen = componentLength;

        if (strcmp(pComponent, ".") == 0) {
            [components removeObjectAtIndex:i];
            i--;
            count--;
            continue;
        }
    }

    return [NSString pathWithComponents:components];
}

/**
 @Status Interoperable
*/
- (Class)classForCoder {
    return [NSString class];
}

/**
 @Status Interoperable
*/
- (NSDictionary*)propertyListFromStringsFileFormat {
    NSMutableDictionary* ret = [NSMutableDictionary new];
    NSUInteger length = [self length];

    NSString* key;
    id value;

    unsigned int index, c, strSize = 0, strMax = 2048;
    std::unique_ptr<char[], decltype(&IwFree)> strBuf(static_cast<char*>(IwMalloc(strMax)), IwFree);

    enum {
        STATE_WHITESPACE,
        STATE_COMMENT_SLASH,
        STATE_COMMENT_EOL,
        STATE_COMMENT,
        STATE_COMMENT_STAR,
        STATE_STRING,
        STATE_STRING_KEY,
        STATE_STRING_SLASH,
        STATE_STRING_SLASH_X00,
        STATE_STRING_SLASH_XX0
    } state = STATE_WHITESPACE;
    enum { EXPECT_KEY, EXPECT_EQUAL_SEMI, EXPECT_VAL, EXPECT_SEMI } expect = EXPECT_KEY;

    unichar (*mapUC)(unichar);
    if ([self characterAtIndex:0] == 0xFFFE) {
        // reverse endianness
        mapUC = SwapWord;
        index = 1;
    } else if ([self characterAtIndex:0] == 0xFEFF) {
        // native endianness
        mapUC = PickWord;
        index = 1;
    } else {
        // no BOM, assume native endianness
        mapUC = PickWord;
        index = 0;
    }

    if (mapUC([self characterAtIndex:(length - 1)]) == 0x0A)
        length--;

    for (; index < length; index++) {
        c = mapUC([self characterAtIndex:index]);
        switch (state) {
            case STATE_WHITESPACE:
                if (c == '/') {
                    state = STATE_COMMENT_SLASH;
                } else if (c == '=') {
                    if (expect == EXPECT_EQUAL_SEMI) {
                        expect = EXPECT_VAL;
                    } else {
                        return error(ret, strBuf.get(), "unexpected character %02X '%c' at %d", c, c, index);
                    }
                } else if (c == ';') {
                    if (expect == EXPECT_SEMI) {
                        [ret setValue:value forKey:key];
                        value = nil;
                        key = nil;
                        expect = EXPECT_KEY;
                    } else if (expect == EXPECT_EQUAL_SEMI) {
                        expect = EXPECT_KEY;
                        assert(0);
                        //[array addObject:[array lastObject]];
                    } else {
                        return error(ret, strBuf.get(), "unexpected character %02X '%c' at %d", c, c, index);
                    }
                } else if (c == '\"') {
                    if (expect != EXPECT_KEY && expect != EXPECT_VAL) {
                        return error(ret, strBuf.get(), "unexpected character %02X '%c' at %d", c, c, index);
                    }

                    strSize = 0;
                    state = STATE_STRING;
                } else if (c > ' ') {
                    if (expect != EXPECT_KEY) {
                        return error(ret, strBuf.get(), "unexpected character %02X '%c' at %d", c, c, index);
                    }

                    strBuf[0] = c;
                    strSize = 1;
                    state = STATE_STRING_KEY;
                }
                break;

            case STATE_COMMENT_SLASH:
                if (c == '*') {
                    state = STATE_COMMENT;
                } else if (c == '/') {
                    state = STATE_COMMENT_EOL;
                } else {
                    return error(ret, strBuf.get(), "unexpected character %02X '%c',after /", c, c);
                }
                break;

            case STATE_COMMENT_EOL:
                if (c == 0x0A) {
                    state = STATE_WHITESPACE;
                }

            case STATE_COMMENT:
                if (c == '*') {
                    state = STATE_COMMENT_STAR;
                }
                break;

            case STATE_COMMENT_STAR:
                if (c == '/') {
                    state = STATE_WHITESPACE;
                } else if (c != '*') {
                    state = STATE_COMMENT;
                }
                break;

            case STATE_STRING_KEY:
                switch (c) {
                    case '\"':
                        return error(ret, strBuf.get(), "unexpected character %02X '%c' at %d", c, c, index);
                    case '=':
                        index -= 2;
                    case ' ':
                        c = '\"';
                }

            case STATE_STRING:
                if (c == '\"') {
                    strBuf[strSize] = '\0';

                    NSString* string = [NSString stringWithUTF8String:strBuf.get()];
                    if (expect == EXPECT_KEY) {
                        key = string;
                    } else {
                        value = string;
                    }

                    state = STATE_WHITESPACE;

                    if (expect == EXPECT_KEY) {
                        expect = EXPECT_EQUAL_SEMI;
                    } else {
                        expect = EXPECT_SEMI;
                    }
                } else {
                    if (strSize >= strMax) {
                        strMax *= 2;
                        char* oldPtr = strBuf.release();
                        strBuf.reset((char*)IwRealloc(oldPtr, strMax));
                    }
                    if (c == '\\') {
                        state = STATE_STRING_SLASH;
                    } else {
                        //  [NOTE: Convert to UTF8 here!]
                        strBuf[strSize] = c;
                        strSize++;
                    }
                }
                break;

            case STATE_STRING_SLASH:
                switch (c) {
                    case 'a':
                        strBuf[strSize++] = '\a';
                        state = STATE_STRING;
                        break;
                    case 'b':
                        strBuf[strSize++] = '\b';
                        state = STATE_STRING;
                        break;
                    case 'f':
                        strBuf[strSize++] = '\f';
                        state = STATE_STRING;
                        break;
                    case 'n':
                        strBuf[strSize++] = '\n';
                        state = STATE_STRING;
                        break;
                    case 'r':
                        strBuf[strSize++] = '\r';
                        state = STATE_STRING;
                        break;
                    case 't':
                        strBuf[strSize++] = '\t';
                        state = STATE_STRING;
                        break;
                    case 'v':
                        strBuf[strSize++] = '\v';
                        state = STATE_STRING;
                        break;
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                        strBuf[strSize++] = c - '0';
                        state = STATE_STRING_SLASH_X00;
                        break;

                    default:
                        strBuf[strSize++] = c;
                        state = STATE_STRING;
                        break;
                }
                break;

            case STATE_STRING_SLASH_X00:
                if (c < '0' || c > '7') {
                    state = STATE_STRING;
                    index--;
                } else {
                    state = STATE_STRING_SLASH_XX0;
                    strBuf[strSize - 1] *= 8;
                    strBuf[strSize - 1] += c - '0';
                }
                break;

            case STATE_STRING_SLASH_XX0:
                state = STATE_STRING;
                if (c < '0' || c > '7') {
                    index--;
                } else {
                    strBuf[strSize - 1] *= 8;
                    strBuf[strSize - 1] += c - '0';
                }
                break;
        }
    }

    if (state != STATE_WHITESPACE) {
        return error(ret, nullptr, "unexpected EOF\n");
    }

    switch (expect) {
        case EXPECT_EQUAL_SEMI:
            return error(ret, nullptr, "unexpected EOF, expecting = or ;");

        case EXPECT_VAL:
            return error(ret, nullptr, "unexpected EOF, expecting value");

        case EXPECT_SEMI:
            return error(ret, nullptr, "unexpected EOF, expecting ;");

        default:
            break;
    }

    return [ret autorelease];
}

/**
 @Status Interoperable
*/
- (unsigned)hash {
    return CFStringHashNSString(static_cast<CFStringRef>(self));
}

/**
 @Status Interoperable
*/
- (NSString*)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString*)padString startingAtIndex:(NSUInteger)padIndex {
    unsigned int length = [self length];

    if (newLength <= length) { // The simple cases (truncation)
        return (newLength == length) ? [[self copy] autorelease] : [self substringWithRange:NSMakeRange(0, newLength)];
    }

    unsigned int padLength = [padString length];
    THROW_NS_IF_FALSE(E_INVALIDARG, (padLength > 0) && (padIndex < padLength));

    NSMutableString* mutableCopy = [self mutableCopy];
    CFStringPad(static_cast<CFMutableStringRef>(mutableCopy), static_cast<CFStringRef>(padString), newLength, padIndex);
    return mutableCopy;
}

/**
 @Status Caveat
 @Notes encoding parameter not supported
*/
- (NSString*)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    NSUInteger i, length = [self length], resultLength = 0;
    std::unique_ptr<unichar[], decltype(&IwFree)> unicode(static_cast<unichar*>(IwMalloc(length * 2)), IwFree);
    std::unique_ptr<unichar[], decltype(&IwFree)> result(static_cast<unichar*>(IwMalloc(length * 3 * 2)), IwFree);
    const char* hex = "0123456789ABCDEF";

    [self getCharacters:unicode.get()];

    for (i = 0; i < length; i++) {
        unichar code = unicode[i];

        if ((code <= 0x20) || (code == 0x22) || (code == 0x23) || (code == 0x25) || (code == 0x3C) || (code == 0x3E) || (code == 0x5B) ||
            (code == 0x5C) || (code == 0x5D) || (code == 0x5E) || (code == 0x60) || (code == 0x7B) || (code == 0x7C) || (code == 0x7D)) {
            result[resultLength++] = '%';
            result[resultLength++] = hex[(code >> 4) & 0xF];
            result[resultLength++] = hex[code & 0xF];
        } else {
            result[resultLength++] = code;
        }
    }

    if (length == resultLength) {
        return self;
    }

    NSString* ret = [NSString stringWithCharacters:result.get() length:resultLength];
    return ret;
}

/**
 @Status Interoperable
*/
- (NSString*)stringByAddingPercentEncodingWithAllowedCharacters:(NSCharacterSet*)set {
    return [static_cast<NSString*>(_CFStringCreateByAddingPercentEncodingWithAllowedCharacters(nullptr,
                                                                                               static_cast<CFStringRef>(self),
                                                                                               static_cast<CFCharacterSetRef>(set)))
        autorelease];
}

/**
 @Status Interoperable
 @Notes
*/
- (NSString*)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    return [static_cast<NSString*>(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
        nullptr, static_cast<CFStringRef>(self), CFSTR(""), CFStringConvertNSStringEncodingToEncoding(encoding))) autorelease];
}

/**
 @Status Interoperable
*/
- (NSString*)stringByRemovingPercentEncoding {
    return [static_cast<NSString*>(_CFStringCreateByRemovingPercentEncoding(nullptr, static_cast<CFStringRef>(self))) autorelease];
}

/**
 @Status Interoperable
*/
- (BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding {
    if (encoding == NSUnicodeStringEncoding || encoding == NSNonLossyASCIIStringEncoding || encoding == NSUTF8StringEncoding) {
        return YES;
    }

    unsigned int convertedLength = __CFStringEncodeByteStream(static_cast<CFStringRef>(self),
                                                              0,
                                                              [self length],
                                                              false,
                                                              CFStringConvertNSStringEncodingToEncoding(encoding),
                                                              0,
                                                              nullptr,
                                                              0,
                                                              nullptr);

    return ([self length] == convertedLength);
}

/**
 @Status Interoperable
*/
- (NSRange)lineRangeForRange:(NSRange)range {
    unsigned int start = 0;
    unsigned int lineEnd = 0;
    [self getLineStart:&start end:&lineEnd contentsEnd:nil forRange:range];
    return NSMakeRange(start, lineEnd - start);
}

/**
 @Status Interoperable
*/
- (void)getParagraphStart:(NSUInteger*)startp end:(NSUInteger*)endp contentsEnd:(NSUInteger*)contentsEndp forRange:(NSRange)range {
    /*
    Documentation does not specify exact getParagraphStart: behavior, only mentioning it is similar to getLineStart:
    The difference is that getParagraphStart: does not delimit on line terminators 0x0085 and 0x2028
    */
    NSUInteger start = range.location;
    NSUInteger end = NSMaxRange(range);
    NSUInteger contentsEnd = end;
    NSUInteger length = [self length];
    enum { scanning, gotR, done } state = scanning;

    for (; start != 0; start--) {
        unichar check = [self characterAtIndex:(start - 1)];

        if (check == 0x2028 || check == 0x000A || check == 0x2029)
            break;

        if (check == 0x000D && [self characterAtIndex:(start)] != 0x000A)
            break;
    }

    for (; end < length && state != done; end++) {
        unichar check = [self characterAtIndex:(end)];

        if (state == scanning) {
            if (check == 0x000D) {
                contentsEnd = end;
                state = gotR;
            } else if (check == 0x000A || check == 0x2029) {
                contentsEnd = end;
                state = done;
            }
        } else if (state == gotR) {
            if (check != 0x000A) {
                end--;
            }
            state = done;
        }
    }

    if ((end >= length) && (state != done)) {
        contentsEnd = end;
    }

    if (startp) {
        *startp = start;
    }
    if (endp) {
        *endp = end;
    }
    if (contentsEndp) {
        *contentsEndp = contentsEnd;
    }
}

/**
 @Status Stub
*/
- (NSString*)precomposedStringWithCanonicalMapping {
    UNIMPLEMENTED();
    TraceVerbose(TAG, L"precomposedStringWithCanonicalMapping??");
    return [self retain];
}

/**
 @Status Stub
 @Notes
*/
- (void)enumerateSubstringsInRange:(NSRange)range
                           options:(NSStringEnumerationOptions)options
                        usingBlock:(void (^)(NSString*, NSRange, NSRange, BOOL*))block {
    UNIMPLEMENTED();
}

/**
 @Status Interoperable
*/
- (void)dealloc {
    [super dealloc];
}

/**
 @Status Interoperable
*/
- (BOOL)boolValue {
    NSScanner* scanner = [NSScanner scannerWithString:self];
    // skip initial whitespace if present
    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
    // scan a single optional '+' or '-' character, followed by zeroes
    if ([scanner scanString:@"+" intoString:nil] == NO) {
        [scanner scanString:@"-" intoString:nil];
    }
    // scan any following zeroes
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0"] intoString:nil];

    // allowable characters are 1-9 y Y t T. It doesn't matter if there are any trailing characters.
    return [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"tTyY123456789"] intoString:nil];
}

/**
 @Status Stub
 @Notes
*/
- (instancetype)initWithFormat:(NSString*)format locale:(id)locale, ... {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (instancetype)initWithFormat:(NSString*)format locale:(id)locale arguments:(va_list)argList {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (instancetype)initWithCStringNoCopy:(char*)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (instancetype)initWithContentsOfURL:(NSURL*)url encoding:(NSStringEncoding)enc error:(NSError* _Nullable*)error {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
+ (instancetype)stringWithContentsOfURL:(NSURL*)url usedEncoding:(NSStringEncoding*)enc error:(NSError* _Nullable*)error {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (instancetype)initWithContentsOfURL:(NSURL*)url usedEncoding:(NSStringEncoding*)enc error:(NSError* _Nullable*)error {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (instancetype)initWithContentsOfURL:(NSURL*)url {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (BOOL)writeToFile:(NSString*)path atomically:(BOOL)useAuxiliaryFile {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (BOOL)writeToURL:(NSURL*)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError* _Nullable*)error {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (BOOL)writeToURL:(NSURL*)url atomically:(BOOL)atomically {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Interoperable
 @Notes
*/
- (NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)enc {
    CFStringEncoding cfEnc = CFStringConvertNSStringEncodingToEncoding(enc);
    CFIndex maxSize = CFStringGetMaximumSizeForEncoding([self length], cfEnc);
    return (maxSize == kCFNotFound) ? 0 : maxSize;
}

/**
 @Status Stub
 @Notes
*/
- (const char*)cString {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (const char*)lossyCString {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSUInteger)cStringLength {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (void)getCString:(char*)bytes maxLength:(NSUInteger)maxLength range:(NSRange)aRange remainingRange:(NSRangePointer)leftoverRange {
    UNIMPLEMENTED();
}

/**
 @Status Stub
 @Notes
*/
- (void)enumerateLinesUsingBlock:(void (^)(NSString*, BOOL*))block {
    UNIMPLEMENTED();
}

/**
 @Status Stub
 @Notes
*/
- (void)getLineStart:(NSUInteger*)startIndex
                 end:(NSUInteger*)lineEndIndex
         contentsEnd:(NSUInteger*)contentsEndIndex
            forRange:(NSRange)aRange {
    // HACKHACK: Actually implement this guy now. should share common impl with paragraph one.
    UNIMPLEMENTED();
}

/**
 @Status Stub
 @Notes
*/
- (NSRange)paragraphRangeForRange:(NSRange)aRange {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)anIndex {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (id)propertyList {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Interoperable
*/
- (BOOL)isEqual:(NSString*)objAddr {
    if (objAddr == self)
        return YES;
    if (objAddr == nil)
        return NO;

    if (objAddr != nil && [objAddr isKindOfClass:[NSString class]]) {
        return [self isEqualToString:objAddr];
    }

    return NO;
}

/**
 @Status Interoperable
 @Notes
*/
- (NSComparisonResult)compare:(NSString*)aString options:(NSStringCompareOptions)mask range:(NSRange)range locale:(id)locale {
    return CFStringCompareWithOptionsAndLocale(static_cast<CFStringRef>(self),
                                               static_cast<CFStringRef>(aString),
                                               CFRange{ range.location, range.length },
                                               mask,
                                               static_cast<CFLocaleRef>(locale));
}

/**
 @Status Stub
 @Notes
*/
- (NSComparisonResult)localizedStandardCompare:(NSString*)string {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSString*)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale*)locale {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSString*)commonPrefixWithString:(NSString*)aString options:(NSStringCompareOptions)mask {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSString*)capitalizedStringWithLocale:(NSLocale*)locale {
    NSMutableString* mutableCopy = [self mutableCopy];
    CFStringCapitalize(static_cast<CFMutableStringRef>(mutableCopy), static_cast<CFLocaleRef>(locale));
    return mutableCopy;
}

/**
 @Status Interoperable
 @Notes
*/
- (NSString*)lowercaseStringWithLocale:(NSLocale*)locale {
    NSMutableString* mutableCopy = [self mutableCopy];
    CFStringLowercase(static_cast<CFMutableStringRef>(mutableCopy), static_cast<CFLocaleRef>(locale));
    return mutableCopy;
}

/**
 @Status Interoperable
 @Notes
*/
- (NSString*)uppercaseStringWithLocale:(NSLocale*)locale {
    NSMutableString* mutableCopy = [self mutableCopy];
    CFStringUppercase(static_cast<CFMutableStringRef>(mutableCopy), static_cast<CFLocaleRef>(locale));
    return mutableCopy;
}

/**
 @Status Stub
 @Notes
*/
- (NSUInteger)completePathIntoString:(NSString* _Nonnull*)outputName
                       caseSensitive:(BOOL)flag
                    matchesIntoArray:(NSArray* _Nonnull*)outputArray
                         filterTypes:(NSArray*)filterTypes {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSArray*)stringsByAppendingPaths:(NSArray*)paths {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (void)enumerateLinguisticTagsInRange:(NSRange)range
                                scheme:(NSString*)tagScheme
                               options:(NSLinguisticTaggerOptions)opts
                           orthography:(NSOrthography*)orthography
                            usingBlock:(void (^)(NSString*, NSRange, NSRange, BOOL*))block {
    UNIMPLEMENTED();
}

/**
 @Status Stub
 @Notes
*/
- (NSArray*)linguisticTagsInRange:(NSRange)range
                           scheme:(NSString*)tagScheme
                          options:(NSLinguisticTaggerOptions)opts
                      orthography:(NSOrthography*)orthography
                      tokenRanges:(NSArray* _Nullable*)tokenRanges {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
+ (instancetype)localizedStringWithFormat:(NSString*)format, ... {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
+ (const NSStringEncoding*)availableStringEncodings {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Caveat
 @Notes not actually localized
*/
+ (NSString*)localizedNameOfStringEncoding:(NSStringEncoding)encoding {
    return [static_cast<NSString*>(CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(encoding))) autorelease];
}

/**
 @Status Stub
 @Notes
*/
+ (BOOL)supportsSecureCoding {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (void)encodeWithCoder:(NSCoder*)coder {
    UNIMPLEMENTED();
}

/**
 @Status Stub
*/
- (NSString*)decomposedStringWithCanonicalMapping {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
*/
- (NSString*)decomposedStringWithCompatibilityMapping {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
*/
- (NSString*)precomposedStringWithCompatibilityMapping {
    UNIMPLEMENTED();
    return StubReturn();
}

- (NSString*)stringByResolvingSymlinksInPath {
    UNIMPLEMENTED();
    return StubReturn();
}

// CF additions for fast paths.
- (const char*)_fastCStringContents:(BOOL)something {
    return nullptr;
}

- (const UniChar*)_fastCharacterContents {
    return nullptr;
}

- (Boolean)_encodingCantBeStoredInEightBitCFString {
    return true;
}

- (NSString*)_createSubstringWithRange:(NSRange)range {
    int len = [self length];
    NSUInteger numBytes = 0;
    NSStringEncoding encoding = [self fastestEncoding];

    [self getBytes:nullptr
             maxLength:0x7FFFFFF
            usedLength:&numBytes
              encoding:encoding
               options:static_cast<NSStringEncodingConversionOptions>(0)
                 range:range
        remainingRange:nullptr];

    if (numBytes > 0) {
        std::vector<unsigned char> bytes(numBytes);
        [self getBytes:&bytes[0]
                 maxLength:numBytes
                usedLength:nullptr
                  encoding:encoding
                   options:static_cast<NSStringEncodingConversionOptions>(0)
                     range:range
            remainingRange:nullptr];

        return [[NSString alloc] initWithBytes:&bytes[0] length:numBytes encoding:encoding];
    }

    return [NSString new];
}

- (CFStringEncoding)_smallestEncodingInCFStringEncoding {
    return kCFStringEncodingUTF8;
}

- (CFStringEncoding)_fastestEncodingInCFStringEncoding {
    // Return Unicode encoding as soon as a single non-ASCII character is found. Otherwise, return ASCII encoding.
    for (int32_t i = 0; i < [self length]; i++) {
        if ([self characterAtIndex:i] > 0x7F) {
            return kCFStringEncodingUnicode;
        }
    }

    return kCFStringEncodingASCII;
}

- (Boolean)_getCString:(char*)buffer maxLength:(NSUInteger)bufferSize encoding:(NSStringEncoding)encoding {
    return [self getBytes:buffer
                maxLength:bufferSize
               usedLength:nullptr
                 encoding:encoding
                  options:static_cast<NSStringEncodingConversionOptions>(0)
                    range:NSMakeRange(0, [self length])
           remainingRange:nullptr];
}

- (const wchar_t*)rawCharacters {
    // TODO 7143070 This is only here for compatibility with projections. remove once we get a new projections.
    return (const wchar_t*)[self cStringUsingEncoding:NSUTF16StringEncoding];
}

- (int)_versionStringCompare:(NSString*)compStrAddr {
    TraceWarning(TAG, L"Warning: versionStringCompare not implemented");
    char* str = (char*)[self UTF8String];

    if (compStrAddr == nil) {
        TraceVerbose(TAG, L"Compare to nil?");
        return strcmp(str, "");
    }

    const char* compStr = (const char*)[compStrAddr UTF8String];

    int result = strcmp(str, compStr);
    if (result < 0) {
        result = -1;
    }
    if (result > 0) {
        result = 1;
    }

    return result;
}

- (NSString*)_reverseString {
    NSUInteger length = [self length];
    if (length < 2) {
        return self;
    }

    std::vector<char> characters(length + 1);
    [self getCString:&characters[0] maxLength:length];
    for (int i = 0; i < length / 2; ++i) {
        char character = characters[length - i - 1];
        characters[length - i - 1] = characters[i];
        characters[i] = character;
    }
    characters[length] = '\0';

    NSString* ret = [[[NSString alloc] initWithCString:&characters[0]] autorelease];

    return ret;
}

@end
