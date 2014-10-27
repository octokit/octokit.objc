//
//  OCTTreeSpec.m
//  OctoKit
//
//  Created by Josh Abernathy on 9/5/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTTreeSpec)

__block NSDictionary *representation;

beforeSuite(^{
	NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"tree" withExtension:@"json"];
	expect(testDataURL).notTo(beNil());

	NSData *testContentData = [NSData dataWithContentsOfURL:testDataURL];
	expect(testContentData).notTo(beNil());

	representation = [NSJSONSerialization JSONObjectWithData:testContentData options:0 error:NULL];
	expect(representation).to(beAnInstanceOf(NSDictionary.class));
});

__block OCTTree *tree;

beforeEach(^{
	tree = [MTLJSONAdapter modelOfClass:OCTTree.class fromJSONDictionary:representation error:NULL];
	expect(tree).notTo(beNil());
});

itBehavesLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: tree };
});

it(@"should initialize", ^{
	expect(tree.SHA).to(equal(@"HEAD"));
	expect(tree.URL.absoluteString).to(equal(@"https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa/git/trees/HEAD"));
	expect(@(tree.entries.count)).to(equal(@4));

	OCTBlobTreeEntry *entry1 = tree.entries[0];
	expect(entry1).to(beAnInstanceOf(OCTBlobTreeEntry.class));
	expect(entry1.path).to(equal(@"CHANGELOG.md"));
	expect(entry1.SHA).to(equal(@"bfcbe8a9b4efeee4ead492e9567f2d4c57acaeb7"));
	expect(entry1.URL.absoluteString).to(equal(@"https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa/git/blobs/bfcbe8a9b4efeee4ead492e9567f2d4c57acaeb7"));
	expect(@(entry1.type)).to(equal(@(OCTTreeEntryTypeBlob)));
	expect(@(entry1.mode)).to(equal(@(OCTTreeEntryModeFile)));
	expect(@(entry1.size)).to(equal(@17609));

	OCTContentTreeEntry *entry2 = tree.entries[1];
	expect(entry2).to(beAnInstanceOf(OCTContentTreeEntry.class));
	expect(entry2.path).to(equal(@"Documentation"));
	expect(entry2.SHA).to(equal(@"5e40845071aa4b59612ef57d2602662de008725d"));
	expect(entry2.URL.absoluteString).to(equal(@"https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa/git/trees/5e40845071aa4b59612ef57d2602662de008725d"));
	expect(@(entry2.type)).to(equal(@(OCTTreeEntryTypeTree)));
	expect(@(entry2.mode)).to(equal(@(OCTTreeEntryModeSubdirectory)));

	OCTCommitTreeEntry *entry3 = tree.entries[2];
	expect(entry3).to(beAnInstanceOf(OCTCommitTreeEntry.class));
	expect(entry3.path).to(equal(@"TransformerKit"));
	expect(entry3.SHA).to(equal(@"1617ae09f662dc252805d818ae8a82626700523a"));
	expect(@(entry3.type)).to(equal(@(OCTTreeEntryTypeCommit)));
	expect(@(entry3.mode)).to(equal(@(OCTTreeEntryModeSubmodule)));

	OCTBlobTreeEntry *entry4 = tree.entries[3];
	expect(entry4).to(beAnInstanceOf(OCTBlobTreeEntry.class));
	expect(entry4.path).to(equal(@"ReactiveCocoaFramework/ReactiveCocoa/RACBehaviorSubject.m"));
	expect(entry4.SHA).to(equal(@"dfda2ac07356f34e422df17673fc8148fae7d3b9"));
	expect(@(entry4.type)).to(equal(@(OCTTreeEntryTypeBlob)));
	expect(@(entry4.mode)).to(equal(@(OCTTreeEntryModeFile)));
	expect(entry4.URL.absoluteString).to(equal(@"https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa/git/blobs/dfda2ac07356f34e422df17673fc8148fae7d3b9"));
	expect(@(entry4.size)).to(equal(@1209));
});

QuickSpecEnd
