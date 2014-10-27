//
//  OCTGitCommitSpec.m
//  OctoKit
//
//  Created by Piet Brauer on 09.02.14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

QuickSpecBegin(OCTGitCommitSpec)

describe(@"github.com git commit", ^{
	describe(@"parsing a small commit", ^{
		__block NSDictionary *representation;

		beforeSuite(^{
			NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"git_commit" withExtension:@"json"];
			expect(testDataURL).notTo(beNil());

			NSData *testContentData = [NSData dataWithContentsOfURL:testDataURL];
			expect(testContentData).notTo(beNil());

			representation = [NSJSONSerialization JSONObjectWithData:testContentData options:0 error:NULL];
			expect(representation).to(beKindOf(NSDictionary.class));
		});

		__block OCTGitCommit *commit;

		beforeEach(^{
			commit = [MTLJSONAdapter modelOfClass:OCTGitCommit.class fromJSONDictionary:representation error:NULL];
			expect(commit).notTo(beNil());
		});

		it(@"should initialize from an external representation", ^{
			expect(commit.commitURL).to(equal([NSURL URLWithString:@"https://api.github.com/repos/octocat/Hello-World/commits/6dcb09b5b57875f334f61aebed695e2e4193db5e"]));
			expect(commit.message).to(equal(@"Fix all the bugs"));
			expect(commit.SHA).to(equal(@"6dcb09b5b57875f334f61aebed695e2e4193db5e"));
			expect(commit.committer.login).to(equal(@"octocat"));
			expect(commit.author.login).to(equal(@"octocat"));
			expect(commit.commitDate).to(equal([NSDate dateWithTimeIntervalSince1970:0]));
			expect(commit.countOfChanges).to(equal(0));
			expect(commit.countOfAdditions).to(equal(0));
			expect(commit.countOfDeletions).to(equal(0));
			expect(commit.files).to(beNil());
		});
	});

	describe(@"parsing a full commit", ^{
		__block NSDictionary *representation;

		beforeSuite(^{
			NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"git_commit_full" withExtension:@"json"];
			expect(testDataURL).notTo(beNil());

			NSData *testContentData = [NSData dataWithContentsOfURL:testDataURL];
			expect(testContentData).notTo(beNil());

			representation = [NSJSONSerialization JSONObjectWithData:testContentData options:0 error:NULL];
			expect(representation).to(beKindOf(NSDictionary.class));
		});

		__block OCTGitCommit *commit;

		beforeEach(^{
			commit = [MTLJSONAdapter modelOfClass:OCTGitCommit.class fromJSONDictionary:representation error:NULL];
			expect(commit).notTo(beNil());
		});

		it(@"should initialize from an external representation", ^{
			expect(commit.commitURL).to(equal([NSURL URLWithString:@"https://api.github.com/repos/octocat/Hello-World/commits/6dcb09b5b57875f334f61aebed695e2e4193db5e"]));
			expect(commit.message).to(equal(@"Fix all the bugs"));
			expect(commit.SHA).to(equal(@"6dcb09b5b57875f334f61aebed695e2e4193db5e"));
			expect(commit.committer.login).to(equal(@"octocat"));
			expect(commit.author.login).to(equal(@"octocat"));
			expect(commit.commitDate).to(equal([NSDate dateWithTimeIntervalSince1970:0]));
			expect(commit.countOfChanges).to(equal(108));
			expect(commit.countOfAdditions).to(equal(104));
			expect(commit.countOfDeletions).to(equal(4));
			expect(commit.files.count).to(equal(1));

			OCTGitCommitFile *file = commit.files[0];
			expect(file.class).to(equal(OCTGitCommitFile.class));
		});
	});
});

QuickSpecEnd
