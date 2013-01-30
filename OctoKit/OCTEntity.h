//
//  OCTEntity.h
//  OctoKit
//
//  Created by Josh Abernathy on 1/21/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTObject.h"

@class OCTPlan;

// Represents any GitHub object which is capable of owning repositories.
@interface OCTEntity : OCTObject

// Returns `login` if no name is explicitly set.
@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSArray *repositories;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSURL *avatarURL;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *blog;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, assign) NSUInteger collaborators;
@property (nonatomic, assign) NSUInteger publicRepoCount;
@property (nonatomic, assign) NSUInteger privateRepoCount;
@property (nonatomic, assign) NSUInteger diskUsage;
@property (nonatomic, readonly, strong) OCTPlan *plan;

// TODO: Fix this to "RemoteCounterparts".
- (void)mergeRepositoriesWithRemoteCountparts:(NSArray *)remoteRepositories;

@end
