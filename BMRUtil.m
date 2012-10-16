//
//  BMRUtil.h
//
//  Created by Brendan Ragan on 26/10/11.
//  Copyright (c) 2011 Brendan Ragan. All rights reserved.
//

#import "BMRUtil.h"

#import <CommonCrypto/CommonDigest.h>

#include <stdlib.h>

@implementation NSString (BMRUtil)

+(id)stringWithData:(NSData*)data andEncoding:(NSStringEncoding)encoding {
	return [[NSString alloc] initWithData:data encoding:encoding];
}

-(NSString*)fullUrlWithBaseURL:(NSURL*)base {
//	rootURL = [NSString stringWithFormat:@"%@://%@/", [base scheme], [base host]];
	return nil;
}

-(NSString*)fullUrlWithBaseString:(NSString *)base {
	NSRange position;
	if ([base characterAtIndex:base.length - 1] != '/') {
		position = [base rangeOfString:@"/" options:NSBackwardsSearch];
		base = [base substringToIndex:position.location + 1];
	}

	position =  [self rangeOfString:@"http"];	
	if (position.location == 0) {
		return self;
	}
	
	if ([self characterAtIndex:0] == '/') {
		NSURL *temp = [NSURL URLWithString:base];
		return [NSString stringWithFormat:@"%@://%@:%@%@", [temp scheme], [temp host], [temp port], self];
	} else 
		return [NSString stringWithFormat:@"%@%@", base, self];
	
	return @"ERROR OCCURED";
}

-(NSData *) dataHexString {
    const char * bytes = [self cStringUsingEncoding: NSUTF8StringEncoding];
    NSUInteger length = strlen(bytes);
	UInt8* dataBytes = calloc(length / 2, sizeof(char));
	UInt8 byte_part2 = 0;
	
	for (int index = 0; index < length; index++) {
		byte_part2 = ((index % 2) != 0) * 4;

		if (bytes[index] < 48) {
			NSLog(@"NSData (BMRUtil) Invalid Hex string: %@", self);
			free(dataBytes);
			return nil;
		} else if (bytes[index] <= 57) {
			dataBytes[index/2] = (dataBytes[index / 2] << byte_part2) + bytes[index] - 48;
		} else if (bytes[index] < 65) {
			NSLog(@"NSData (BMRUtil) Invalid Hex string: %@", self);
			free(dataBytes);
			return nil;
		} else if (bytes[index] <= 70) {
			dataBytes[index/2] = (dataBytes[index / 2] << byte_part2) + bytes[index] - 55;
		} else if (bytes[index] < 97) {	
			NSLog(@"NSData (BMRUtil) Invalid Hex string: %@", self);
			free(dataBytes);
			return nil;
		} else if (bytes[index] <= 102) {
			dataBytes[index/2] = (dataBytes[index / 2] << byte_part2) + bytes[index] - 87;
		} else {
			NSLog(@"NSData (BMRUtil) Invalid Hex string: %@", self);
			free(dataBytes);
			return nil;
		}
	}
	
	NSData *data = [NSData dataWithBytes:dataBytes length:length / 2];
	free(dataBytes);
    return data;
}


@end

@implementation NSData (BMRUtil)

-(NSString*)stringValue {
	return [NSString stringWithData:self andEncoding:NSUTF8StringEncoding];
}

-(NSString*)stringValueWithEncoding:(NSStringEncoding)encoding {
	return [NSString stringWithData:self andEncoding:encoding];
}

-(BOOL)isEqualToMD5Data:(NSData*)md5Data {
	return [[self md5] isEqualToData:md5Data];
}

-(NSData*)md5 {
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
	CC_MD5(self.bytes, self.length, md5Buffer);
	
	NSData *md5value = [NSData dataWithBytes:md5Buffer length:CC_MD5_DIGEST_LENGTH];
	return md5value;
}

-(NSString*)hexStringValue {
	static const char hexdigits[] = "0123456789ABCDEF";
	const size_t numBytes = [self length];
	const unsigned char* bytes = [self bytes];
	char *strbuf = (char *)malloc(numBytes * 2 + 1);
	char *hex = strbuf;
	NSString *hexBytes = nil;
	
	for (int i = 0; i<numBytes; ++i) {
		const unsigned char c = *bytes++;
		*hex++ = hexdigits[(c >> 4) & 0xF];
		*hex++ = hexdigits[(c ) & 0xF];
	}
	*hex = 0;
	hexBytes = [NSString stringWithUTF8String:strbuf];
	free(strbuf);
	return hexBytes;
}

+(NSData *)generateRandomWithByteLength:(NSUInteger)length {
    uint8_t *databytes = malloc(sizeof(uint8_t) * length);
    for(int i = 0; i < length; i++) {
        databytes[i] = arc4random_uniform(255);
    }
    
    NSData *data = [NSData dataWithBytes:databytes length:length];
    
    free(databytes);
    
    return data;
}

@end

@implementation NSDictionary (BMRUtil)

+(NSDictionary*)dictionaryWithDictionaries:(NSArray*)dicts {
    NSMutableDictionary *combined = [NSMutableDictionary dictionaryWithCapacity:dicts.count * 2];
    
    for(NSObject *object in dicts) {
        if ([object isKindOfClass:NSDictionary.class]) {
            NSDictionary *dictObject = (NSDictionary*)object;
            for(NSObject<NSCopying> *key in dictObject.allKeys) {
                combined[key] = dictObject[key];
            }
        } else {
            NSLog(@"ERROR: %@ is not a dictionary or subclass of dictionary", object);
        }
    }
    
    return combined;
}

@end

@implementation BMRUtil



@end

