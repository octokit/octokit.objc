//
//  OCTObject.h
//  OctoClient
//
//  Created by Josh Abernathy on 1/14/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCTServer;

// The base model class for any objects retrieved through the GitHub API.
@interface OCTObject : MTLModel

// The unique ID for this object. This is only guaranteed to be unique among
// objects of the same type, from the same server.
//
// By default, the external representation for this property assumes a numeric
// representation (which is the case for most API objects). Subclasses may
// override the `+objectIDTransformer` method to change this behavior.
@property (nonatomic, copy) NSString *objectID;

// The server this object is associated with
@property (nonatomic, strong, readonly) OCTServer *server;

// Behaves like -[MTLModel externalRepresentation], but any NSNull values are
// omitted.
- (NSDictionary *)externalRepresentation;

@end
