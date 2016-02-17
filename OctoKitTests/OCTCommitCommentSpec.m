//
//  OCTCommitCommentSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <OctoKit/OctoKit.h>
@import Nimble;
@import Quick;

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTCommitCommentSpec)

NSDictionary *representation = @{
	@"html_url": @"https://github.com/octocat/Hello-World/commit/6dcb09b5b57875f334f61aebed695e2e4193db5e#commitcomment-1",
	@"url": @"https://api.github.com/repos/octocat/Hello-World/comments/1",
	@"id": @1,
	@"body": @"Great stuff",
	@"path": @"file1.txt",
	@"position": @4,
	@"line": @14,
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
	@"updated_at": @"2011-04-14T16:15:00Z"
};

__block OCTCommitComment *comment;

beforeEach(^{
	comment = [MTLJSONAdapter modelOfClass:OCTCommitComment.class fromJSONDictionary:representation error:NULL];
	expect(comment).notTo(beNil());
});

itBehavesLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: comment };
});

itBehavesLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
	return @{ OCTObjectKey: comment, OCTObjectExternalRepresentationKey: representation };
});

it(@"should initialize", ^{
	expect(comment.objectID).to(equal(@"1"));
	expect(comment.HTMLURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/commit/6dcb09b5b57875f334f61aebed695e2e4193db5e#commitcomment-1"]));
	expect(comment.commitSHA).to(equal(@"6dcb09b5b57875f334f61aebed695e2e4193db5e"));
	expect(comment.creationDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-04-14T16:00:49Z"]));
	expect(comment.updatedDate).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2011-04-14T16:15:00Z"]));
	expect(comment.body).to(equal(@"Great stuff"));
	expect(comment.path).to(equal(@"file1.txt"));
	expect(comment.position).to(equal(@(4)));
});

QuickSpecEnd
