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

+ (NSSet *)propertyKeys {
	NSMutableSet *keys = [super.propertyKeys mutableCopy];

	// This is a derived property.
	[keys removeObject:@keypath(OCTObject.new, baseURL)];

	return keys;
}

+ (NSUInteger)modelVersion {
	return 5;
}

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"objectID": @"id",
		@"server": NSNull.null,
	}];
}

+ (NSValueTransformer *)objectIDJSONTransformer {
	return [MTLValueTransformer
		reversibleTransformerWithForwardBlock:^(NSNumber *num) {
			return num.stringValue;
		} reverseBlock:^ id (NSString *str) {
			if (str == nil) return nil;

			return [NSDecimalNumber decimalNumberWithString:str];
		}];
}

#pragma mark Properties

- (NSURL *)baseURL {
	return self.server.baseURL;
}

- (void)setBaseURL:(NSURL *)baseURL {
	if ([self.baseURL isEqual:baseURL]) return;

	if (baseURL == nil || [baseURL.host isEqual:@"api.github.com"]) {
		self.server = OCTServer.dotComServer;
	} else {
		NSString *baseURLString = [NSString stringWithFormat:@"%@://%@", baseURL.scheme, baseURL.host];
		self.server = [OCTServer serverWithBaseURL:[NSURL URLWithString:baseURLString]];
	}
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.server.hash ^ self.objectID.hash;
}

- (BOOL)isEqual:(OCTObject *)obj {
	if (self == obj) return YES;
	if (![obj isMemberOfClass:self.class]) return NO;
	
	return [obj.server isEqual:self.server] && [obj.objectID isEqual:self.objectID];
}

@end
