//
//  OCTPlan.h
//  OctoClient
//
//  Created by Josh Abernathy on 1/21/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTObject.h"

@interface OCTPlan : OCTObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger collaborators;
@property (nonatomic, assign) NSUInteger space;
@property (nonatomic, assign) NSUInteger privateRepos;

@end
