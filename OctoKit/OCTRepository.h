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

// The description of this repository.
@property (nonatomic, copy, readonly) NSString *repoDescription;

// Whether this repository is private to the owner.
@property (nonatomic, assign, getter = isPrivate, readonly) BOOL private;

// Whether this repository is a fork of another repository.
@property (nonatomic, assign, getter = isFork, readonly) BOOL fork;

// The date of the last push to this repository.
@property (nonatomic, strong, readonly) NSDate *datePushed;

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

@end
