//
//  OCTGitCommit.h
//  OctoKit
//
//  Created by Piet Brauer on 09.02.14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTGitCommit : OCTObject

@property (nonatomic, copy, readonly) NSURL *commitURL;

@property (nonatomic, copy, readonly) NSString *message;

@property (nonatomic, copy, readonly) NSString *SHA;

@property (nonatomic, copy, readonly) OCTUser *committer;

@property (nonatomic, copy, readonly) OCTUser *author;

@end
