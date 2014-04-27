//
//  OCTFeed.h
//  OctoKit
//
//  Created by Yorkie on 4/27/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTFeed : OCTObject

// The GitHub global public timeline.
@property (nonatomic, copy, readonly) NSURL *timelineURL;

// The public timeline for any user, using URI template.
@property (nonatomic, copy, readonly) NSURL *userURL;

// The private timeline for the authenticated user.
@property (nonatomic, copy, readonly) NSURL *currentUserURL;

// The public timeline for the authenticated user.
@property (nonatomic, copy, readonly) NSURL *currentUserPublicURL;

// The private timeline for activity created by the authenticated user.
@property (nonatomic, copy, readonly) NSURL *currentUserActivityURL;

// The private timeline for the authenticated user for a given organization, using URI template.
@property (nonatomic, copy, readonly) NSURL *currentUserOrgURL;

@end
