//
//  OCTRepositorySpec.m
//  GitHub
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTRepository.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTRepository)

describe(@"from JSON", ^{
	NSDictionary *representation = @{
		@"url": @"https://api.github.com/repos/octocat/Hello-World",
		@"html_url": @"https://github.com/octocat/Hello-World",
		@"clone_url": @"https://github.com/octocat/Hello-World.git",
		@"git_url": @"git://github.com/octocat/Hello-World.git",
		@"ssh_url": @"git@github.com:octocat/Hello-World.git",
		@"svn_url": @"https://svn.github.com/octocat/Hello-World",
		@"mirror_url": @"git://git.example.com/octocat/Hello-World",
		@"id": @1296269,
		@"owner": @{
			@"login": @"octocat",

			// Omitted because the JSON parsing does not preserve these keys.
			/*
			@"id": @1,
			@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
			@"gravatar_id": @"somehexcode",
			@"url": @"https://api.github.com/users/octocat"
			*/
		},

		@"name": @"Hello-World",
		@"full_name": @"octocat/Hello-World",
		@"description": @"This your first repo!",
		@"homepage": @"https://github.com",
		@"language": NSNull.null,
		@"private": @NO,
		@"fork": @NO,
		@"forks": @9,
		@"watchers": @80,
		@"size": @108,
		@"master_branch": @"master",
		@"open_issues": @0,
		@"pushed_at": @"2011-01-26T19:06:43Z",
		@"created_at": @"2011-01-26T19:01:12Z",
		@"updated_at": @"2011-01-26T19:14:43Z",
		@"default_branch": @"master",
	};

	__block OCTRepository *repository;

	before(^{
		repository = [MTLJSONAdapter modelOfClass:OCTRepository.class fromJSONDictionary:representation error:NULL];
		expect(repository).notTo.beNil();
	});

	itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
		return @{ OCTObjectKey: repository };
	});

	itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
		return @{ OCTObjectKey: repository, OCTObjectExternalRepresentationKey: representation };
	});

	it(@"should initialize", ^{
		expect(repository.objectID).to.equal(@"1296269");
		expect(repository.name).to.equal(@"Hello-World");
		expect(repository.repoDescription).to.equal(@"This your first repo!");
		expect(repository.private).to.beFalsy();
		expect(repository.fork).to.beFalsy();
		expect(repository.ownerLogin).to.equal(@"octocat");
		expect(repository.datePushed).to.equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-01-26 19:06:43 +0000"]);
		expect(repository.HTTPSURL).to.equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World.git"]);
		expect(repository.HTMLURL).to.equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World"]);
		expect(repository.SSHURL).to.equal(@"git@github.com:octocat/Hello-World.git");
		expect(repository.defaultBranch).to.equal(@"master");
	});
});

it(@"should migrate from pre-MTLModel OCTObject", ^{
	NSDictionary *representation = @{
		@"OCTObjectModelVersionKey": @2,
		@"description": @"Formerly help.github.com/api. A list of projects using the API",
		@"fork": @0,
		@"forks": @0,
		@"has_downloads": @1,
		@"has_issues": @1,
		@"has_wiki": @1,
		@"homepage": @"poweredby.github.com",
		@"id": @1234,
		@"isPushable": @0,
		@"isTracking": @0,
		@"name": @"poweredby.github.com",
		@"open_issues": @0,
		@"owner": @"github",
		@"private": @1,
		@"url": [NSURL URLWithString:@"https://github.com/github/poweredby.github.com"],
		@"watchers": @1
	};

	NSDictionary *dictionaryValue = [OCTRepository dictionaryValueFromArchivedExternalRepresentation:representation version:0];
	expect(dictionaryValue).notTo.beNil();

	OCTRepository *repository = [OCTRepository modelWithDictionary:dictionaryValue error:NULL];
	expect(repository).notTo.beNil();

	// Test a key that actually changed format.
	expect(repository.ownerLogin).to.equal(@"github");
});

SpecEnd
