//
//  OCTClient+Notifications.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Notifications.h"
#import "NSDateFormatter+OCTFormattingAdditions.h"
#import "OCTClient+Private.h"
#import "OCTNotification.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTClient (Notifications)

- (RACSignal *)fetchNotificationsNotMatchingEtag:(NSString *)etag includeReadNotifications:(BOOL)includeRead updatedSince:(NSDate *)since {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"all"] = @(includeRead);

	if (since != nil) {
		parameters[@"since"] = [NSDateFormatter oct_stringFromDate:since];
	}
	NSURLRequest *request = [self requestWithMethod:@"GET" path:@"notifications" parameters:parameters notMatchingEtag:etag];
	return [self enqueueRequest:request resultClass:OCTNotification.class];
}

- (RACSignal *)markNotificationThreadAsReadAtURL:(NSURL *)threadURL {
	return [self patchThreadURL:threadURL withReadStatus:YES];
}

- (RACSignal *)patchThreadURL:(NSURL *)threadURL withReadStatus:(BOOL)read {
	NSParameterAssert(threadURL != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableURLRequest *request = [self requestWithMethod:@"PATCH" path:@"" parameters:@{ @"read": @(read) }];
	request.URL = threadURL;
	return [[self enqueueRequest:request resultClass:nil] ignoreValues];
}

- (RACSignal *)muteNotificationThreadAtURL:(NSURL *)threadURL {
	NSParameterAssert(threadURL != nil);

	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:@"" parameters:@{ @"ignored": @YES }];
	request.URL = [threadURL URLByAppendingPathComponent:@"subscription"];
	return [[self enqueueRequest:request resultClass:nil] ignoreValues];
}

@end
