//
//  OCTCommitSpec.m
//  OctoKit
//
//  Created by Jackson Harper on 2013-12-09.
//  Copyright (c) 2013 SyntaxTree, Inc. All rights reserved.
//

#import "OCTCommit.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTCommit)

NSDictionary *representation = @{
	@"sha": @"144224ad915165e4d49e5085ae44eb4a1dee002b",
	@"commit": @{
		@"author": @{
			@"name": @"Jackson Harper",
			@"email": @"jacksonh@gmail.com",
			@"date": @"2013-12-06T16:20:08Z"
		},
		@"committer": @{
			@"name": @"Jackson Harper",
			@"email": @"jacksonh@gmail.com",
			@"date": @"2013-12-06T16:26:15Z"
		},
		@"message": @"Specify memory-management semantics",
		@"tree": @{
			@"sha": @"5a3508e0c61e868e82c276a68b224dfd2e3e2937",
			@"url": @"https://api.github.com/repos/octokit/octokit.objc/git/trees/5a3508e0c61e868e82c276a68b224dfd2e3e2937"
		},
		@"url": @"https://api.github.com/repos/octokit/octokit.objc/git/commits/144224ad915165e4d49e5085ae44eb4a1dee002b",
		@"comment_count": @(0)
	},
	@"url": @"https://api.github.com/repos/octokit/octokit.objc/commits/144224ad915165e4d49e5085ae44eb4a1dee002b",
	@"html_url": @"https://github.com/octokit/octokit.objc/commit/144224ad915165e4d49e5085ae44eb4a1dee002b",
	@"comments_url": @"https://api.github.com/repos/octokit/octokit.objc/commits/144224ad915165e4d49e5085ae44eb4a1dee002b/comments",
	@"author": @{
		@"login": @"jacksonh",
		@"id": @(75189),
		@"avatar_url": @"https://2.gravatar.com/avatar/e0cbf5c545fcef2fe5d3abec89908ed7?d=https%3A%2F%2Fidenticons.github.com%2F6d926a75cf9136107752fbe5251cdaf6.png&r=x",
		@"gravatar_id": @"e0cbf5c545fcef2fe5d3abec89908ed7",
		@"url": @"https://api.github.com/users/jacksonh",
		@"html_url": @"https://github.com/jacksonh",
		@"followers_url": @"https://api.github.com/users/jacksonh/followers",
		@"following_url": @"https://api.github.com/users/jacksonh/following{/other_user}",
		@"gists_url": @"https://api.github.com/users/jacksonh/gists{/gist_id}",
		@"starred_url": @"https://api.github.com/users/jacksonh/starred{/owner}{/repo}",
		@"subscriptions_url": @"https://api.github.com/users/jacksonh/subscriptions",
		@"organizations_url": @"https://api.github.com/users/jacksonh/orgs",
		@"repos_url": @"https://api.github.com/users/jacksonh/repos",
		@"events_url": @"https://api.github.com/users/jacksonh/events{/privacy}",
		@"received_events_url": @"https://api.github.com/users/jacksonh/received_events",
		@"type": @"User",
		@"site_admin": @"false"
	},
	@"committer": @{
		@"login": @"jacksonh",
		@"id": @(75191),
		@"avatar_url": @"https://2.gravatar.com/avatar/e0cbf5c545fcef2fe5d3abec89908ed7?d=https%3A%2F%2Fidenticons.github.com%2F6d926a75cf9136107752fbe5251cdaf6.png&r=x",
		@"gravatar_id": @"e0cbf5c545fcef2fe5d3abec89908ed7",
		@"url": @"https://api.github.com/users/jacksonh",
		@"html_url": @"https://github.com/jacksonh",
		@"followers_url": @"https://api.github.com/users/jacksonh/followers",
		@"following_url": @"https://api.github.com/users/jacksonh/following{/other_user}",
		@"gists_url": @"https://api.github.com/users/jacksonh/gists{/gist_id}",
		@"starred_url": @"https://api.github.com/users/jacksonh/starred{/owner}{/repo}",
		@"subscriptions_url": @"https://api.github.com/users/jacksonh/subscriptions",
		@"organizations_url": @"https://api.github.com/users/jacksonh/orgs",
		@"repos_url": @"https://api.github.com/users/jacksonh/repos",
		@"events_url": @"https://api.github.com/users/jacksonh/events{/privacy}",
		@"received_events_url": @"https://api.github.com/users/jacksonh/received_events",
		@"type": @"User",
		@"site_admin": @"false"
	},
	@"parents": @[
		@{
			@"sha": @"70d82aa6f6caae9585e664143100ae98c3146c78",
			@"url": @"https://api.github.com/repos/octokit/octokit.objc/commits/70d82aa6f6caae9585e664143100ae98c3146c78",
			@"html_url": @"https://github.com/octokit/octokit.objc/commit/70d82aa6f6caae9585e664143100ae98c3146c78"
		}
	]
};

__block OCTCommit *commit;

before(^{
	commit = [MTLJSONAdapter modelOfClass:OCTCommit.class fromJSONDictionary:representation error:NULL];
	expect(commit).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: commit };
});

it(@"should initialize", ^{
	expect(commit.SHA).to.equal(@"144224ad915165e4d49e5085ae44eb4a1dee002b");
	expect(commit.URL).to.equal([NSURL URLWithString:@"https://api.github.com/repos/octokit/octokit.objc/commits/144224ad915165e4d49e5085ae44eb4a1dee002b"]);
	expect(commit.HTMLURL).to.equal([NSURL URLWithString:@"https://github.com/octokit/octokit.objc/commit/144224ad915165e4d49e5085ae44eb4a1dee002b"]);
	expect(commit.commentsURL).to.equal([NSURL URLWithString:@"https://api.github.com/repos/octokit/octokit.objc/commits/144224ad915165e4d49e5085ae44eb4a1dee002b/comments"]);
	expect(commit.authorDate).to.equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2013-12-06T16:20:08Z"]);
	expect(commit.commitDate).to.equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2013-12-06T16:26:15Z"]);
	expect(commit.author.objectID).to.equal(@"75189");
	expect(commit.committer.objectID).to.equal(@"75191");
	expect(commit.message).to.equal(@"Specify memory-management semantics");
	
});

SpecEnd
