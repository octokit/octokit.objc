//
//  OCTMemberEvent.h
//  OctoKit
//
//  Created by Tyler Stromberg on 12/25/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "OCTEvent.h"

// The type of action performed.
//
// OCTMemberActionUnknown      - An unknown action occurred. Member events will
//                               never be initialized with this value -- they
//                               will simply fail to be created.
// OCTMemberActionAdded        - The user was added as a collaborator to the repository.

typedef NS_ENUM(NSInteger, OCTMemberAction) {
	OCTMemberActionUnknown = 0,
	OCTMemberActionAdded
};

// A user was added as a collaborator to a repository.
@interface OCTMemberEvent : OCTEvent

// The login of the user that was added to the repository.
@property (nonatomic, copy, readonly) NSString *memberLogin;

// The action that took place.
@property (nonatomic, assign, readonly) OCTMemberAction action;

@end
