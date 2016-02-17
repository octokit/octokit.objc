//
//  OCTClient+Issues.h
//  OctoKit
//
//  Created by leichunfeng on 15/3/7.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

typedef NS_ENUM(NSInteger, OCTClientIssueState) {
	OCTClientIssueStateOpen,
	OCTClientIssueStateClosed,
	OCTClientIssueStateAll,
};

@interface OCTClient (Issues)

/// Creates an issue.
///
/// title      - The title of the issue. This must not be nil.
/// body       - The contents of the issue. This can be nil.
/// assignee   - Login for the user that this issue should be assigned to. NOTE:
///              Only users with push access can set the assignee for new issues.
//               The assignee is silently dropped otherwise. This can be nil.
/// milestone  - Milestone to associate this issue with. NOTE: Only users with
///              push access can set the milestone for new issues. The milestone
///              is silently dropped otherwise. This can be nil.
/// labels     - Labels to associate with this issue. NOTE: Only users with push
///              access can set labels for new issues. Labels are silently dropped
///              otherwise. This can be nil.
/// repository - The repository in which to create the issue. This must not be nil.
///
/// Returns a signal which will send the created `OCTIssue` then complete, or error.
- (RACSignal *)createIssueWithTitle:(NSString *)title body:(NSString *)body assignee:(NSString *)assignee milestone:(NSNumber *)milestone labels:(NSArray *)labels inRepository:(OCTRepository *)repository;

/// Fetch the issues with the given state from the repository.
///
/// repository - The repository whose issues should be fetched. Cannot be nil.
/// state      - The state of issues to return.
/// etag       - An Etag from a previous request, used to avoid downloading
//               unnecessary data. May be nil.
/// since      - Only issues updated or created after this date will be fetched.
///              May be nil.
///
/// Returns a signal which will send each `OCTResponse`-wrapped `OCTIssue`s and
/// complete or error.
- (RACSignal *)fetchIssuesForRepository:(OCTRepository *)repository state:(OCTClientIssueState)state notMatchingEtag:(NSString *)etag since:(NSDate *)since;

@end
