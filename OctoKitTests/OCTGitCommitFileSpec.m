//
// Created by Piet Brauer on 09.02.14.
// Copyright (c) 2014 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

QuickSpecBegin(OCTGitCommitFileSpec)

describe(@"github.com file", ^{
	NSDictionary *representation = @{
		@"filename": @"file1.txt",
		@"additions": @10,
		@"deletions": @2,
		@"changes": @12,
		@"status": @"modified",
		@"raw_url": @"https://github.com/octocat/Hello-World/raw/7ca483543807a51b6079e54ac4cc392bc29ae284/file1.txt",
		@"blob_url": @"https://github.com/octocat/Hello-World/blob/7ca483543807a51b6079e54ac4cc392bc29ae284/file1.txt",
		@"patch": @"@@ -29,7 +29,7 @@....."
	};

	__block OCTGitCommitFile *file;

	beforeEach(^{
		file = [MTLJSONAdapter modelOfClass:OCTGitCommitFile.class fromJSONDictionary:representation error:NULL];
		expect(file).notTo(beNil());
	});

	it(@"should initialize from an external representation", ^{
		expect(file.filename).to(equal(@"file1.txt"));
		expect(file.countOfAdditions).to(equal(10));
		expect(file.countOfDeletions).to(equal(2));
		expect(file.countOfChanges).to(equal(12));
		expect(file.status).to(equal(@"modified"));
		expect(file.rawURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/raw/7ca483543807a51b6079e54ac4cc392bc29ae284/file1.txt"]));
		expect(file.blobURL).to(equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/blob/7ca483543807a51b6079e54ac4cc392bc29ae284/file1.txt"]));
		expect(file.patch).to(equal(@"@@ -29,7 +29,7 @@....."));
	});
});

QuickSpecEnd
