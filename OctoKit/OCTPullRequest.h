//
//  OCTPullRequest.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTRepository;

// A pull request on a repository.
@interface OCTPullRequest : OCTObject

// The webpage URL for this pull request.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The title of this pull request.
@property (nonatomic, copy, readonly) NSString *title;

// The repository that the pull request would be merged into.
@property (nonatomic, strong, readonly) OCTRepository *baseRepository;

// The name of the branch that the pull request would be merged into.
@property (nonatomic, copy, readonly) NSString *baseBranch;

// The repository that the pull request originates from. This may be the same as
// the `baseRepository`.
@property (nonatomic, strong, readonly) OCTRepository *headRepository;

// The name of the branch that the pull request originates from.
@property (nonatomic, copy, readonly) NSString *headBranch;

@end
