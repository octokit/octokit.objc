//
//  OCTClient+Repositories.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@class OCTRepository;

@interface OCTClient (Repositories)

// Fetches the content at `relativePath` at the given `reference` from the
// `repository`.
//
// In case `relativePath` is `nil` the contents of the repository root will be
// sent.
//
// repository   - The repository from which the file should be fetched.
// relativePath - The relative path (from the repository root) of the file that
//                should be fetched, may be `nil`.
// reference    - The name of the commit, branch or tag, may be `nil` in which
//                case it defaults to the default repo branch.
//
// Returns a signal which will send zero or more OCTContents depending on if the
// relative path resolves at all or, resolves to a file or directory.
- (RACSignal *)fetchRelativePath:(NSString *)relativePath inRepository:(OCTRepository *)repository reference:(NSString *)reference;

// Fetches the readme of a `repository`.
//
// repository - The repository for which the readme should be fetched.
//
// Returns a signal which will send zero or one OCTContent.
- (RACSignal *)fetchRepositoryReadme:(OCTRepository *)repository;

// Fetches a specific repository owned by the given `owner` and named `name`.
//
// name  - The name of the repository, must be a non-empty string.
// owner - The owner of the repository, must be a non-empty string.
//
// Returns a signal of zero or one OCTRepository.
- (RACSignal *)fetchRepositoryWithName:(NSString *)name owner:(NSString *)owner;

@end
