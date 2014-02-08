//
//  OCTBranch.h
//  OctoKit
//
//  Created by Piet Brauer on 08.02.14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

// A GithHub repository branch.
@interface OCTBranch : OCTObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) NSString *lastCommitSHA;

@property (nonatomic, copy, readonly) NSString *lastCommitURL;

@end
