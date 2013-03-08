//
//  RACSignal+OCTClientAdditions.m
//  OctoKit
//
//  Created by Alan Rogers on 8/03/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RACSignal+OCTClientAdditions.h"
#import "OCTResponse.h"

@implementation RACSignal (OCTClientAdditions)

- (RACSignal *)oct_parsedResult {
	return [self map:^(OCTResponse *response) {
		NSAssert([response isKindOfClass:OCTResponse.class], @"Expected signal value to be an OCTResponse, but was %@", NSStringFromClass(response.class));
		return response.parsedResult;
	}];
}

@end
