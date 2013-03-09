//
//  RACSignal+OCTClientAdditions.h
//  OctoKit
//
//  Created by Alan Rogers on 8/03/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

// Convenience category to retreive parsedResults from OCTResponses.
@interface RACSignal (OCTClientAdditions)

// This method assumes that the receiver is a signal of OCTResponses.
//
// Returns a signal that maps the receiver to become a signal of
// OCTResponse.parsedResult.
- (RACSignal *)oct_parsedResults;

@end
