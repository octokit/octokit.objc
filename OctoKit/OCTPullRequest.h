//
//  OCTPullRequest.h
//  OctoClient
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"

// A pull request on a repository.
@interface OCTPullRequest : OCTObject

// The webpage URL for this pull request.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The title of this pull request.
@property (nonatomic, copy, readonly) NSString *title;

@end
