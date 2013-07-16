//
//  OCTSubmoduleContent.h
//  OctoKit
//
//  Created by Aron Cedercrantz on 14-07-2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTContent.h"

// A submodule in a git repository.
@interface OCTSubmoduleContent : OCTContent

// The git URL of the submodule.
@property (nonatomic, copy, readonly) NSString *submoduleGitURL;

@end
