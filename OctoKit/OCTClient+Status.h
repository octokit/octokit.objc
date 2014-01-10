//
//  OCTClient+Status.h
//  OctoKit
//
//  Created by Jackson Harper on 1/10/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTClient (Status)

// Fetch the statuses for a specific reference in a repository. One common use
// is for continuous integration services to mark commits as passing or failing
// builds using Status. The target_url would be the full URL to the build output,
// and the description would be the high level summary of what happened with the build.
//
// ref        -  Ref to list the statuses from. It can be a SHA, a branch name, or a tag name.
// repository - The repository the
//
// Returns a signal which will send zero or more OCTStatus objects.
- (RACSignal *)fetchStatusesForReference:(NSString *)ref inRepository:(OCTRepository *)repository;

@end
