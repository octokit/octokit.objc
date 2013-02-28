//
//  OCTPublicKey.h
//  OctoKit
//
//  Created by Josh Abernathy on 12/31/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A public SSH key.
@interface OCTPublicKey : OCTObject

// The public key data itself.
@property (nonatomic, copy, readonly) NSString *publicKey;

// The name given to this key by the user.
@property (nonatomic, copy, readonly) NSString *title;

@end
