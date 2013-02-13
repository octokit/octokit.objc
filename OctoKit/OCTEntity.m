//
//  OCTEntity.m
//  OctoKit
//
//  Created by Josh Abernathy on 1/21/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTEntity.h"
#import "OCTPlan.h"
#import "OCTRepository.h"

// Keys used in parsing and migration.
static NSString * const OCTEntityPublicRepoCountKey = @"public_repos";
static NSString * const OCTEntityOwnedPrivateRepoCountKey = @"owned_private_repos";

@implementation OCTEntity

#pragma mark Properties

@synthesize name = _name;

- (NSString *)name {
	return _name ?: self.login;
}

#pragma mark MTLModel

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
	NSMutableDictionary *keys = [[super externalRepresentationKeyPathsByPropertyKey] mutableCopy];
	
	[keys addEntriesFromDictionary:@{
		@"avatarURL": @"avatar_url",
		@"publicRepoCount": OCTEntityPublicRepoCountKey,
		@"privateRepoCount": OCTEntityOwnedPrivateRepoCountKey,
		@"diskUsage": @"disk_usage",
	}];

	return keys;
}

+ (NSUInteger)modelVersion {
	return 2;
}

+ (NSValueTransformer *)repositoriesTransformer {
	return [NSValueTransformer mtl_externalRepresentationArrayTransformerWithModelClass:OCTRepository.class];
}

+ (NSValueTransformer *)avatarURLTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)planTransformer {
	return [NSValueTransformer mtl_externalRepresentationTransformerWithModelClass:OCTPlan.class];
}

- (void)mergeRepositoriesFromModel:(OCTEntity *)entity {
	[self mergeRepositoriesWithRemoteCounterparts:entity.repositories];
}

#pragma mark Merging

- (void)mergeRepositoriesWithRemoteCounterparts:(NSArray *)remoteRepositories {
	if (remoteRepositories == nil) {
		// A nil array means that repositories were never fetched. An empty
		// array means that there are no remote repositories, so we should clear
		// ours out.
		return;
	}

	NSArray *localRepositories = [self.repositories copy];

	NSMutableArray *reposToAdd = [remoteRepositories mutableCopy];
	[reposToAdd removeObjectsInArray:localRepositories];
	
	NSMutableArray *reposToRemove = [localRepositories mutableCopy];
	[reposToRemove removeObjectsInArray:remoteRepositories];
	
	NSMutableArray *allRepos = [localRepositories mutableCopy] ?: [NSMutableArray array];
	[allRepos addObjectsFromArray:reposToAdd];
	[allRepos removeObjectsInArray:reposToRemove];
	
	// update every repo with the data from its remote equivalent
	for (OCTRepository *repo in allRepos) {
		NSUInteger index = [remoteRepositories indexOfObject:repo];
		if (index == NSNotFound) continue;
		
		OCTRepository *remoteCounterpart = remoteRepositories[index];
		[repo mergeValuesForKeysFromModel:remoteCounterpart];
	}
	
	self.repositories = allRepos;
}

#pragma mark Migration

+ (NSDictionary *)dictionaryValueFromArchivedExternalRepresentation:(NSDictionary *)externalRepresentation version:(NSUInteger)fromVersion {
	NSMutableDictionary *dictionaryValue = [NSMutableDictionary dictionaryWithCapacity:externalRepresentation.count];

	// These keys will be copied as-is, one-to-one.
	NSArray *keysToCopy = @[ @"login", @"name", @"email", @"blog", @"company", @"collaborators" ];
	for (NSString *key in keysToCopy) {
		if (externalRepresentation[key] == nil) continue;

		dictionaryValue[key] = externalRepresentation[key];
	}

	// Although some of these keys match JSON key paths, the format of this
	// external representation is fixed (since it's always old data), thus the
	// hard-coding.
	dictionaryValue[@"repositories"] = [self.repositoriesJSONTransformer transformedValue:externalRepresentation[@"repositories"]] ?: NSNull.null;
	dictionaryValue[@"avatarURL"] = [self.avatarURLJSONTransformer transformedValue:externalRepresentation[@"avatar_url"]] ?: NSNull.null;
	dictionaryValue[@"publicRepoCount"] = externalRepresentation[@"public_repos"] ?: externalRepresentation[@"public_repo_count"] ?: @0;
	dictionaryValue[@"privateRepoCount"] = externalRepresentation[@"owned_private_repos"] ?: externalRepresentation[@"owned_private_repo_count"] ?: @0;
	dictionaryValue[@"diskUsage"] = externalRepresentation[@"disk_usage"] ?: @0;
	dictionaryValue[@"plan"] = [self.planJSONTransformer transformedValue:externalRepresentation[@"plan"]] ?: NSNull.null;

	return dictionaryValue;
}

@end
