//
//  OCTIssueCommentSpec.m
//  OctoKit
//
//  Created by Josh Vera on 8/30/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTIssueComment.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTIssueComment)

NSDictionary *representation = @{
	@"url": @"https://api.github.com/repos/octocat/Hello-World/issues/comments/23572966",
	@"html_url": @"https://api.github.com/octocat/Hello-World/issues/1#issuecomment-23572966",
	@"issue_url": @"https://api.github.com/repos/octocat/Hello-World/issues/1",
	@"id": @1,
	@"user": @{
		@"login": @"gjtorikian",
		// Omitted because the JSON parsing does not preserve these keys.
		/*
		"id": 64050,
		"avatar_url": "https://2.gravatar.com/avatar/befd819b3fced8c6bd3dba7e633dd068?d=https%3A%2F%2Fidenticons.github.com%2F8c4cf2f289e384ce286d6b0c5174d4c2.png",
		"gravatar_id": "befd819b3fced8c6bd3dba7e633dd068",
		"url": "https://api.github.com/users/gjtorikian",
		"html_url": "https://github.com/gjtorikian",
		"followers_url": "https://api.github.com/users/gjtorikian/followers",
		"following_url": "https://api.github.com/users/gjtorikian/following{/other_user}",
		"gists_url": "https://api.github.com/users/gjtorikian/gists{/gist_id}",
		"starred_url": "https://api.github.com/users/gjtorikian/starred{/owner}{/repo}",
		"subscriptions_url": "https://api.github.com/users/gjtorikian/subscriptions",
		"organizations_url": "https://api.github.com/users/gjtorikian/orgs",
		"repos_url": "https://api.github.com/users/gjtorikian/repos",
		"events_url": "https://api.github.com/users/gjtorikian/events{/privacy}",
		"received_events_url": "https://api.github.com/users/gjtorikian/received_events",
		"type": "User"
		*/
	},
	@"created_at": @"2013-08-30T16:25:46Z",
	@"updated_at": @"2013-08-30T16:25:46Z",
	@"body_html": @"<p>bump-a-dump.</p>",
	@"body": @"bump-a-dump."
};

__block OCTIssueComment *comment;

before(^{
	comment = [MTLJSONAdapter modelOfClass:OCTIssueComment.class fromJSONDictionary:representation error:NULL];
	expect(comment).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: comment };
});

it(@"should initialize", ^{
	expect(comment.objectID).to.equal(@"1");
	expect(comment.HTMLURL).to.equal([NSURL URLWithString:@"https://api.github.com/octocat/Hello-World/issues/1#issuecomment-23572966"]);
	expect(comment.issueURL).to.equal([NSURL URLWithString:@"https://api.github.com/repos/octocat/Hello-World/issues/1"]);
});


SpecEnd
