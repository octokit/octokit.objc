//
//  OCTUserSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObject+Private.h"
#import "OCTObjectSpec.h"

QuickSpecBegin(OCTUserSpec)

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
		user = [MTLJSONAdapter modelOfClass:OCTUser.class fromJSONDictionary:representation error:NULL];
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
		OCTUser *user = [OCTUser userWithRawLogin:@"foo" server:OCTServer.dotComServer];
		expect(user).notTo.beNil();

		expect(user.server).to.equal(OCTServer.dotComServer);
		expect(user.rawLogin).to.equal(@"foo");
	});

	it(@"should allow differing rawLogin and login properties", ^{
		OCTUser *newUser = [OCTUser userWithRawLogin:@"octocat@github.com" server:OCTServer.dotComServer];
		expect(newUser).notTo.beNil();

		expect(newUser.server).to.equal(OCTServer.dotComServer);
		expect(newUser.rawLogin).to.equal(@"octocat@github.com");

		[newUser mergeValuesForKeysFromModel:user];

		expect(newUser.login).to.equal(@"octocat");
		expect(newUser.rawLogin).to.equal(@"octocat@github.com");
	});

	it(@"should only merge rawLogin if the current value is nil", ^{
		OCTUser *newUser = [OCTUser modelWithDictionary:@{
				@keypath(OCTUser.new, login): @"octocat",
				@keypath(OCTUser.new, server): OCTServer.dotComServer,
			 } error:NULL];
		expect(newUser).notTo.beNil();

		expect(newUser.server).to.equal(OCTServer.dotComServer);
		expect(newUser.login).to.equal(@"octocat");
		expect(newUser.rawLogin).to.beNil();

		OCTUser *rawUser = [OCTUser userWithRawLogin:@"octocat@github.com" server:OCTServer.dotComServer];

		[newUser mergeValuesForKeysFromModel:rawUser];

		expect(newUser.rawLogin).to.equal(@"octocat@github.com");
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

		user = [MTLJSONAdapter modelOfClass:OCTUser.class fromJSONDictionary:representation error:NULL];
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
		OCTUser *user = [OCTUser userWithRawLogin:@"foo" server:server];
		expect(user).notTo.beNil();

		expect(user.server).to.equal(server);
		expect(user.rawLogin).to.equal(@"foo");
	});
});

describe(@"equality", ^{
	it(@"should treat users with the same server and login as equals", ^{
		OCTUser *user1 = [OCTUser userWithRawLogin:@"joshaber" server:OCTServer.dotComServer];
		OCTUser *user2 = [OCTUser userWithRawLogin:@"joshaber" server:OCTServer.dotComServer];
		expect([user1 isEqual:user2]).to.beTruthy();
		expect(user1.hash).to.equal(user2.hash);
	});

	it(@"shouldn't treat users with different servers or logins as equals", ^{
		OCTUser *user1 = [OCTUser userWithRawLogin:@"joshaber1" server:OCTServer.dotComServer];
		OCTUser *user2 = [OCTUser userWithRawLogin:@"joshaber" server:OCTServer.dotComServer];
		expect([user1 isEqual:user2]).to.beFalsy();

		OCTUser *user3 = [OCTUser userWithRawLogin:@"joshaber" server:[OCTServer serverWithBaseURL:[NSURL URLWithString:@"https://google.com"]]];
		expect([user2 isEqual:user3]).to.beFalsy();
	});

	it(@"should prefer objectID equivalence", ^{
		OCTUser *user1 = [[OCTUser alloc] initWithDictionary:@{
			@keypath(OCTUser.new, login): @"joshaber",
			@keypath(OCTUser.new, objectID): @"43",
			@keypath(OCTUser.new, server): OCTServer.dotComServer,
		} error:NULL];
		OCTUser *user2 = [[OCTUser alloc] initWithDictionary:@{
			@keypath(OCTUser.new, login): @"joshaber1",
			@keypath(OCTUser.new, objectID): @"43",
			@keypath(OCTUser.new, server): OCTServer.dotComServer,
		} error:NULL];
		expect(user1).notTo.beNil();
		expect(user2).notTo.beNil();
		expect(user1).to.equal(user2);
	});

	it(@"should prefer rawLogin equivalence over login equivalence", ^{
		OCTUser *user1 = [[OCTUser alloc] initWithDictionary:@{
			@keypath(OCTUser.new, rawLogin): @"josh.aber",
			@keypath(OCTUser.new, login): @"josh-aber",
			@keypath(OCTUser.new, server): OCTServer.dotComServer,
		} error:NULL];
		OCTUser *user2 = [[OCTUser alloc] initWithDictionary:@{
			@keypath(OCTUser.new, rawLogin): @"josh_aber",
			@keypath(OCTUser.new, login): @"josh-aber",
			@keypath(OCTUser.new, server): OCTServer.dotComServer,
		} error:NULL];
		expect(user1).notTo.beNil();
		expect(user2).notTo.beNil();
		expect(user1).notTo.equal(user2);
	});

	it(@"should never treat a user with an ID as equivalent to a user without", ^{
		OCTUser *user1 = [OCTUser userWithRawLogin:@"joshaber" server:OCTServer.dotComServer];
		OCTUser *user2 = [OCTUser modelWithDictionary:@{
			@keypath(OCTUser.new, login): @"joshaber",
			@keypath(OCTUser.new, objectID): @"42",
			@keypath(OCTUser.new, server): OCTServer.dotComServer,
		} error:NULL];
		expect(user1).notTo.equal(user2);
	});
});

QuickSpecEnd
