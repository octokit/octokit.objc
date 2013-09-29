//
//  OCTPullRequestCommentSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTPullRequestComment.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTPullRequestComment)

NSDictionary *representation = @{
	@"url": @"https://api.github.com/repos/octocat/Hello-World/pulls/comments/1",
	@"id": @1,
	@"body": @"Great stuff",
	@"diff_hunk": @"@@ -0,0 +1,26 @@\n+//\n+//  OCTComment.h\n+//  OctoKit\n+//\n+//...",
	@"path": @"file1.txt",
	@"position": @4,
	@"commit_id": @"6dcb09b5b57875f334f61aebed695e2e4193db5e",
	@"user": @{
		@"login": @"octocat",

		// Omitted because the JSON parsing does not preserve these keys.
		/*
		@"id": @1,
		@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
		@"gravatar_id": @"somehexcode",
		@"url": @"https://api.github.com/users/octocat"
		*/
	},
	@"created_at": @"2011-04-14T16:00:49Z",
	@"updated_at": @"2011-04-14T16:15:00Z",
	@"html_url": @"https://github.com/octocat/Hello-World/pull/1#discussion-diff-1",
	@"_links": @{
		@"self": @{
			@"href": @"https://api.github.com/octocat/Hello-World/pulls/comments/1"
		},
		@"html": @{
			@"href": @"https://github.com/octocat/Hello-World/pull/1#discussion-diff-1"
		},
		@"pull_request": @{
			@"href": @"https://api.github.com/octocat/Hello-World/pulls/1"
		}
	}
};

__block OCTPullRequestComment *comment;

before(^{
	comment = [MTLJSONAdapter modelOfClass:OCTPullRequestComment.class fromJSONDictionary:representation error:NULL];
	expect(comment).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: comment };
});

it(@"should initialize", ^{
	expect(comment.objectID).to.equal(@"1");
	expect(comment.body).to.equal(@"Great stuff");
	expect(comment.diffHunk).to.equal(@"@@ -0,0 +1,26 @@\n+//\n+//  OCTComment.h\n+//  OctoKit\n+//\n+//...");
	expect(comment.creationDate).to.equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-04-14T16:00:49Z"]);
	expect(comment.updatedDate).to.equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-04-14T16:15:00Z"]);
	expect(comment.HTMLURL).to.equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/pull/1#discussion-diff-1"]);
	expect(comment.pullRequestAPIURL).to.equal([NSURL URLWithString:@"https://api.github.com/octocat/Hello-World/pulls/1"]);
	expect(comment.position).to.equal(@4);
	expect(comment.path).to.equal(@"file1.txt");
	expect(comment.body).to.equal(@"Great stuff");
	expect(comment.commitSHA).to.equal(@"6dcb09b5b57875f334f61aebed695e2e4193db5e");
});

SpecEnd
