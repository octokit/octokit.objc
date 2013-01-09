//
//  OCTPublicKey.h
//  OctoClient
//
//  Created by Josh Abernathy on 12/31/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTObject.h"

@interface OCTPublicKey : OCTObject

@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, copy) NSString *title;

@end
