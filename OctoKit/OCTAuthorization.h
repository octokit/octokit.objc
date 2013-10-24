//
//  OCTAuthorization.h
//  OctoKit
//
//  Created by Josh Abernathy on 7/25/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// An OAuth token returned from the /authorizations API.
@interface OCTAuthorization : OCTObject

// The authorization token. You should treat this as you would the user's
// password.
//
// This property will not be serialized to JSON. If you need to persist it, save
// it to the Keychain.
@property (nonatomic, readonly, copy) NSString *token;

@end
