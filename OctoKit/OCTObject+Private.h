//
//  OCTObject+Private.h
//  OctoKit
//
//  Created by Alan Rogers on 26/10/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

@interface OCTObject ()

// The URL of the API endpoint from which the receiver came. This should only be
// set at the time of initialization, and is responsible for filling in the
// `server` property.
@property (nonatomic, strong) NSURL *baseURL;

@end
