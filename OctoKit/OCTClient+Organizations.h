//
//  OCTClient+Organizations.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@class OCTOrganization;
@class OCTTeam;

@interface OCTClient (Organizations)

// Fetches the organizations that the current user is a member of.
//
// Returns a signal which sends zero or more OCTOrganization objects. Private
// organizations will only be included if the client is `authenticated`. If no
// `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserOrganizations;

// Fetches the specified organization's full information.
//
// Returns a signal which sends a new OCTOrganization.
- (RACSignal *)fetchOrganizationInfo:(OCTOrganization *)organization;

// Fetches the specified organization's teams.
//
// Returns a signal which sends zero or more OCTTeam objects. If the client is
// not `authenticated`, the signal will error immediately.
- (RACSignal *)fetchTeamsForOrganization:(OCTOrganization *)organization;

@end
