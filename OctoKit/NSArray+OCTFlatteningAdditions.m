//
//  NSArray+OCTFlatteningAdditions.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-01-09.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSArray+OCTFlatteningAdditions.h"

@implementation NSArray (OCTFlatteningAdditions)

- (NSArray *)oct_flattenedArray {
	NSMutableArray *flattened = [NSMutableArray arrayWithCapacity:self.count];
	for (id object in self) {
		if ([object isKindOfClass:NSArray.class]) {
			[flattened addObjectsFromArray:[object oct_flattenedArray]];
		} else {
			[flattened addObject:object];
		}
	}
	
	return flattened;
}

@end
