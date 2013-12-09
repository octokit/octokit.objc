//
//  OCTClient+Commits.h
//  OctoKit
//
//  Created by Jackson Harper on 12/9/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@class OCTPullRequest;

@interface OCTClient (Commits)

- (RACSignal *)fetchCommitsForPullRequest:(OCTPullRequest *)pullRequest;

@end
