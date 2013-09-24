//
//  OCTReviewComment.h
//  OctoKit
//
//  Created by Jackson Harper on 9/23/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCTComment.h"

@protocol OCTReviewComment <OCTComment>

// The relative path of the file being commented on.
@property (nonatomic, copy, readonly) NSString *path;

// The current HEAD SHA of the code being commented on.
@property (nonatomic, copy, readonly) NSString *commitSHA;

// The line index of the code being commented on.
@property (nonatomic, copy, readonly) NSNumber *position;

@end
