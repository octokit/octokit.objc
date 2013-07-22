//
//  OCTContent.m
//  OctoKit
//
//  Created by Aron Cedercrantz on 14-07-2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTContent.h"
#import "OCTFileContent.h"
#import "OCTDirectoryContent.h"
#import "OCTSymlinkContent.h"
#import "OCTSubmoduleContent.h"

@interface OCTContent ()

// The type of content which the reciever represents.
@property (nonatomic, copy, readonly) NSString *type;

@end

@implementation OCTContent

#pragma mark Class Cluster

+ (NSDictionary *)contentClassesByType {
	return @{
		@"file": OCTFileContent.class,
		@"dir": OCTDirectoryContent.class,
		@"symlink": OCTSymlinkContent.class,
		@"submodule": OCTSubmoduleContent.class,
	};
}

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"SHA": @"sha",
	}];
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
	NSString *type = JSONDictionary[@"type"];
	NSAssert(type != nil, @"OCTContent JSON dictionary must contain a type string.");
	Class class = self.contentClassesByType[type];
	NSAssert(class != Nil, @"No known OCTContent class for the type '%@'.", type);
	return class;
}

@end
