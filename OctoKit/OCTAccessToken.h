//
//  OCTAccessToken.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-24.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// An OAuth access token returned from the web flow.
@interface OCTAccessToken : OCTObject

// The access token itself. You should treat this as you would the user's
// password.
//
// This property will not be serialized to JSON. If you need to persist it, save
// it to the Keychain.
@property (nonatomic, readonly, copy) NSString *token;

@end
