//
//  BMRUtil.h
//
//  Created by Brendan Ragan on 26/10/11.
//  Copyright (c) 2011 Brendan Ragan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BMRUtil)

+(id)stringWithData:(NSData*)data andEncoding:(NSStringEncoding)encoding;
-(NSData *)dataHexString;
-(NSString*)fullUrlWithBaseString:(NSString *)base;

@end

@interface NSData (BMRUtil)

-(NSString*)stringValue;
-(NSString*)stringValueWithEncoding:(NSStringEncoding)encoding;
-(BOOL)isEqualToMD5Data:(NSData*)md5Data;
-(NSString*)hexStringValue;
-(NSData*)md5;
+(NSData *)generateRandomWithByteLength:(NSUInteger)length;

@end

@interface NSDictionary (BMRUtil)

+(NSDictionary*)dictionaryWithDictionaries:(NSArray*)dicts;

@end

@interface BMRUtil : NSObject

@end
