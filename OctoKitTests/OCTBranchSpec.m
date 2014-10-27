//
//  OCTBranchSpec.m
//  OctoKit
//
//  Created by Piet Brauer on 08.02.14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObject+Private.h"

QuickSpecBegin(OCTBranch)

describe(@"github.com branch", ^{
	NSDictionary *representation = @{
		@"name": @"master",
		@"commit": @{
			@"sha": @"6dcb09b5b57875f334f61aebed695e2e4193db5e",
			@"url": @"https://api.github.com/repos/octocat/Hello-World/commits/c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc"
		}
	};

	__block OCTBranch *branch;

	beforeEach(^{
		branch = [MTLJSONAdapter modelOfClass:OCTBranch.class fromJSONDictionary:representation error:NULL];
		expect(branch).notTo.beNil();
	});

	it(@"should initialize from an external representation", ^{
		expect(branch.name).to.equal(@"master");
		expect(branch.lastCommitSHA).to.equal(@"6dcb09b5b57875f334f61aebed695e2e4193db5e");
		expect(branch.lastCommitURL).to.equal([NSURL URLWithString:@""@"https://api.github.com/repos/octocat/Hello-World/commits/c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc"]);
	});
});

QuickSpecEnd
