//
//  OCTRefEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"

// Represents the type of a git reference.
//
// OCTRefTypeUnknown    - An unknown type of reference. Ref events will never
//                        be initialized with this value -- they will simply
//                        fail to be created.
// OCTRefTypeBranch     - A branch in a repository.
// OCTRefTypeTag        - A tag in a repository.
// OCTRefTypeRepository - A repository.
typedef enum : NSUInteger {
    OCTRefTypeUnknown = 0,
    OCTRefTypeBranch,
    OCTRefTypeTag,
    OCTRefTypeRepository
} OCTRefType;

// The type of event that occurred around a reference.
//
// OCTRefEventUnknown - An unknown event occurred. Ref events will never be
//                      initialized with this value -- they will simply
//                      fail to be created.
// OCTRefEventCreated - The reference was created on the server.
// OCTRefEventDeleted - The reference was deleted on the server.
typedef enum : NSUInteger {
    OCTRefEventUnknown = 0,
    OCTRefEventCreated,
    OCTRefEventDeleted
} OCTRefEventType;

// A git reference (branch or tag) was created or deleted.
@interface OCTRefEvent : OCTEvent

// The kind of reference that was created or deleted.
@property (nonatomic, assign, readonly) OCTRefType refType;

// The type of event that occurred with the reference.
@property (nonatomic, assign, readonly) OCTRefEventType eventType;

// The short name of this reference (e.g., "master").
@property (nonatomic, copy, readonly) NSString *refName;

@end
