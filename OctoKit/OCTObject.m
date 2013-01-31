//
//  OCTObject.m
//  OctoKit
//
//  Created by Josh Abernathy on 1/14/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTObject.h"
#import "OCTServer.h"
#import "OCTObject+Private.h"

// This shouldn't be used for anything new. It exists solely for backwards
// compatibility.
static NSString * const OCTObjectModelVersionKey = @"OCTObjectModelVersionKey";

@interface OCTObject ()

@property (nonatomic, strong, readwrite) OCTServer *server;

@end

@implementation OCTObject

#pragma mark MTLModel

- (instancetype)init {
	self = [super init];
	if (self == nil) return nil;

	self.server = OCTServer.dotComServer;

	return self;
}

- (instancetype)initWithExternalRepresentation:(NSDictionary *)externalRepresentation {
	// Manually migrate if we find the old model version key.
	if (externalRepresentation[OCTObjectModelVersionKey] != nil) {
		NSUInteger version = [externalRepresentation[OCTObjectModelVersionKey] unsignedIntegerValue];
		if (version < self.class.modelVersion) externalRepresentation = [self.class migrateExternalRepresentation:externalRepresentation fromVersion:version];
	}

	return [super initWithExternalRepresentation:externalRepresentation];
}

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [[super externalRepresentationKeyPathsByPropertyKey] mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"objectID": @"id",
		// For local persistence only (not present in JSON)
		@"baseURL": @"OCTServer_baseURL",
		@"server": @"OCTServer_server"
	}];

	return keys;
}

- (NSDictionary *)externalRepresentation {
	NSMutableDictionary *filteredRepresentation = [[[super externalRepresentation] mtl_filterEntriesUsingBlock:^ BOOL (id _, id value) {
		return ![value isEqual:NSNull.null];
	}] mutableCopy];

	// So that older versions of GHfM don't crash outright if they try to read
	// this representation, we include the model version key they know about.
	filteredRepresentation[OCTObjectModelVersionKey] = @(self.class.modelVersion);

	return filteredRepresentation;
}

+ (NSValueTransformer *)objectIDTransformer {
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (id objectID) {
			// Sometimes issues have a String ID :(
			if ([objectID isKindOfClass:NSNumber.class]) {
				return [objectID stringValue];
			} else {
				return objectID;
			}
		}
		reverseBlock:^ id (NSString *str) {
			if (str == nil) return nil;

			return [NSDecimalNumber decimalNumberWithString:str];
		}];
}

+ (NSValueTransformer *)baseURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)serverTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTServer.class];
}

#pragma mark Properties

- (void)setBaseURL:(NSURL *)baseURL {
	if ([_baseURL isEqual:baseURL]) return;
	if (baseURL == nil || [baseURL.host isEqual:@"api.github.com"]) {
		_baseURL = nil;
	} else {
		NSString *baseURLString = [NSString stringWithFormat:@"%@://%@", baseURL.scheme, baseURL.host];
		_baseURL = [NSURL URLWithString:baseURLString];
	}

	self.server = [OCTServer serverWithBaseURL:self.baseURL];
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.server.hash ^ self.objectID.hash;
}

- (BOOL)isEqual:(OCTObject *)obj {
	if (self == obj) return YES;
	if (![obj isMemberOfClass:self.class]) return NO;
	
	if (![obj.server isEqual:self.server]) return NO;

	return [obj.objectID isEqual:self.objectID];
}

@end
