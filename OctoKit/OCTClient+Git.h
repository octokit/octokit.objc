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

// Fetches the blob identified by the given SHA.
//
// blobSHA    - The SHA of the blob to fetch. This must not be nil.
// repository - The repository from which the blob should be fetched. Cannot be
//              nil.
//
// Returns a signal which will send an NSData then complete, or error.
- (RACSignal *)fetchBlob:(NSString *)blobSHA inRepository:(OCTRepository *)repository;

@end
