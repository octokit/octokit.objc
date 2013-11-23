//
//  OCTClient+Organizations.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient+Organizations.h"
#import "OCTClient+Private.h"
#import "OCTOrganization.h"
#import "OCTTeam.h"
#import "RACSignal+OCTClientAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation OCTClient (Organizations)

- (RACSignal *)fetchUserOrganizations {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/orgs" parameters:nil resultClass:OCTOrganization.class] oct_parsedResults];
}

- (RACSignal *)fetchOrganizationInfo:(OCTOrganization *)organization {
	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@", organization.login] parameters:nil notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTOrganization.class] oct_parsedResults];
}

- (RACSignal *)fetchTeamsForOrganization:(OCTOrganization *)organization {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@/teams", organization.login] parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTTeam.class] oct_parsedResults];
}

@end
