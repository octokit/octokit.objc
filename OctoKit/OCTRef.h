//
//  OCTRef.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A git reference.
@interface OCTRef : OCTObject

// The fully qualified name of this reference.
@property (nonatomic, copy, readonly) NSString *name;

// The SHA of the git object that this ref points to.
@property (nonatomic, copy, readonly) NSString *SHA;

// The API URL to the git object that this ref points to.
@property (nonatomic, copy, readonly) NSURL *objectURL;

@end
