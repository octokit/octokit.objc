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
@property (nonatomic, copy) NSString *login;

// The full name of this entity.
//
// Returns `login` if no name is explicitly set.
@property (nonatomic, copy) NSString *name;

// The OCTRepository objects associated with this entity.
//
// Most endpoints do not actually set this property. It is provided mostly as
// a convenience.
@property (nonatomic, copy) NSArray *repositories;

// The email address for this account.
@property (nonatomic, copy) NSString *email;

// The URL for any avatar image.
@property (nonatomic, copy) NSURL *avatarURL;

// A reference to a blog associated with this account.
@property (nonatomic, copy) NSString *blog;

// The name of a company associated with this account.
@property (nonatomic, copy) NSString *company;

// The total number of collaborators that this account has on their private repositories.
@property (nonatomic, assign) NSUInteger collaborators;

// The number of public repositories owned by this account.
@property (nonatomic, assign) NSUInteger publicRepoCount;

// The number of private repositories owned by this account.
@property (nonatomic, assign) NSUInteger privateRepoCount;

// The number of kilobytes occupied by this account's repositories on disk.
@property (nonatomic, assign) NSUInteger diskUsage;

// The plan that this account is on.
@property (nonatomic, readonly, strong) OCTPlan *plan;

// Updates the receiver's repositories with data from the set of remote
// repositories.
- (void)mergeRepositoriesWithRemoteCounterparts:(NSArray *)remoteRepositories;

@end
