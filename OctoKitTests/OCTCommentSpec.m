//
//  OCTCommentSpec.m
//  OctoKit
//
//  Created by Josh Vera on 8/30/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTComment.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTComment)

NSDictionary *representation = @{
	@"html_url": @"https://github.com/octocat/Hello-World/commit/6dcb09b5b57875f334f61aebed695e2e4193db5e#commitcomment-1",
	@"url": @"https://api.github.com/repos/octocat/Hello-World/comments/1",
	@"id": @1,
	@"body": @"Great stuff",
	@"body_html": @"<b>Great stuff</b>",
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
	@"updated_at": @"2011-04-14T16:00:49Z"
};

__block OCTComment *comment;

before(^{
	comment = [MTLJSONAdapter modelOfClass:OCTComment.class fromJSONDictionary:representation error:NULL];
	expect(comment).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: comment };
});

itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
	return @{ OCTObjectKey: comment, OCTObjectExternalRepresentationKey: representation };
});

it(@"should initialize", ^{
	expect(comment.objectID).to.equal([representation[@"id"] stringValue]);
	expect(comment.APIURL).to.equal([NSURL URLWithString:representation[@"url"]]);
	expect(comment.HTMLURL).to.equal([NSURL URLWithString:representation[@"html_url"]]);
	expect(comment.body).to.equal(representation[@"body"]);
	expect(comment.HTMLBody).to.equal(representation[@"body_html"]);

	expect(comment.commenterLogin).to.equal(representation[@"user"][@"login"]);

	NSDate *createdAt = [[[ISO8601DateFormatter alloc] init] dateFromString:representation[@"created_at"]];
	expect(comment.createdAtDate).to.equal(createdAt);

	NSDate *updatedAt = [[[ISO8601DateFormatter alloc] init] dateFromString:representation[@"updated_at"]];
	expect(comment.updatedAtDate).to.equal(updatedAt);
});

SpecEnd

