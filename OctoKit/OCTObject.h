//
//  OCTObject.h
//  OctoKit
//
//  Created by Josh Abernathy on 1/14/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>

@class OCTServer;

// The base model class for any objects retrieved through the GitHub API.
@interface OCTObject : MTLModel <MTLJSONSerializing>

// The unique ID for this object. This is only guaranteed to be unique among
// objects of the same type, from the same server.
//
// By default, the JSON representation for this property assumes a numeric
// representation (which is the case for most API objects). Subclasses may
// override the `+objectIDJSONTransformer` method to change this behavior.
@property (nonatomic, copy, readonly) NSString *objectID;

// The server this object is associated with.
//
// This object is not encoded into JSON.
@property (nonatomic, strong, readonly) OCTServer *server;

@end
