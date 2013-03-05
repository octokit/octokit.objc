//
//  OCTCommitCommentSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTCommitComment.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTCommitComment)

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
	@"updated_at": @"2011-04-14T16:00:49Z"
};

__block OCTCommitComment *comment;

before(^{
	comment = [MTLJSONAdapter modelOfClass:OCTCommitComment.class fromJSONDictionary:representation error:NULL];
	expect(comment).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: comment };
});

itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
	return @{ OCTObjectKey: comment, OCTObjectExternalRepresentationKey: representation };
});

it(@"should initialize", ^{
	expect(comment.objectID).to.equal(@"1");
	expect(comment.HTMLURL).to.equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/commit/6dcb09b5b57875f334f61aebed695e2e4193db5e#commitcomment-1"]);
	expect(comment.commitSHA).to.equal(@"6dcb09b5b57875f334f61aebed695e2e4193db5e");
});

SpecEnd
