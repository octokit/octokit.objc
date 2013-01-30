//
//  OCTEntity.m
//  OctoClient
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

@interface OCTEntity ()

@property (nonatomic, readwrite, strong) OCTPlan *plan;

@end

@implementation OCTEntity

#pragma mark Properties

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
	[self mergeRepositoriesWithRemoteCountparts:entity.repositories];
}

+ (NSDictionary *)migrateExternalRepresentation:(NSDictionary *)dictionary fromVersion:(NSUInteger)fromVersion {
	NSMutableDictionary *convertedDictionary = [[super migrateExternalRepresentation:dictionary fromVersion:fromVersion] mutableCopy];
	
	if (fromVersion < 2) {
		convertedDictionary[OCTEntityPublicRepoCountKey] = dictionary[@"public_repo_count"] ?: @0;
		convertedDictionary[OCTEntityOwnedPrivateRepoCountKey] = dictionary[@"owned_private_repo_count"] ?: @0;
	}
	
	return convertedDictionary;
}

#pragma mark Merging

- (void)mergeRepositoriesWithRemoteCountparts:(NSArray *)remoteRepositories {
	if (remoteRepositories == nil) {
		// A nil array means that repositories were never fetched. An empty
		// array means that there are no remote repositories, so we should clear
		// ours out.
		return;
	}

	NSMutableArray *reposToAdd = [remoteRepositories mutableCopy];
	[reposToAdd removeObjectsInArray:self.repositories];
	
	NSMutableArray *reposToRemove = [self.repositories mutableCopy];
	[reposToRemove removeObjectsInArray:remoteRepositories];
	
	NSMutableArray *allRepos = [self.repositories mutableCopy] ? : [NSMutableArray array];
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

@end
