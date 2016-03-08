//
//  OCTHook.h
//  OctoKit
//
//  Created by Benjamin Dobell on 3/8/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTUser;

// Commit or diff commented on.
extern NSString * const OCTHookEventCommitComment;

// Branch, or tag created.
extern NSString * const OCTHookEventCreate;

// Branch, or tag deleted.
extern NSString * const OCTHookEventDelete;

// Repository deployed.
extern NSString * const OCTHookEventDeployment;

// Deployment status updated from the API.
extern NSString * const OCTHookEventDeploymentStatus;

// Repository forked.
extern NSString * const OCTHookEventFork;

// Wiki page updated.
extern NSString * const OCTHookEventGollum;

// Issue commented on.
extern NSString * const OCTHookEventIssueComment;

// Issue opened, closed, assigned, or labeled.
extern NSString * const OCTHookEventIssues;

// Collaborator added to a non-organization repository.
extern NSString * const OCTHookEventMember;

// Pages site built.
extern NSString * const OCTHookEventPageBuild;

// Repository changes from private to public.
extern NSString * const OCTHookEventPublic;

// Pull request opened, closed, assigned, labeled, or synchronized.
extern NSString * const OCTHookEventPullRequest;

// Pull request diff commented on.
extern NSString * const OCTHookEventPullRequestReviewCommit;

// Git push to a repository.
extern NSString * const OCTHookEventPush;

// Release published in a repository.
extern NSString * const OCTHookEventRelease;

// Commit status updated from the API.
extern NSString * const OCTHookEventStatus;

// Team added or modified on a repository.
extern NSString * const OCTHookEventTeamAdd;

// User stars a repository.
extern NSString * const OCTHookEventWatch;

// A class cluster for Github hooks.
@interface OCTHook : OCTObject

// A HTTP POST to `testURL` will trigger this hook with the details of the most
// recent `OCTHookEventPush`, assuming the hook is subscribed to
// `OCTHookEventPush`. If not, the server will respond with status code 204.
@property (nonatomic, copy, readonly) NSURL *testURL;

// A HTTP POST to `pingURL` will trigger a "ping event" for this hook. For more
// details refer to: https://developer.github.com/webhooks/#ping-event
@property (nonatomic, copy, readonly) NSURL *pingURL;

// The name (or type) of hook. This will be either "web" or the name of a
// service that officially integrates with Github.
@property (nonatomic, copy, readonly) NSString *name;

// The names of all the events this hook subscribes to.
@property (nonatomic, copy, readonly) NSArray *events;

// Whether or not event details will be sent to this hook when one of the
// `events` occurs.
@property (nonatomic, assign, getter=isActive, readonly) BOOL active;

// The date at which the hook was originally created.
@property (nonatomic, copy, readonly) NSDate *creationDate;

// The date the hook was last updated. This will be equal to creationDate
// if the hook has not been updated.
@property (nonatomic, copy, readonly) NSDate *updatedDate;

@end
