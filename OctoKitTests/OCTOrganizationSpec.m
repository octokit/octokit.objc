//
//  OCTOrganizationSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTOrganization)

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

__block OCTOrganization *organization;

before(^{
	organization = [MTLJSONAdapter modelOfClass:OCTOrganization.class fromJSONDictionary:representation error:NULL];
	expect(organization).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: organization };
});

itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
	// Our shared example doesn't know how to handle recursive external
	// representations, so don't test it.
	NSMutableDictionary *flattenedRepresentation = [representation mutableCopy];
	[flattenedRepresentation removeObjectForKey:@"plan"];

	return @{ OCTObjectKey: organization, OCTObjectExternalRepresentationKey: flattenedRepresentation };
});

it(@"should initialize", ^{
	expect(organization.login).to.equal(@"github");
	expect(organization.name).to.equal(@"github");
	expect(organization.objectID).to.equal(@"1");
	expect(organization.avatarURL).to.equal([NSURL URLWithString:@"https://github.com/images/error/octocat_happy.gif"]);
	expect(organization.company).to.equal(@"GitHub");
	expect(organization.blog).to.equal(@"https://github.com/blog");
	expect(organization.email).to.equal(@"octocat@github.com");
	expect(organization.publicRepoCount).to.equal(2);
	expect(organization.privateRepoCount).to.equal(100);
	expect(organization.diskUsage).to.equal(10000);
	expect(organization.collaborators).to.equal(8);

	expect(organization.plan).notTo.beNil();
	expect(organization.plan.name).to.equal(@"Medium");
	expect(organization.plan.space).to.equal(400);
	expect(organization.plan.privateRepos).to.equal(20);
});

QuickSpecEnd
