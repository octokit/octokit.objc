//
//  OCTRepository.h
//  OctoKit
//
//  Created by Timothy Clem on 2/14/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A GitHub repository.
@interface OCTRepository : OCTObject

// The name of this repository, as used in GitHub URLs.
//
// This is the second half of a unique GitHub repository name, which follows the
// form `ownerLogin/name`.
@property (nonatomic, copy, readonly) NSString *name;

// The login of the account which owns this repository.
//
// This is the first half of a unique GitHub repository name, which follows the
// form `ownerLogin/name`.
@property (nonatomic, copy, readonly) NSString *ownerLogin;

// The URL for any avatar image.
@property (nonatomic, copy, readonly) NSURL *ownerAvatarURL;

// The description of this repository.
@property (nonatomic, copy, readonly) NSString *repoDescription;

// The language of this repository.
@property (nonatomic, copy, readonly) NSString *language;

// Whether this repository is private to the owner.
@property (nonatomic, assign, getter = isPrivate, readonly) BOOL private;

// Whether this repository is a fork of another repository.
@property (nonatomic, assign, getter = isFork, readonly) BOOL fork;

// The date of the last push to this repository.
@property (nonatomic, strong, readonly) NSDate *datePushed;

// The created date of this repository.
@property (nonatomic, strong, readonly) NSDate *dateCreated;

// The last updated date of this repository.
@property (nonatomic, strong, readonly) NSDate *dateUpdated;

// The number of watchers for this repository.
@property (nonatomic, assign, readonly) NSUInteger watchersCount;

// The number of forks for this repository.
@property (nonatomic, assign, readonly) NSUInteger forksCount;

// The number of stargazers for this repository.
@property (nonatomic, assign, readonly) NSUInteger stargazersCount;

// The number of open issues for this repository.
@property (nonatomic, assign, readonly) NSUInteger openIssuesCount;

// The number of subscribers for this repository.
@property (nonatomic, assign, readonly) NSUInteger subscribersCount;

// The URL for pushing and pulling this repository over HTTPS.
@property (nonatomic, copy, readonly) NSURL *HTTPSURL;

// The URL for pushing and pulling this repository over SSH, formatted as
// a string because SSH URLs are not correctly interpreted by NSURL.
@property (nonatomic, copy, readonly) NSString *SSHURL;

// The URL for pulling this repository over the `git://` protocol.
@property (nonatomic, copy, readonly) NSURL *gitURL;

// The URL for visiting this repository on the web.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The default branch's name. For empty repositories, this will be nil.
@property (nonatomic, copy, readonly) NSString *defaultBranch;

// The URL for the issues page in a repository.
//
// An issue number may be appended (as a path component) to this path to create
// an individual issue's HTML URL.
@property (nonatomic, copy, readonly) NSURL *issuesHTMLURL;

// Text match metadata, uses to highlight the search results.
@property (nonatomic, copy, readonly) NSArray *textMatches;

/// The parent of the fork, or nil if the repository isn't a fork. This is the
/// repository from which the receiver was forked.
///
/// Note that this is only populated on calls to
/// -[OCTClient fetchRepositoryWithName:owner:].
@property (nonatomic, copy, readonly) OCTRepository *forkParent;

/// The source of the fork, or nil if the repository isn't a fork. This is the
/// ultimate source for the network, which may be different from the
/// `forkParent`.
///
/// Note that this is only populated on calls to
/// -[OCTClient fetchRepositoryWithName:owner:].
@property (nonatomic, copy, readonly) OCTRepository *forkSource;

@end
