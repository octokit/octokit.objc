//
//  OCTCommitSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-12-09.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTCommitSpec)

__block NSDictionary *representation;

beforeSuite(^{
	NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"commit" withExtension:@"json"];
	expect(testDataURL).notTo(beNil());

	NSData *testContentData = [NSData dataWithContentsOfURL:testDataURL];
	expect(testContentData).notTo(beNil());

	representation = [NSJSONSerialization JSONObjectWithData:testContentData options:0 error:NULL];
	expect(representation).to(beKindOf(NSDictionary.class));
});

__block OCTCommit *commit;

beforeEach(^{
	commit = [MTLJSONAdapter modelOfClass:OCTCommit.class fromJSONDictionary:representation error:NULL];
	expect(commit).notTo(beNil());
});

itBehavesLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: commit };
});

it(@"should initialize", ^{
	expect(commit.SHA).to(equal(@"7638417db6d59f3c431d3e1f261cc637155684cd"));
	expect(commit.treeURL.absoluteString).to(equal(@"https://api.github.com/repos/octocat/Hello-World/git/trees/691272480426f78a0138979dd3ce63b77f706feb"));
	expect(commit.treeSHA).to(equal(@"691272480426f78a0138979dd3ce63b77f706feb"));
});

QuickSpecEnd
