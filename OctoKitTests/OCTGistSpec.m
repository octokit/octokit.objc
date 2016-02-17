//
//  OCTGistSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-08-14.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <OctoKit/OctoKit.h>
@import Nimble;
@import Quick;

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTGistSpec)

describe(@"from JSON", ^{
	NSDictionary *representation = @{
		@"url": @"https://api.github.com/gists/23fe77b213f016ba8163",
		@"id": @"1",
		@"description": @"description of gist",
		@"public": @YES,
		@"user": @{
			@"login": @"octocat",
			@"id": @1,
			@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
			@"gravatar_id": @"somehexcode",
			@"url": @"https://api.github.com/users/octocat"
		},
		@"files": @{
			@"ring.erl": @{
				@"size": @932,
				@"filename": @"ring.erl",
				@"raw_url": @"https://gist.github.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl"
			}
		},
		@"comments": @0,
		@"comments_url": @"https://api.github.com/gists/71bca83c625d7bbd1ac5/comments/",
		@"html_url": @"https://gist.github.com/1",
		@"git_pull_url": @"git://gist.github.com/1.git",
		@"git_push_url": @"git@gist.github.com:1.git",
		@"created_at": @"2010-04-14T02:15:15Z",
		@"forks": @[
			@{
				@"user": @{
					@"login": @"octocat",
					@"id": @1,
					@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
					@"gravatar_id": @"somehexcode",
					@"url": @"https://api.github.com/users/octocat"
				},
				@"url": @"https://api.github.com/gists/ac16d17127f44732e77b",
				@"created_at": @"2011-04-14T16:00:49Z"
			}
		],
		@"history": @[
			@{
				@"url": @"https://api.github.com/gists/b5b5732025ffd72da0d2",
				@"version": @"57a7f021a713b1c5a6a199b54cc514735d2d462f",
				@"user": @{
					@"login": @"octocat",
					@"id": @1,
					@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
					@"gravatar_id": @"somehexcode",
					@"url": @"https://api.github.com/users/octocat"
				},
				@"change_status": @{
					@"deletions": @0,
					@"additions": @180,
					@"total": @180
				},
				@"committed_at": @"2010-04-14T02:15:15Z"
			}
		]
	};

	__block OCTGist *gist;

	beforeEach(^{
		gist = [MTLJSONAdapter modelOfClass:OCTGist.class fromJSONDictionary:representation error:NULL];
		expect(gist).notTo(beNil());
	});

	itBehavesLike(OCTObjectArchivingSharedExamplesName, ^{
		return @{ OCTObjectKey: gist };
	});

	itBehavesLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
		// Our shared example doesn't know how to handle recursive external
		// representations, so don't test it.
		NSMutableDictionary *flattenedRepresentation = [representation mutableCopy];
		[flattenedRepresentation removeObjectForKey:@"files"];

		return @{ OCTObjectKey: gist, OCTObjectExternalRepresentationKey: flattenedRepresentation };
	});

	it(@"should initialize", ^{
		expect(gist.objectID).to(equal(@"1"));
		expect(gist.creationDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2010-04-14 02:15:15 +0000"]));
		expect(gist.HTMLURL).to(equal([NSURL URLWithString:@"https://gist.github.com/1"]));
		expect(@(gist.files.count)).to(equal(@1));

		OCTGistFile *file = gist.files[@"ring.erl"];
		expect(file).notTo(beNil());
		expect(file.filename).to(equal(@"ring.erl"));
		expect(file.rawURL).to(equal([NSURL URLWithString:@"https://gist.github.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl"]));
		expect(@(file.size)).to(equal(@932));
	});
});

QuickSpecEnd
