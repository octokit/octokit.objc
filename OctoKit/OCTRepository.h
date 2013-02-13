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
@property (nonatomic, copy) NSString *name;

// The login of the account which owns this repository.
//
// This is the first half of a unique GitHub repository name, which follows the
// form `ownerLogin/name`.
@property (nonatomic, copy) NSString *ownerLogin;

// The description of this repository.
@property (nonatomic, copy) NSString *repoDescription;

// Whether this repository is private to the owner.
@property (nonatomic, assign, getter=isPrivate) BOOL private;

// The date of the last push to this repository.
@property (nonatomic, strong) NSDate *datePushed;

// The URL for pushing and pulling this repository over HTTPS.
@property (nonatomic, copy) NSURL *HTTPSURL;

// The URL for pushing and pulling this repository over SSH, formatted as
// a string because SSH URLs are not correctly interpreted by NSURL.
@property (nonatomic, copy) NSString *SSHURL;

// The URL for pulling this repository over the `git://` protocol.
@property (nonatomic, copy) NSURL *gitURL;

// The URL for visiting this repository on the web.
@property (nonatomic, copy) NSURL *HTMLURL;

// The number of users watching this repository.
@property (nonatomic, copy) NSNumber *watcherCount;

@end
