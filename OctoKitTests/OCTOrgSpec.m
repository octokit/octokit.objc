//
//  OCTOrgSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTOrg.h"
#import "OCTPlan.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTOrg)

NSDictionary *representation = @{
	@"login": @"github",
	@"id": @1,
	@"url": @"https://api.github.com/orgs/github",
	@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
	@"company": @"GitHub",
	@"blog": @"https://github.com/blog",
	@"location": @"San Francisco",
	@"email": @"octocat@github.com",
	@"public_repos": @2,
	@"public_gists": @1,
	@"followers": @20,
	@"following": @0,
	@"html_url": @"https://github.com/octocat",
	@"created_at": @"2008-01-14T04:33:35Z",
	@"type": @"Organization",
	@"owned_private_repos": @100,
	@"private_gists": @81,
	@"disk_usage": @10000,
	@"collaborators": @8,
	@"billing_email": @"support@github.com",
	@"plan": @{
		@"name": @"Medium",
		@"space": @400,
		@"private_repos": @20
	}
};

__block OCTOrg *org;

before(^{
	org = [[OCTOrg alloc] initWithExternalRepresentation:representation];
	expect(org).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: org };
});

itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
	// Our shared example doesn't know how to handle recursive external
	// representations, so don't test it.
	NSMutableDictionary *flattenedRepresentation = [representation mutableCopy];
	[flattenedRepresentation removeObjectForKey:@"plan"];

	return @{ OCTObjectKey: org, OCTObjectExternalRepresentationKey: flattenedRepresentation };
});

it(@"should initialize", ^{
	expect(org.login).to.equal(@"github");
	expect(org.name).to.equal(@"github");
	expect(org.objectID).to.equal(@"1");
	expect(org.avatarURL).to.equal([NSURL URLWithString:@"https://github.com/images/error/octocat_happy.gif"]);
	expect(org.company).to.equal(@"GitHub");
	expect(org.blog).to.equal(@"https://github.com/blog");
	expect(org.email).to.equal(@"octocat@github.com");
	expect(org.publicRepoCount).to.equal(2);
	expect(org.privateRepoCount).to.equal(100);
	expect(org.diskUsage).to.equal(10000);
	expect(org.collaborators).to.equal(8);

	expect(org.plan).notTo.beNil();
	expect(org.plan.name).to.equal(@"Medium");
	expect(org.plan.space).to.equal(400);
	expect(org.plan.privateRepos).to.equal(20);
});

SpecEnd
