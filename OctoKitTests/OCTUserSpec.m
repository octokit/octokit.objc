//
//  OCTUserSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTUser.h"
#import "OCTObject+Private.h"
#import "OCTServer.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTUser)

describe(@"github.com user", ^{
	NSDictionary *representation = @{
		@"login": @"octocat",
		@"id": @1,
		@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
		@"gravatar_id": @"somehexcode",
		@"url": @"https://api.github.com/users/octocat",
		@"name": @"Mona Lisa Octocat",
		@"company": @"GitHub",
		@"blog": @"https://github.com/blog",
		@"location": @"San Francisco",
		@"email": @"octocat@github.com",
		@"hireable": @NO,
		@"bio": @"There once was...",
		@"public_repos": @2,
		@"public_gists": @1,
		@"followers": @20,
		@"following": @0,
		@"html_url": @"https://github.com/octocat",
		@"created_at": @"2008-01-14T04:33:35Z",
		@"type": @"User"
	};

	__block OCTUser *user;

	beforeEach(^{
		user = [MTLJSONAdapter modelOfClass:OCTUser.class fromJSONDictionary:representation];
		expect(user).notTo.beNil();
	});

	it(@"should initialize from an external representation", ^{
		expect(user.server).to.equal(OCTServer.dotComServer);
		expect(user.login).to.equal(@"octocat");
		expect(user.name).to.equal(@"Mona Lisa Octocat");
		expect(user.objectID).to.equal(@"1");
		expect(user.avatarURL).to.equal([NSURL URLWithString:@"https://github.com/images/error/octocat_happy.gif"]);
		expect(user.company).to.equal(@"GitHub");
		expect(user.blog).to.equal(@"https://github.com/blog");
		expect(user.email).to.equal(@"octocat@github.com");
		expect(user.publicRepoCount).to.equal(2);
	});

	itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
		return @{ OCTObjectKey: user };
	});

	itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
		return @{ OCTObjectKey: user, OCTObjectExternalRepresentationKey: representation };
	});

	it(@"should initialize with a name and email", ^{
		OCTUser *user = [OCTUser userWithName:@"foobar" email:@"foo@bar.com"];
		expect(user).notTo.beNil();

		expect(user.server).to.equal(OCTServer.dotComServer);
		expect(user.name).to.equal(@"foobar");
		expect(user.email).to.equal(@"foo@bar.com");
	});
	
	it(@"should initialize with a login and server", ^{
		OCTUser *user = [OCTUser userWithLogin:@"foo" server:OCTServer.dotComServer];
		expect(user).notTo.beNil();

		expect(user.server).to.equal(OCTServer.dotComServer);
		expect(user.login).to.equal(@"foo");
	});
});

describe(@"enterprise user", ^{
	NSDictionary *representation = @{
		@"type": @"User",
		@"public_repos": @0,
		@"public_gists": @0,
		@"html_url": @"http://10.168.1.109/jspahrsummers",
		@"gravatar_id": @"cac992bb300ed4f3ed5c2a6049e552f9",
		@"following": @0,
		@"avatar_url": @"https://secure.gravatar.com/avatar/cac992bb300ed4f3ed5c2a6049e552f9?d=http://10.168.1.109%2Fimages%2Fgravatars%2Fgravatar-user-420.png",
		@"url": @"https://10.168.1.109/api/v3/users/jspahrsummers",
		@"followers": @0,
		@"created_at": @"2012-10-09T03:06:59Z",
		@"login": @"jspahrsummers",
		@"id": @2
	};

	__block NSURL *baseURL;
	__block OCTUser *user;

	beforeEach(^{
		baseURL = [NSURL URLWithString:@"https://10.168.0.109"];

		user = [MTLJSONAdapter modelOfClass:OCTUser.class fromJSONDictionary:representation];
		expect(user).notTo.beNil();

		// This is usually set by OCTClient, but we'll do it ourselves here to simulate
		// what OCTClient does.
		user.baseURL = baseURL;
	});

	it(@"should initialize from an external representation", ^{
		OCTServer *enterpriseServer = [OCTServer serverWithBaseURL:baseURL];
		expect(user.server).to.equal(enterpriseServer);

		expect(user.login).to.equal(@"jspahrsummers");
		expect(user.objectID).to.equal(@"2");
		expect(user.avatarURL).to.equal([NSURL URLWithString:@"https://secure.gravatar.com/avatar/cac992bb300ed4f3ed5c2a6049e552f9?d=http://10.168.1.109%2Fimages%2Fgravatars%2Fgravatar-user-420.png"]);
		expect(user.publicRepoCount).to.equal(0);
	});

	itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
		return @{ OCTObjectKey: user };
	});

	itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
		// The "url" key isn't translated back for creating the external
		// representation, so remove it.
		NSDictionary *modifiedRepresentation = [representation mtl_dictionaryByRemovingEntriesWithKeys:[NSSet setWithObject:@"url"]];

		return @{ OCTObjectKey: user, OCTObjectExternalRepresentationKey: modifiedRepresentation };
	});
	
	it(@"should initialize with a login and server", ^{
		NSURL *baseURL = [NSURL URLWithString:@"https://10.168.1.109"];
		OCTServer *server = [OCTServer serverWithBaseURL:baseURL];
		OCTUser *user = [OCTUser userWithLogin:@"foo" server:server];
		expect(user).notTo.beNil();

		expect(user.server).to.equal(server);
		expect(user.login).to.equal(@"foo");
	});
});

SpecEnd
