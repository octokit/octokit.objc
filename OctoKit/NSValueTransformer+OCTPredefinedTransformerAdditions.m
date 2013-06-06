//
//  NSValueTransformer+OCTPredefinedTransformerAdditions.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-02-02.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"
#import "NSDateFormatter+OCTFormattingAdditions.h"
#import <Mantle/MTLValueTransformer.h>

NSString * const OCTDateValueTransformerName = @"OCTDateValueTransformerName";

@implementation NSValueTransformer (OCTPredefinedTransformerAdditions)

#pragma mark Category Loading

+ (void)load {
	@autoreleasepool {
		MTLValueTransformer *dateValueTransformer = [MTLValueTransformer
			reversibleTransformerWithForwardBlock:^ id (id dateOrDateString) {
				// Some old model versions would serialize NSDates directly, so
				// handle that case too.
				if ([dateOrDateString isKindOfClass:NSDate.class]) {
					return dateOrDateString;
				} else if ([dateOrDateString isKindOfClass:NSString.class]) {
					return [NSDateFormatter oct_dateFromString:dateOrDateString];
				} else {
					return nil;
				}
			}
			reverseBlock:^ id (NSDate *date) {
				if (![date isKindOfClass:NSDate.class]) return nil;
				return [NSDateFormatter oct_stringFromDate:date];
			}];
		
		[NSValueTransformer setValueTransformer:dateValueTransformer forName:OCTDateValueTransformerName];
	}
}

@end
