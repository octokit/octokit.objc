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
@property (atomic, copy, readonly) NSString *login;

// The full name of this entity.
//
// Returns `login` if no name is explicitly set.
@property (atomic, copy, readonly) NSString *name;

// The short biography associated with this account.
@property (atomic, copy, readonly) NSString *bio;

// The OCTRepository objects associated with this entity.
//
// OCTClient endpoints do not actually set this property. It is provided as
// a convenience for persistence and model merging.
@property (atomic, copy) NSArray *repositories;

// The email address for this account.
@property (atomic, copy, readonly) NSString *email;

// The URL for any avatar image.
@property (atomic, copy, readonly) NSURL *avatarURL;

// The web URL for this account.
@property (atomic, copy, readonly) NSURL *HTMLURL;

// A reference to a blog associated with this account.
@property (atomic, copy, readonly) NSString *blog;

// The name of a company associated with this account.
@property (atomic, copy, readonly) NSString *company;

// The location associated with this account.
@property (atomic, copy, readonly) NSString *location;

// The total number of collaborators that this account has on their private repositories.
@property (atomic, assign, readonly) NSUInteger collaborators;

// The number of public repositories owned by this account.
@property (atomic, assign, readonly) NSUInteger publicRepoCount;

// The number of private repositories owned by this account.
@property (atomic, assign, readonly) NSUInteger privateRepoCount;

// The number of public gists owned by this account.
@property (atomic, assign, readonly) NSUInteger publicGistCount;

// The number of private gists owned by this account.
@property (atomic, assign, readonly) NSUInteger privateGistCount;

// The number of followers for this account.
@property (atomic, assign, readonly) NSUInteger followers;

// The number of following for this account.
@property (atomic, assign, readonly) NSUInteger following;

// The number of kilobytes occupied by this account's repositories on disk.
@property (atomic, assign, readonly) NSUInteger diskUsage;

// The plan that this account is on.
@property (atomic, strong, readonly) OCTPlan *plan;

// The date of joined on of this account
@property (nonatomic, copy, readonly) NSDate *createdAt;
// Updates the receiver's repositories with data from the set of remote
// repositories.
- (void)mergeRepositoriesWithRemoteCounterparts:(NSArray *)remoteRepositories;

@end
