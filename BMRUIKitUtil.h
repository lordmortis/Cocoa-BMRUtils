//
//  BMRUIKitUtil.h
//
//  Created by Brendan Ragan on 26/10/11.
//  Copyright (c) 2011 Brendan Ragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (BMRUIKitUtil)

+(id)stringWithRect:(CGRect)rect;
+(id)stringWithPoint:(CGPoint)point;
+(id)stringWithSize:(CGSize)size;

@end

@interface UIColor (BMRUIKitUtil)

-(NSString*)hexStringValue;

+(UIColor*)colorFromString:(NSString*)string;

@end

@interface UILabel (BMRUIKitUtil)

-(void)resizeFontToFit;

@end

@interface BMRUIKitUtil : NSObject

+(void)showError:(NSError*)error;
+(BOOL)iPad;
+(BOOL)retinaDisplay;
+(UIColor*)colorFromString:(NSString*)string;
+(CGSize)sizeFromString:(NSString*)string;

@end
