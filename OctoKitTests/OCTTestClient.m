//
//  OCTTestClient.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-24.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTTestClient.h"

static BOOL OCTTestClientShouldSucceedOpeningURL = YES;
static RACReplaySubject *OCTTestClientOpenedURLs;

@implementation OCTTestClient

#pragma mark Lifecycle

+ (void)initialize {
	if (self != OCTTestClient.class) return;

	OCTTestClientOpenedURLs = [[RACReplaySubject replaySubjectWithCapacity:1] setNameWithFormat:@"+openedURLs"];
}

#pragma mark URL opening

+ (void)setShouldSucceedOpeningURL:(BOOL)shouldSucceed {
	OCTTestClientShouldSucceedOpeningURL = shouldSucceed;
}

+ (RACSignal *)openedURLs {
	return OCTTestClientOpenedURLs;
}

+ (BOOL)openURL:(NSURL *)webURL {
	NSParameterAssert(webURL != nil);

	[OCTTestClientOpenedURLs sendNext:webURL];
	return OCTTestClientShouldSucceedOpeningURL;
}

@end
