//
//  OCTMilestoneSpec.m
//  OctoKit
//
//  Created by Toby Boudreaux on 2013-06-12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTMilestone.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTMilestone)

NSDictionary *representation = @{
									 @"html_url" : @"https://github.com/octocat/Hello-World/milestones/1",
									 @"url": @"https://api.github.com/repos/octocat/Hello-World/milestones/1",
									 @"number": @1,
									 @"state": @"open",
									 @"title": @"v1.0",
									 @"description": @"",
									 @"creator": @{
										@"login": @"octocat",
										@"id": @1,
										@"avatar_url": @"https://github.com/images/error/octocat_happy.gif",
										@"gravatar_id": @"somehexcode",
										@"url": @"https://api.github.com/users/octocat"
									},
				 @"open_issues": @4,
				 @"closed_issues": @8,
				 @"created_at": [NSDateFormatter oct_dateFromString:@"2011-04-10T20:09:31Z"],
				 @"due_on": NSNull.null
		 };

__block OCTMilestone *milestone;

before(^{
	milestone = [MTLJSONAdapter modelOfClass:OCTMilestone.class fromJSONDictionary:representation error:NULL];
	expect(milestone).notTo.beNil();
});

itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
	return @{ OCTObjectKey: milestone };
});

it(@"should initialize", ^{
	expect(milestone.objectID).to.equal(@"1");
	expect(milestone.HTMLURL).to.equal([NSURL URLWithString:@"https://github.com/octocat/Hello-World/milestones/1"]);
	expect(milestone.title).to.equal(@"v1.0");
	expect(milestone.dueOnDate).to.equal(nil);
	expect(milestone.dateCreated).to.equal([NSDateFormatter oct_dateFromString:@"2011-04-10T20:09:31Z"]);
});

SpecEnd
