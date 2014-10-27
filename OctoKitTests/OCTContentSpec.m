//
//  OCTContentSpec.m
//  OctoKit
//
//  Created by Aron Cedercrantz on 14-07-2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTContentSpec)

__block NSArray *contentDictionaries;

beforeAll(^{
	NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"content" withExtension:@"json"];
	expect(testDataURL).notTo.beNil();

	NSData *testContentData = [NSData dataWithContentsOfURL:testDataURL];
	expect(testContentData).notTo.beNil();

	contentDictionaries = [NSJSONSerialization JSONObjectWithData:testContentData options:0 error:NULL];
	expect(contentDictionaries).to.beKindOf(NSArray.class);
});

__block NSDictionary *contentByName;

beforeEach(^{
	NSMutableDictionary *mutableContent = [NSMutableDictionary dictionaryWithCapacity:contentDictionaries.count];
	for (NSDictionary *contentDict in contentDictionaries) {
		OCTContent *content = [MTLJSONAdapter modelOfClass:OCTContent.class fromJSONDictionary:contentDict error:NULL];
		expect(content).notTo.beNil();
		expect(content).to.beKindOf(OCTContent.class);

		// Although each instance should be of the OCTContent kind none should
		// be an instance of OCTContent itself.
		expect(content.class).notTo.equal(OCTContent.class);

		expect(content.name.length).to.beGreaterThan(0);
		mutableContent[content.name] = content;
	}

	contentByName = mutableContent;

	expect(contentByName.count).to.equal(4);
});

describe(@"OCTDirectoryContent", ^{
	it(@"should have deserialized", ^{
		OCTDirectoryContent *content = contentByName[@"octokit"];
		expect(content).notTo.beNil();
		expect(content).to.beKindOf(OCTDirectoryContent.class);

		expect(content.name).to.equal(@"octokit");
		expect(content.size).to.equal(0);
		expect(content.path).to.equal(@"lib/octokit");
		expect(content.SHA).to.equal(@"a84d88e7554fc1fa21bcbc4efae3c782a70d2b9d");
	});
});

describe(@"OCTFileContent", ^{
	it(@"should have deserialized", ^{
		OCTFileContent *content = contentByName[@"README.md"];
		expect(content).notTo.beNil();
		expect(content).to.beKindOf(OCTFileContent.class);

		expect(content.name).to.equal(@"README.md");
		expect(content.size).to.equal(2706);
		expect(content.path).to.equal(@"README.md");
		expect(content.SHA).to.equal(@"2eee5e61e61bec2346fd40d56719c2f28f5e0fc3");
		expect(content.encoding).to.equal(@"base64");
		expect(content.content).to.equal(@"dGhlIGJhc2U2NCBlbmNvZGVkIGRhdGHigKY=");
	});
});

describe(@"OCTSubmoduleContent", ^{
	it(@"should have deserialized", ^{
		OCTSubmoduleContent *content = contentByName[@"qunit"];
		expect(content).notTo.beNil();
		expect(content).to.beKindOf(OCTSubmoduleContent.class);

		expect(content.name).to.equal(@"qunit");
		expect(content.size).to.equal(0);
		expect(content.path).to.equal(@"test/qunit");
		expect(content.SHA).to.equal(@"6ca3721222109997540bd6d9ccd396902e0ad2f9");
		expect(content.submoduleGitURL).to.equal(@"git@github.com:octokit/octokit.objc.git");
	});
});

describe(@"OCTSymlinkContent", ^{
	it(@"should have deserialized", ^{
		OCTSymlinkContent *content = contentByName[@"some-symlink"];
		expect(content).notTo.beNil();
		expect(content).to.beKindOf(OCTSymlinkContent.class);

		expect(content.name).to.equal(@"some-symlink");
		expect(content.size).to.equal(23);
		expect(content.path).to.equal(@"bin/some-symlink");
		expect(content.SHA).to.equal(@"452a98979c88e093d682cab404a3ec82babebb48");
		expect(content.target).to.equal(@"/path/to/symlink/target");
	});
});

QuickSpecEnd
