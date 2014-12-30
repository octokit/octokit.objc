//
//  OCTEventSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTObjectSpec.h"

QuickSpecBegin(OCTEventSpec)

__block NSArray *eventDictionaries;

beforeSuite(^{
	NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"events" withExtension:@"json"];
	expect(testDataURL).notTo(beNil());

	NSData *testEventData = [NSData dataWithContentsOfURL:testDataURL];
	expect(testEventData).notTo(beNil());

	eventDictionaries = [NSJSONSerialization JSONObjectWithData:testEventData options:0 error:NULL];
	expect(eventDictionaries).to(beAKindOf(NSArray.class));
});

__block NSDictionary *eventsByID;

beforeEach(^{
	NSMutableDictionary *mutableEvents = [NSMutableDictionary dictionaryWithCapacity:eventDictionaries.count];
	for (NSDictionary *eventDict in eventDictionaries) {
		OCTEvent *event = [MTLJSONAdapter modelOfClass:OCTEvent.class fromJSONDictionary:eventDict error:NULL];

		// We don't support all event types yet.
		if (event == nil) continue;

		expect(event).to(beAKindOf(OCTEvent.class));

		// Nothing should be an instance of OCTEvent itself.
		expect(event.class).notTo(equal(OCTEvent.class));

		mutableEvents[event.objectID] = event;
	}

	eventsByID = mutableEvents;

	// We don't support all of the event types in the test data, so we may not
	// have an equal amount, but we should've deserialized some.
	expect(@(eventsByID.count)).to(beGreaterThan(@0));
});

describe(@"archiving", ^{
	// Test archiving.
	//
	// External representations for events are necessarily recursive, so we
	// can't use our shared example (which doesn't support that).
	itBehavesLike(OCTObjectArchivingSharedExamplesName, ^{
		return @{ OCTObjectKey: eventsByID.allValues.lastObject };
	});
});

describe(@"OCTCommitCommentEvent", ^{
	it(@"should have deserialized", ^{
		OCTCommitCommentEvent *event = eventsByID[@"1605861091"];
		expect(event).to(beAKindOf(OCTCommitCommentEvent.class));

		expect(event.repositoryName).to(equal(@"github/twui"));
		expect(event.actorLogin).to(equal(@"galaxas0"));
		expect(event.organizationLogin).to(equal(@"github"));
		expect(event.date).to(equal([[[ISO8601DateFormatter alloc] init] dateFromString:@"2012-10-02 22:03:12 +0000"]));

		expect(event.comment).to(beAKindOf(OCTCommitComment.class));
	});
});

describe(@"OCTPullRequestCommentEvent", ^{
	it(@"should have deserialized", ^{
		OCTPullRequestCommentEvent *event = eventsByID[@"1605868324"];
		expect(event).to(beAKindOf(OCTPullRequestCommentEvent.class));

		expect(event.repositoryName).to(equal(@"github/ReactiveCocoa"));
		expect(event.actorLogin).to(equal(@"jspahrsummers"));
		expect(event.organizationLogin).to(equal(@"github"));

		expect(event.comment).to(beAKindOf(OCTPullRequestComment.class));
		expect(event.comment.position).to(equal(@14));
		expect(event.comment.originalPosition).to(equal(@14));
		expect(event.comment.commitSHA).to(equal(@"7e731834f7fa981166cbb509a353dbe02eb5d1ea"));
		expect(event.comment.originalCommitSHA).to(equal(@"7e731834f7fa981166cbb509a353dbe02eb5d1ea"));
		expect(event.pullRequest).to(beNil());
	});
});

describe(@"OCTIssueCommentEvent", ^{
	it(@"should have deserialized", ^{
		OCTIssueCommentEvent *event = eventsByID[@"1605861266"];
		expect(event).to(beAKindOf(OCTIssueCommentEvent.class));

		expect(event.repositoryName).to(equal(@"github/twui"));
		expect(event.actorLogin).to(equal(@"galaxas0"));
		expect(event.organizationLogin).to(equal(@"github"));

		expect(event.comment).to(beAKindOf(OCTIssueComment.class));
		expect(event.issue).to(beAKindOf(OCTIssue.class));
	});
});

describe(@"OCTPushEvent", ^{
	it(@"should have deserialized", ^{
		OCTPushEvent *event = eventsByID[@"1605847260"];
		expect(event).to(beAKindOf(OCTPushEvent.class));

		expect(event.repositoryName).to(equal(@"github/ReactiveCocoa"));
		expect(event.actorLogin).to(equal(@"joshaber"));
		expect(event.organizationLogin).to(equal(@"github"));

		expect(@(event.commitCount)).to(equal(@36));
		expect(@(event.distinctCommitCount)).to(equal(@5));
		expect(event.previousHeadSHA).to(equal(@"623934b71f128f9bcc44482d6dc76b7fd4848d4d"));
		expect(event.currentHeadSHA).to(equal(@"da01b97c85d2a2d2b8e4021c2e3dff693a8f2c6b"));
		expect(event.branchName).to(equal(@"new-demo"));
	});
});

describe(@"OCTPullRequestEvent", ^{
	it(@"should have deserialized", ^{
		OCTPullRequestEvent *event = eventsByID[@"1605849683"];
		expect(event).to(beAKindOf(OCTPullRequestEvent.class));

		expect(event.repositoryName).to(equal(@"github/ReactiveCocoa"));
		expect(event.actorLogin).to(equal(@"joshaber"));
		expect(event.organizationLogin).to(equal(@"github"));

		expect(@(event.action)).to(equal(@(OCTIssueActionOpened)));
		expect(event.pullRequest).to(beAKindOf(OCTPullRequest.class));
	});
});

describe(@"OCTPullRequestEventAssignee", ^{
	it(@"should have an assignee", ^{
		OCTPullRequestEvent *event = eventsByID[@"1605825804"];
		expect(event).to(beAKindOf(OCTPullRequestEvent.class));

		expect(event.pullRequest.assignee.objectID).to(equal(@"432536"));
		expect(event.pullRequest.assignee.login).to(equal(@"jspahrsummers"));
	});
});

describe(@"OCTIssueEvent", ^{
	it(@"should have deserialized", ^{
		OCTIssueEvent *event = eventsByID[@"1605857918"];
		expect(event).to(beAKindOf(OCTIssueEvent.class));

		expect(event.repositoryName).to(equal(@"github/twui"));
		expect(event.actorLogin).to(equal(@"jwilling"));
		expect(event.organizationLogin).to(equal(@"github"));

		expect(@(event.action)).to(equal(@(OCTIssueActionOpened)));
		expect(event.issue).to(beAKindOf(OCTIssue.class));
	});
});

describe(@"OCTRefEvent", ^{
	it(@"should deserialize a creation event", ^{
		OCTRefEvent *event = eventsByID[@"1605847125"];
		expect(event).to(beAKindOf(OCTRefEvent.class));

		expect(event.repositoryName).to(equal(@"github/ReactiveCocoa"));
		expect(event.actorLogin).to(equal(@"joshaber"));
		expect(event.organizationLogin).to(equal(@"github"));

		expect(@(event.refType)).to(equal(@(OCTRefTypeBranch)));
		expect(@(event.eventType)).to(equal(@(OCTRefEventCreated)));
		expect(event.refName).to(equal(@"perform-selector"));
	});

	it(@"should deserialize a deletion event", ^{
		OCTRefEvent *event = eventsByID[@"1605820410"];
		expect(event).to(beAKindOf(OCTRefEvent.class));

		expect(event.repositoryName).to(equal(@"github/twui"));
		expect(event.actorLogin).to(equal(@"joshaber"));
		expect(event.organizationLogin).to(equal(@"github"));

		expect(@(event.refType)).to(equal(@(OCTRefTypeBranch)));
		expect(@(event.eventType)).to(equal(@(OCTRefEventDeleted)));
		expect(event.refName).to(equal(@"fix-make-first-responder"));
	});
});

describe(@"OCTForkEvent", ^{
	it(@"should have deserialized", ^{
		OCTForkEvent *event = eventsByID[@"2483893273"];
		expect(event).to(beAKindOf(OCTForkEvent.class));
		
		expect(event.repositoryName).to(equal(@"thoughtbot/Argo"));
		expect(event.actorLogin).to(equal(@"jspahrsummers"));
		
		expect(event.forkeeRepositoryName).to(equal(@"jspahrsummers/Argo"));
	});
});

describe(@"OCTMemberEvent", ^{
	it(@"should deserialize an addition event", ^{
		OCTMemberEvent *event = eventsByID[@"2472813496"];
		expect(event).to(beAKindOf(OCTMemberEvent.class));
		
		expect(event.repositoryName).to(equal(@"niftyn8/degenerate"));
		expect(event.actorLogin).to(equal(@"niftyn8"));
		
		expect(event.memberName).to(equal(@"houndci"));
		expect(@(event.action)).to(equal(@(OCTMemberActionAdded)));
	});
});

describe(@"OCTPublicEvent", ^{
	it(@"should have deserialized", ^{
		OCTPublicEvent *event = eventsByID[@"2485152382"];
		expect(event).to(beAKindOf(OCTPublicEvent.class));
		
		expect(event.repositoryName).to(equal(@"ethanjdiamond/AmIIn"));
		expect(event.actorLogin).to(equal(@"ethanjdiamond"));
	});
});

QuickSpecEnd
