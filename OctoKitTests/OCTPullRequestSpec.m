//
//  OCTPullRequestSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTPullRequestSpec)

NSDictionary *representation = @{
	@"url": @"https://api.github.com/octocat/Hello-World/pulls/1",
	@"html_url": @"https://github.com/octocat/Hello-World/pulls/1",
	@"diff_url": @"https://github.com/octocat/Hello-World/pulls/1.diff",
	@"patch_url": @"https://github.com/octocat/Hello-World/pulls/1.patch",
	@"issue_url": @"https://github.com/octocat/Hello-World/issue/1",
	@"number": @1,
	@"state": @"open",
	@"title": @"new-feature",
	@"body": @"Please pull these awesome changes",
	@"created_at": @"2011-01-26T19:01:12Z",
	@"updated_at": @"2011-01-26T19:02:12Z",
	@"closed_at": @"2011-01-26T19:03:12Z",
	@"merged_at": @"2011-01-26T19:04:12Z",
	@"head": @{
		@"label": @"new-topic",
		@"ref": @"new-topic",
		@"sha": @"6dcb09b5b57875f334f61aebed695e2e4193db5e",
		@"user": @{
			@"login": @"octocat",
			@"id": @1,
			@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
			@"gravatar_id": @"somehexcode",
			@"url": @"https://api.github.com/users/octocat"
		},
		@"repo": @{
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
				@"id": @1,
				@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
				@"gravatar_id": @"somehexcode",
				@"url": @"https://api.github.com/users/octocat"
			},
			@"name": @"Hello-World",
			@"full_name": @"octocat/Hello-World",
			@"description": @"This your first repo!",
			@"homepage": @"https://github.com",
			@"language": NSNull.null,
			@"private": @NO,
			@"fork": @NO,
			@"forks": @9,
			@"forks_count": @9,
			@"watchers": @80,
			@"watchers_count": @80,
			@"size": @108,
			@"master_branch": @"master",
			@"open_issues": @0,
			@"pushed_at": @"2011-01-26T19:06:43Z",
			@"created_at": @"2011-01-26T19:01:12Z",
			@"updated_at": @"2011-01-26T19:14:43Z"
		}
	},
	@"base": @{
		@"label": @"master",
		@"ref": @"master",
		@"sha": @"6dcb09b5b57875f334f61aebed695e2e4193db5e",
		@"user": @{
			@"login": @"octocat",
			@"id": @1,
			@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
			@"gravatar_id": @"somehexcode",
			@"url": @"https://api.github.com/users/octocat"
		},
		@"repo": @{
			@"url": @"https://api.github.com/repos/octocat/Hello-World",
			@"html_url": @"https://github.com/octocat/Hello-World",
			@"clone_url": @"https://github.com/octocat/Hello-World.git",
			@"git_url": @"git://github.com/octocat/Hello-World.git",
			@"ssh_url": @"git@github.com:octocat/Hello-World.git",
			@"svn_url": @"https://svn.github.com/octocat/Hello-World",
			@"mirror_url": @"git://git.example.com/octocat/Hello-World",
			@"id": @1296271,
			@"owner": @{
				@"login": @"octocat",
				@"id": @1,
				@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
				@"gravatar_id": @"somehexcode",
				@"url": @"https://api.github.com/users/octocat"
			},
			@"name": @"Hello-World",
			@"full_name": @"octocat/Hello-World",
			@"description": @"This your first repo!",
			@"homepage": @"https://github.com",
			@"language": NSNull.null,
			@"private": @NO,
			@"fork": @NO,
			@"forks": @9,
			@"forks_count": @9,
			@"watchers": @80,
			@"watchers_count": @80,
			@"size": @108,
			@"master_branch": @"master",
			@"open_issues": @0,
			@"pushed_at": @"2011-01-26T19:06:43Z",
			@"created_at": @"2011-01-26T19:01:12Z",
			@"updated_at": @"2011-01-26T19:14:43Z"
		}
	},
	@"_links": @{
		@"self": @{
			@"href": @"https://api.github.com/octocat/Hello-World/pulls/1"
		},
		@"html": @{
			@"href": @"https://github.com/octocat/Hello-World/pull/1"
		},
		@"comments": @{
			@"href": @"https://api.github.com/octocat/Hello-World/issues/1/comments"
		},
		@"review_comments": @{
			@"href": @"https://api.github.com/octocat/Hello-World/pulls/1/comments"
		}
	},
	@"user": @{
		@"login": @"octocat",
		@"id": @1,
		@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
		@"gravatar_id": @"somehexcode",
		@"url": @"https://api.github.com/users/octocat"
	}
};

__block OCTPullRequest *pullRequest;

beforeEach(^{
	pullRequest = [MTLJSONAdapter modelOfClass:OCTPullRequest.class fromJSONDictionary:representation error:NULL];
	expect(pullRequest).notTo(beNil());
});

itBehavesLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: pullRequest };
});

it(@"should initialize", ^{
	expect(pullRequest.objectID).to(equal(@"1"));
	expect(pullRequest.URL).to(equal([NSURL URLWithString:@"https://api.github.com/octocat/Hello-World/pulls/1"]));
	expect(pullRequest.HTMLURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/pulls/1"]));
	expect(pullRequest.diffURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/pulls/1.diff"]));
	expect(pullRequest.patchURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/pulls/1.patch"]));
	expect(pullRequest.issueURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/issue/1"]));
	expect(@(pullRequest.state)).to(equal(@(OCTPullRequestStateOpen)));
	expect(pullRequest.user.objectID).to(equal(@"1"));
	expect(pullRequest.user.login).to(equal(@"octocat"));
	expect(pullRequest.title).to(equal(@"new-feature"));
	expect(pullRequest.body).to(equal(@"Please pull these awesome changes"));
	expect(pullRequest.headRepository.objectID).to(equal(@"1296269"));
	expect(pullRequest.headBranch).to(equal(@"new-topic"));
	expect(pullRequest.baseRepository.objectID).to(equal(@"1296271"));
	expect(pullRequest.baseBranch).to(equal(@"master"));
	expect(pullRequest.creationDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-01-26T19:01:12Z"]));
	expect(pullRequest.updatedDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-01-26T19:02:12Z"]));
	expect(pullRequest.closedDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-01-26T19:03:12Z"]));
	expect(pullRequest.mergedDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-01-26T19:04:12Z"]));
});

QuickSpecEnd
