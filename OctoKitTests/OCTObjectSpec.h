//
//  OCTObjectSpec.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

// The shared example group name for verifying that an object archives and
// unarchives successfully.
extern NSString * const OCTObjectArchivingSharedExamplesName;

// The shared example group name for verifying that an object's external
// representation matches the one it was initialized with.
extern NSString * const OCTObjectExternalRepresentationSharedExamplesName;

// The object to use for testing. The value for this key should not be nil.
extern NSString * const OCTObjectKey;

// The external representation with which the object was initialized.
extern NSString * const OCTObjectExternalRepresentationKey;
