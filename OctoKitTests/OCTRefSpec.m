//
//  OCTRefSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-12-09.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTRef)

__block NSDictionary *representation;

beforeAll(^{
	NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"ref" withExtension:@"json"];
	expect(testDataURL).notTo.beNil();

	NSData *testContentData = [NSData dataWithContentsOfURL:testDataURL];
	expect(testContentData).notTo.beNil();

	representation = [NSJSONSerialization JSONObjectWithData:testContentData options:0 error:NULL];
	expect(representation).to.beKindOf(NSDictionary.class);
});

__block OCTRef *ref;

beforeEach(^{
	ref = [MTLJSONAdapter modelOfClass:OCTRef.class fromJSONDictionary:representation error:NULL];
	expect(ref).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: ref };
});

it(@"should initialize", ^{
	expect(ref.name).to.equal(@"refs/heads/sc/featureA");
	expect(ref.SHA).to.equal(@"aa218f56b14c9653891f9e74264a383fa43fefbd");
	expect(ref.objectURL.absoluteString).to.equal(@"https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd");
});

QuickSpecEnd
