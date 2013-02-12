//
//  OCTCommit.h
//  HubHub
//
//  Created by Josh Vera on 2/12/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "OCTObject.h"

@class OCTUser;

@interface OCTCommit : OCTObject

@property (nonatomic, copy, readonly) NSString *SHA;

@property (nonatomic, copy, readonly) NSURL *URL;

@property (nonatomic, copy, readonly) OCTUser *author;

@property (nonatomic, copy, readonly) OCTUser *committer;

@property (nonatomic, copy, readonly) NSString *message;

@end
