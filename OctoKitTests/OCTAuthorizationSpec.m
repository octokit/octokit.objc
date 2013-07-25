//
//  OCTAuthorizationSpec.m
//  OctoKit
//
//  Created by Josh Abernathy on 7/25/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTAuthorization.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTAuthorization)

static NSString * const token = @"some-token";
NSDictionary *representation = @{
	@"id": @1,
	@"token": token,
};

__block OCTAuthorization *authorization;

beforeEach(^{
	authorization = [MTLJSONAdapter modelOfClass:OCTAuthorization.class fromJSONDictionary:representation error:NULL];
	expect(authorization).notTo.beNil();
});

it(@"should initialize from an external representation", ^{
	expect(authorization.objectID).to.equal(@"1");
	expect(authorization.token).to.equal(token);
});

it(@"shouldn't include the token in the serialized representation", ^{
	NSDictionary *representation = [MTLJSONAdapter JSONDictionaryFromModel:authorization];
	expect(representation[@"token"]).to.equal(NSNull.null);
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: authorization };
});

SpecEnd
