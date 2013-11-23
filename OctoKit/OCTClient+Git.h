//
//  OCTClient+Git.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@class OCTRepository;

@interface OCTClient (Git)

// Fetches the tree for the given reference.
//
// reference  - The SHA, branch, reference, or tag to fetch. May be nil, in
//              which case HEAD is fetched.
// repository - The repository from which the tree should be fetched. Cannot be
//              nil.
// recursive  - Should the tree be fetched recursively?
//
// Returns a signal which will send an OCTTree and complete or error.
- (RACSignal *)fetchTreeForReference:(NSString *)reference inRepository:(OCTRepository *)repository recursive:(BOOL)recursive;

// Creates a new tree.
//
// treeEntries - The `OCTTreeEntry` objects that should comprise the new tree.
//               This array must not be nil.
// repository  - The repository in which to create the tree. Cannot be nil.
// baseTreeSHA - The SHA of the tree upon which to base this new tree. This may
//               be nil to create an orphaned tree.
//
// Returns a signal which will send the created OCTTree and complete, or error.
- (RACSignal *)createTreeWithEntries:(NSArray *)treeEntries inRepository:(OCTRepository *)repository basedOnTreeWithSHA:(NSString *)baseTreeSHA;

// Fetches the blob identified by the given SHA.
//
// blobSHA    - The SHA of the blob to fetch. This must not be nil.
// repository - The repository from which the blob should be fetched. Cannot be
//              nil.
//
// Returns a signal which will send an NSData then complete, or error.
- (RACSignal *)fetchBlob:(NSString *)blobSHA inRepository:(OCTRepository *)repository;

// Creates a blob using the given text content.
//
// string     - The text for the new blob. This must not be nil.
// repository - The repository in which to create the blob. This must not be
//              nil.
// 
// Returns a signal which will send an NSString of the new blob's SHA then
// complete, or error.
- (RACSignal *)createBlobWithString:(NSString *)string inRepository:(OCTRepository *)repository;

// Fetches the commit identified by the given SHA.
//
// commitSHA  - The SHA of the commit to fetch. This must not be nil.
// repository - The repository from which the commit should be fetched. Cannot be
//              nil.
//
// Returns a signal which will send an `OCTCommit` then complete, or error.
- (RACSignal *)fetchCommit:(NSString *)commitSHA inRepository:(OCTRepository *)repository;

// Creates a commit.
//
// message    - The message of the new commit. This must not be nil.
// repository - The repository in which to create the commit. This must not be
//              nil.
// treeSHA    - The SHA of the tree for the new commit. This must not be nil.
// parentSHAs - An array of `NSString`s representing the SHAs of parent commits
//              for the new commit. This can be empty to create a root commit,
//              or have more than one object to create a merge commit. This
//              array must not be nil.
//
// Returns a signal which will send the created `OCTCommit` then complete, or
// error.
- (RACSignal *)createCommitWithMessage:(NSString *)message inRepository:(OCTRepository *)repository pointingToTreeWithSHA:(NSString *)treeSHA parentCommitSHAs:(NSArray *)parentSHAs;

// Fetches a git reference given its fully-qualified name.
//
// refName    - The fully-qualified name of the ref to fetch (e.g.,
//              `heads/master`). This must not be nil.
// repository - The repository in which to fetch the ref. This must not be nil.
//
// Returns a signal which will send an OCTRef then complete, or error.
- (RACSignal *)fetchReference:(NSString *)refName inRepository:(OCTRepository *)repository;

// Attempts to update a reference to point at a new SHA.
//
// refName    - The fully-qualified name of the ref to update (e.g.,
//              `heads/master`). This must not be nil.
// repository - The repository in which to update the ref. This must not be nil.
// newSHA     - The new SHA for the ref. This must not be nil.
// force      - Whether to force the ref to update, even if it cannot be
//              fast-forwarded.
//
// Returns a signal which will send the updated OCTRef then complete, or error.
- (RACSignal *)updateReference:(NSString *)refName inRepository:(OCTRepository *)repository toSHA:(NSString *)newSHA force:(BOOL)force;

@end
