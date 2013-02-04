//
//  OCTEntity.h
//  OctoKit
//
//  Created by Josh Abernathy on 1/21/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTPlan;

// Represents any GitHub object which is capable of owning repositories.
@interface OCTEntity : OCTObject

// The unique name for this entity, used in GitHub URLs.
@property (nonatomic, copy, readonly) NSString *login;

// The full name of this entity.
//
// Returns `login` if no name is explicitly set.
@property (nonatomic, copy, readonly) NSString *name;

// The OCTRepository objects associated with this entity.
//
// OCTClient endpoints do not actually set this property. It is provided as
// a convenience for persistence and model merging.
@property (atomic, copy) NSArray *repositories;

// The email address for this account.
@property (nonatomic, copy, readonly) NSString *email;

// The URL for any avatar image.
@property (nonatomic, copy, readonly) NSURL *avatarURL;

// A reference to a blog associated with this account.
@property (nonatomic, copy, readonly) NSString *blog;

// The name of a company associated with this account.
@property (nonatomic, copy, readonly) NSString *company;

// The total number of collaborators that this account has on their private repositories.
@property (nonatomic, assign, readonly) NSUInteger collaborators;

// The number of public repositories owned by this account.
@property (nonatomic, assign, readonly) NSUInteger publicRepoCount;

// The number of private repositories owned by this account.
@property (nonatomic, assign, readonly) NSUInteger privateRepoCount;

// The number of kilobytes occupied by this account's repositories on disk.
@property (nonatomic, assign, readonly) NSUInteger diskUsage;

// The plan that this account is on.
@property (nonatomic, strong, readonly) OCTPlan *plan;

// Updates the receiver's repositories with data from the set of remote
// repositories.
- (void)mergeRepositoriesWithRemoteCounterparts:(NSArray *)remoteRepositories;

@end
