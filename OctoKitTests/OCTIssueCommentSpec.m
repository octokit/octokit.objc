//
//  OCTIssueCommentSpec.m
//  OctoKit
//
//  Created by Jackson Harper on 2013-09-23.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <OctoKit/OctoKit.h>
@import Nimble;
@import Quick;

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTIssueCommentSpec)

NSDictionary *representation = @{
	@"id": @1,
	@"url": @"https://api.github.com/repos/octocat/Hello-World/issues/comments/1",
	@"html_url": @"https://github.com/octocat/Hello-World/issues/1347#issuecomment-1",
	@"body": @"Me too",
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
	@"updated_at": @"2011-04-14T18:00:49Z"
};

__block OCTIssueComment *comment;

beforeEach(^{
	comment = [MTLJSONAdapter modelOfClass:OCTIssueComment.class fromJSONDictionary:representation error:NULL];
	expect(comment).notTo(beNil());
});

itBehavesLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: comment };
});

it(@"should initialize", ^{
	expect(comment.objectID).to(equal(@"1"));
	expect(comment.body).to(equal(@"Me too"));
	expect(comment.creationDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-04-14T16:00:49Z"]));
	expect(comment.updatedDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-04-14T18:00:49Z"]));
	expect(comment.HTMLURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/issues/1347#issuecomment-1"]));
});

QuickSpecEnd
