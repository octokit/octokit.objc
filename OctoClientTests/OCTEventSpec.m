//
//  OCTEventSpec.m
//  OctoClient
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTEvent.h"
#import "OCTCommitComment.h"
#import "OCTCommitCommentEvent.h"
#import "OCTIssue.h"
#import "OCTIssueEvent.h"
#import "OCTIssueComment.h"
#import "OCTIssueCommentEvent.h"
#import "OCTObjectSpec.h"
#import "OCTPullRequest.h"
#import "OCTPullRequestEvent.h"
#import "OCTPullRequestComment.h"
#import "OCTPullRequestCommentEvent.h"
#import "OCTPushEvent.h"
#import "OCTRefEvent.h"

SpecBegin(OCTEvent)

__block NSArray *eventDictionaries;

beforeAll(^{
	NSURL *testDataURL = [[NSBundle bundleForClass:self.class] URLForResource:@"test_events" withExtension:@"json"];
	expect(testDataURL).notTo.beNil();

	NSData *testEventData = [NSData dataWithContentsOfURL:testDataURL];
	expect(testEventData).notTo.beNil();

	eventDictionaries = [NSJSONSerialization JSONObjectWithData:testEventData options:0 error:NULL];
	expect(eventDictionaries).to.beKindOf(NSArray.class);
});

__block NSDictionary *eventsByID;

beforeEach(^{
	NSMutableDictionary *mutableEvents = [NSMutableDictionary dictionaryWithCapacity:eventDictionaries.count];
	for (NSDictionary *eventDict in eventDictionaries) {
		OCTEvent *event = [OCTEvent modelWithExternalRepresentation:eventDict];

		// We don't support all event types yet.
		if (event == nil) continue;

		expect(event).to.beKindOf(OCTEvent.class);

		// Nothing should be an instance of OCTEvent itself.
		expect(event.class).notTo.equal(OCTEvent.class);

		// Test archiving.
		//
		// External representations for events are necessarily recursive, so we
		// can't use our shared example (which doesn't support that).
		itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, @{ OCTObjectKey: event }, nil);

		mutableEvents[event.objectID] = event;
	}

	eventsByID = mutableEvents;

	// We don't support all of the event types in the test data, so we may not
	// have an equal amount, but we should've deserialized some.
	expect(eventsByID.count).to.beGreaterThan(0);
});

describe(@"OCTCommitCommentEvent", ^{
	it(@"should have deserialized", ^{
		OCTCommitCommentEvent *event = eventsByID[@"1605861091"];
		expect(event).to.beKindOf(OCTCommitCommentEvent.class);

		expect(event.repositoryName).to.equal(@"github/twui");
		expect(event.actorLogin).to.equal(@"galaxas0");
		expect(event.organizationLogin).to.equal(@"github");
		expect(event.date).to.equal([NSDate dateWithString:@"2012-10-02 22:03:12 +0000"]);

		expect(event.comment).to.beKindOf(OCTCommitComment.class);
	});
});

describe(@"OCTPullRequestCommentEvent", ^{
	it(@"should have deserialized", ^{
		OCTPullRequestCommentEvent *event = eventsByID[@"1605868324"];
		expect(event).to.beKindOf(OCTPullRequestCommentEvent.class);

		expect(event.repositoryName).to.equal(@"github/ReactiveCocoa");
		expect(event.actorLogin).to.equal(@"jspahrsummers");
		expect(event.organizationLogin).to.equal(@"github");

		expect(event.comment).to.beKindOf(OCTPullRequestComment.class);
		expect(event.pullRequest).to.beNil();
	});
});

describe(@"OCTIssueCommentEvent", ^{
	it(@"should have deserialized", ^{
		OCTIssueCommentEvent *event = eventsByID[@"1605861266"];
		expect(event).to.beKindOf(OCTIssueCommentEvent.class);

		expect(event.repositoryName).to.equal(@"github/twui");
		expect(event.actorLogin).to.equal(@"galaxas0");
		expect(event.organizationLogin).to.equal(@"github");

		expect(event.comment).to.beKindOf(OCTIssueComment.class);
		expect(event.issue).to.beKindOf(OCTIssue.class);
	});
});

describe(@"OCTPushEvent", ^{
	it(@"should have deserialized", ^{
		OCTPushEvent *event = eventsByID[@"1605847260"];
		expect(event).to.beKindOf(OCTPushEvent.class);

		expect(event.repositoryName).to.equal(@"github/ReactiveCocoa");
		expect(event.actorLogin).to.equal(@"joshaber");
		expect(event.organizationLogin).to.equal(@"github");

		expect(event.commitCount).to.equal(36);
		expect(event.distinctCommitCount).to.equal(5);
		expect(event.previousHeadSHA).to.equal(@"623934b71f128f9bcc44482d6dc76b7fd4848d4d");
		expect(event.currentHeadSHA).to.equal(@"da01b97c85d2a2d2b8e4021c2e3dff693a8f2c6b");
		expect(event.branchName).to.equal(@"new-demo");
	});
});

describe(@"OCTPullRequestEvent", ^{
	it(@"should have deserialized", ^{
		OCTPullRequestEvent *event = eventsByID[@"1605849683"];
		expect(event).to.beKindOf(OCTPullRequestEvent.class);

		expect(event.repositoryName).to.equal(@"github/ReactiveCocoa");
		expect(event.actorLogin).to.equal(@"joshaber");
		expect(event.organizationLogin).to.equal(@"github");

		expect(event.action).to.equal(OCTIssueActionOpened);
		expect(event.pullRequest).to.beKindOf(OCTPullRequest.class);
	});
});

describe(@"OCTIssueEvent", ^{
	it(@"should have deserialized", ^{
		OCTIssueEvent *event = eventsByID[@"1605857918"];
		expect(event).to.beKindOf(OCTIssueEvent.class);

		expect(event.repositoryName).to.equal(@"github/twui");
		expect(event.actorLogin).to.equal(@"jwilling");
		expect(event.organizationLogin).to.equal(@"github");

		expect(event.action).to.equal(OCTIssueActionOpened);
		expect(event.issue).to.beKindOf(OCTIssue.class);
	});
});

describe(@"OCTRefEvent", ^{
	it(@"should deserialize a creation event", ^{
		OCTRefEvent *event = eventsByID[@"1605847125"];
		expect(event).to.beKindOf(OCTRefEvent.class);

		expect(event.repositoryName).to.equal(@"github/ReactiveCocoa");
		expect(event.actorLogin).to.equal(@"joshaber");
		expect(event.organizationLogin).to.equal(@"github");

		expect(event.refType).to.equal(OCTRefTypeBranch);
		expect(event.eventType).to.equal(OCTRefEventCreated);
		expect(event.refName).to.equal(@"perform-selector");
	});

	it(@"should deserialize a deletion event", ^{
		OCTRefEvent *event = eventsByID[@"1605820410"];
		expect(event).to.beKindOf(OCTRefEvent.class);

		expect(event.repositoryName).to.equal(@"github/twui");
		expect(event.actorLogin).to.equal(@"joshaber");
		expect(event.organizationLogin).to.equal(@"github");

		expect(event.refType).to.equal(OCTRefTypeBranch);
		expect(event.eventType).to.equal(OCTRefEventDeleted);
		expect(event.refName).to.equal(@"fix-make-first-responder");
	});
});

SpecEnd
