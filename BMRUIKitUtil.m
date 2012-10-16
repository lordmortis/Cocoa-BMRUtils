//
//  BMRUIKitUtil.m
//
//  Created by Brendan Ragan on 26/10/11.
//  Copyright (c) 2011 Brendan Ragan. All rights reserved.
//


#import "BMRUIKitUtil.h"

@implementation NSString (BMRUIKitUtil)

+(id)stringWithRect:(CGRect)rect {
	return [NSString stringWithFormat:@"%f,%f - %fx%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

+(id)stringWithPoint:(CGPoint)point {
	return [NSString stringWithFormat:@"%f,%f", point.x, point.y];
}

+(id)stringWithSize:(CGSize)size {
	return [NSString stringWithFormat:@"%fx%f", size.width, size.height];
}

@end 

@implementation UIColor (BMRUIKitUtil) 

-(NSString*)hexStringValue {
	if (self == [UIColor blackColor])
		return @"black";
	if (self == [UIColor whiteColor])
		return @"white";
	if (self == [UIColor grayColor])
		return @"gray";
	if (self == [UIColor redColor])
		return @"red";
	if (self == [UIColor greenColor])
		return @"green";
	if (self == [UIColor blueColor])
		return @"blue";	
	
	CGFloat red, green, blue, alpha;
	if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
		NSString *string = [NSString stringWithFormat:@"R: %f, G: %f, B: %f", red, green, blue];
		if (alpha < 1.0)
			return [NSString stringWithFormat:@"%@ Alpha: %f", string, alpha];
		else
			return string;
	} else
		return @"Unknown";
}

+(UIColor*)colorFromString:(NSString*)string {	
	return [BMRUIKitUtil colorFromString:string];
}

@end

@implementation UILabel (BMRUIKitUtil)

-(void)resizeFontToFit {
	UIFont *font = self.font;
	CGFloat fontSize = font.pointSize;
	NSString *text = self.text;
	CGSize size = self.frame.size;
	CGSize temp = [text sizeWithFont:font];
	if (temp.width <= size.width && temp.height <= size.height)
		return;
	
	while(temp.width > size.width || temp.height > size.height) {
		fontSize = fontSize - 1.0f;
		font = [font fontWithSize:fontSize];
		temp = [text sizeWithFont:font];
	}
	self.font = font;	
}

@end


@implementation BMRUIKitUtil

+ (void)showError:(NSError*)error {
	UIAlertView *errorbox = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[errorbox show];
}

+(BOOL)iPad {
	static BOOL checked = false;
	static BOOL iPad = NO;
	if (!checked) {
		if (NSClassFromString(@"UISplitViewController") != nil && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			iPad = YES;
		}
		else {
			iPad = NO;
		}
		
		checked = YES;
	}
	
	return iPad;	
}

+(BOOL)retinaDisplay {
	static BOOL checked = NO;
	static BOOL retina = NO;
	
	if (!checked) {
		if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&		
			([UIScreen mainScreen].scale == 2.0))
			retina = YES;
		checked = YES;
	}
	
	return retina;
}

+(UIColor*)colorFromString:(NSString*)string {
	if ([string characterAtIndex:0] == '#') {
		NSScanner *scanner = [NSScanner scannerWithString:[string substringFromIndex:1]];
		[scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]];
		NSUInteger baseColor1;
		[scanner scanHexInt:&baseColor1];
		if (string.length == 9) {
			CGFloat red   = ((baseColor1 & 0xFF000000) >> 24) / 255.0f;
			CGFloat green = ((baseColor1 & 0x00FF0000) >>  16) / 255.0f;
			CGFloat blue  =  ((baseColor1 & 0x0000FF00) >> 8)/ 255.0f;
			CGFloat alpha  =  (baseColor1 & 0x000000FF) / 255.0f;
			return [UIColor colorWithRed:red
								   green:green
									blue:blue
								   alpha:alpha];	
		} else if (string.length == 5) {
			CGFloat red   = ((baseColor1 & 0xF000) >> 12) / 16.0f;
			CGFloat green = ((baseColor1 & 0x0F00) >>  8) / 16.0f;
			CGFloat blue  =  ((baseColor1 & 0x00F0) >> 4)/ 16.0f;
			CGFloat alpha  =  (baseColor1 & 0x000F) / 16.0f;
			return [UIColor colorWithRed:red
								   green:green
									blue:blue
								   alpha:alpha];			
		} else if (string.length == 7) {
			CGFloat red   = ((baseColor1 & 0xFF0000) >> 16) / 255.0f;
			CGFloat green = ((baseColor1 & 0x00FF00) >>  8) / 255.0f;
			CGFloat blue  =  (baseColor1 & 0x0000FF) / 255.0f;
			return [UIColor colorWithRed:red
								   green:green
									blue:blue
								   alpha:1.0f];
		} else if (string.length == 4) {
			CGFloat red   = ((baseColor1 & 0xF00) >> 8) / 16.0f;
			CGFloat green = ((baseColor1 & 0x0F0) >>  4) / 16.0f;
			CGFloat blue  =  (baseColor1 & 0x00F) / 16.0f;
			return [UIColor colorWithRed:red
								   green:green
									blue:blue
								   alpha:1.0f];			
		}
	} else {
		if ([string caseInsensitiveCompare:@"black"] == NSOrderedSame)
			return [UIColor blackColor];
		if ([string caseInsensitiveCompare:@"white"] == NSOrderedSame)
			return [UIColor whiteColor];
		if (([string caseInsensitiveCompare:@"gray"] == NSOrderedSame) || 
			([string caseInsensitiveCompare:@"grey"] == NSOrderedSame))
			return [UIColor grayColor];
		if ([string caseInsensitiveCompare:@"red"] == NSOrderedSame)
			return [UIColor redColor];
		if ([string caseInsensitiveCompare:@"green"] == NSOrderedSame)
			return [UIColor greenColor];
		if ([string caseInsensitiveCompare:@"blue"] == NSOrderedSame)
			return [UIColor blueColor];
	}
	
	return [UIColor greenColor];
}

+(CGSize)sizeFromString:(NSString*)string {
	CGSize size = CGSizeMake(0.0f, 0.0f);
	NSCharacterSet *separatorString = [NSCharacterSet characterSetWithCharactersInString:@","];
	CGFloat value;
	NSScanner *scanner = [NSScanner scannerWithString:string];
	[scanner scanFloat:&value];
	size.width = value;
	if (![scanner isAtEnd]) {
		[scanner scanCharactersFromSet:separatorString intoString:nil];
		[scanner scanFloat:&value];
		size.height = value;
	}
	
	return size;
}

@end