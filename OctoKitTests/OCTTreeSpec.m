//
//  OCTTreeSpec.m
//  OctoKit
//
//  Created by Josh Abernathy on 9/5/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTTree.h"
#import "OCTObjectSpec.h"
#import "OCTTreeEntry.h"

SpecBegin(OCTTree)

__block NSDictionary *representation;

beforeAll(^{
	NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"tree" withExtension:@"json"];
	expect(testDataURL).notTo.beNil();

	NSData *testContentData = [NSData dataWithContentsOfURL:testDataURL];
	expect(testContentData).notTo.beNil();

	representation = [NSJSONSerialization JSONObjectWithData:testContentData options:0 error:NULL];
	expect(representation).to.beKindOf(NSDictionary.class);
});

__block OCTTree *tree;

beforeEach(^{
	tree = [MTLJSONAdapter modelOfClass:OCTTree.class fromJSONDictionary:representation error:NULL];
	expect(tree).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: tree };
});

it(@"should initialize", ^{
	expect(tree.SHA).to.equal(@"HEAD");
	expect(tree.URL.absoluteString).to.equal(@"https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa/git/trees/HEAD");
	expect(tree.entries.count).to.equal(2);

	OCTTreeEntry *entry1 = tree.entries[0];
	expect(entry1.path).to.equal(@"CHANGELOG.md");
	expect(entry1.SHA).to.equal(@"bfcbe8a9b4efeee4ead492e9567f2d4c57acaeb7");
	expect(entry1.URL.absoluteString).to.equal(@"https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa/git/blobs/bfcbe8a9b4efeee4ead492e9567f2d4c57acaeb7");
	expect(entry1.type).to.equal(OCTTreeEntryTypeBlob);
	expect(entry1.mode).to.equal(OCTTreeEntryModeFile);

	OCTTreeEntry *entry2 = tree.entries[1];
	expect(entry2.path).to.equal(@"Documentation");
	expect(entry2.SHA).to.equal(@"5e40845071aa4b59612ef57d2602662de008725d");
	expect(entry2.URL.absoluteString).to.equal(@"https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa/git/trees/5e40845071aa4b59612ef57d2602662de008725d");
	expect(entry2.type).to.equal(OCTTreeEntryTypeTree);
	expect(entry2.mode).to.equal(OCTTreeEntryModeSubdirectory);
});

SpecEnd
