//
//  OCTIssueSpec.m
//  OctoClient
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssue.h"
#import "OCTObjectSpec.h"
#import "OCTPullRequest.h"

SpecBegin(OCTIssue)

NSDictionary *representation = @{
	@"url": @"https://api.github.com/repos/octocat/Hello-World/issues/1",
	@"html_url": @"https://github.com/octocat/Hello-World/issues/1",
	@"number": @1347,
	@"state": @"open",
	@"title": @"Found a bug",
	@"body": @"I'm having a problem with this.",
	@"user": @{
		@"login": @"octocat",
		@"id": @1,
		@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
		@"gravatar_id": @"somehexcode",
		@"url": @"https://api.github.com/users/octocat"
	},
	@"labels": @[
		@{
			@"url": @"https://api.github.com/repos/octocat/Hello-World/labels/bug",
			@"name": @"bug",
			@"color": @"f29513"
		}
	],
	@"assignee": @{
		@"login": @"octocat",
		@"id": @1,
		@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
		@"gravatar_id": @"somehexcode",
		@"url": @"https://api.github.com/users/octocat"
	},
	@"milestone": @{
		@"url": @"https://api.github.com/repos/octocat/Hello-World/milestones/1",
		@"number": @1,
		@"state": @"open",
		@"title": @"v1.0",
		@"description": @"",
		@"creator": @{
			@"login": @"octocat",
			@"id": @1,
			@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
			@"gravatar_id": @"somehexcode",
			@"url": @"https://api.github.com/users/octocat"
		},
		@"open_issues": @4,
		@"closed_issues": @8,
		@"created_at": @"2011-04-10T20:09:31Z",
		@"due_on": NSNull.null
	},
	@"comments": @0,
	@"pull_request": @{
		@"html_url": @"https://github.com/octocat/Hello-World/issues/1",
		@"diff_url": @"https://github.com/octocat/Hello-World/issues/1.diff",
		@"patch_url": @"https://github.com/octocat/Hello-World/issues/1.patch"
	},
	@"closed_at": NSNull.null,
	@"created_at": @"2011-04-22T13:33:48Z",
	@"updated_at": @"2011-04-22T13:33:48Z"
};

__block OCTIssue *issue;

before(^{
	issue = [[OCTIssue alloc] initWithExternalRepresentation:representation];
	expect(issue).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: issue };
});

it(@"should initialize", ^{
	expect(issue.objectID).to.equal(@"1347");
	expect(issue.HTMLURL).to.equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/issues/1"]);
	expect(issue.title).to.equal(@"Found a bug");

	expect(issue.pullRequest).to.beKindOf(OCTPullRequest.class);
	expect(issue.pullRequest.objectID).to.equal(issue.objectID);
	expect(issue.pullRequest.title).to.equal(issue.title);
	expect(issue.pullRequest.HTMLURL).to.equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/issues/1"]);
});

SpecEnd
