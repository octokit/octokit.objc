//
//  OCTEvent.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-01.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A class cluster for GitHub events.
@interface OCTEvent : OCTObject

// The name of the repository upon which the event occurred (e.g., `github/Mac`).
@property (nonatomic, copy, readonly) NSString *repositoryName;

// The login of the user who instigated the event.
@property (nonatomic, copy, readonly) NSString *actorLogin;

// The organization related to the event.
@property (nonatomic, copy, readonly) NSString *organizationLogin;

// The date that this event occurred.
@property (nonatomic, copy, readonly) NSDate *date;

@end
