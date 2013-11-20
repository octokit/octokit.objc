//
//  OCTServerMetadata.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-14.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTObject.h"

// Contains information about a GitHub server (Enterprise or .com).
@interface OCTServerMetadata : OCTObject

// Whether this server supports password authentication.
//
// If this is NO, you must invoke +[OCTClient signInToServerUsingWebBrowser:] to
// log in to this server.
@property (nonatomic, assign, readonly) BOOL supportsPasswordAuthentication;

@end
