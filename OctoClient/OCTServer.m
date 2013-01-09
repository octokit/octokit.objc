//
//  OCTServer.m
//  OctoClient
//
//  Created by Alan Rogers on 18/10/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTServer.h"
#import "OCTServer+Private.h"

NSString * const OCTServerDotComAPIEndpoint = @"https://api.github.com";
NSString * const OCTServerDotComBaseWebURL = @"https://github.com";
NSString * const OCTServerEnterpriseAPIEndpointPathComponent = @"api/v3";

// Enterprise defaults to HTTP, and not all instances have HTTPS set up.
NSString * const OCTServerDefaultEnterpriseScheme = @"http";

@interface OCTServer ()

@property (nonatomic, copy, readwrite) NSURL *baseURL;

@end

@implementation OCTServer

+ (instancetype)dotComServer {
	static OCTServer *dotComServer = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dotComServer = [[self alloc] initWithBaseURL:nil];
	});
	return dotComServer;
}

+ (instancetype)serverWithBaseURL:(NSURL *)baseURL {
	if (baseURL == nil) return self.dotComServer;

	return [[OCTServer alloc] initWithBaseURL:baseURL];
}

#pragma mark Lifecycle

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
	self = [super init];
	if (self == nil) return nil;

	_baseURL = baseURL;

	return self;
}

- (NSDictionary *)externalRepresentation {
	return [super.externalRepresentation mtl_filterEntriesUsingBlock:^ BOOL (id _, id value) {
		return ![value isEqual:NSNull.null];
	}];
}

+ (NSValueTransformer *)baseURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark Properties

- (NSURL *)APIEndpoint {
	if (self.baseURL == nil) {
		// This environment variable can be used to debug API requests by
		// redirecting them to a different URL.
		NSString *endpoint = NSProcessInfo.processInfo.environment[@"API_ENDPOINT"];
		if (endpoint != nil) return [NSURL URLWithString:endpoint];

		return [NSURL URLWithString:OCTServerDotComAPIEndpoint];
	} else {
		return [self.baseURL URLByAppendingPathComponent:OCTServerEnterpriseAPIEndpointPathComponent isDirectory:YES];
	}
}

- (NSURL *)baseWebURL {
	if (self.baseURL == nil) {
		return [NSURL URLWithString:OCTServerDotComBaseWebURL];
	} else {
		return self.baseURL;
	}
}

- (BOOL)isEnterprise {
	return self.baseURL != nil;
}

#pragma mark NSObject

- (BOOL)isEqual:(OCTServer *)object {
	if (object == self) return YES;
	if (![object isKindOfClass:self.class]) return NO;

	if (self.baseURL == nil && object.baseURL == nil) return YES;

	return [self.baseURL isEqual:object.baseURL];
}

- (NSUInteger)hash {
	return self.baseURL.hash;
}

@end
