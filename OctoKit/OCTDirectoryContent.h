//
//  OCTDirectoryContent.h
//  OctoKit
//
//  Created by Aron Cedercrantz on 14-07-2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTContent.h"

//{
//    "type": "dir",
//    "size": 0,
//    "name": "octokit",
//    "path": "lib/octokit",
//    "sha": "a84d88e7554fc1fa21bcbc4efae3c782a70d2b9d",
//    "url": "https://api.github.com/repos/pengwynn/octokit/contents/lib/octokit",
//    "git_url": "https://api.github.com/repos/pengwynn/octokit/git/trees/a84d88e7554fc1fa21bcbc4efae3c782a70d2b9d",
//    "html_url": "https://github.com/pengwynn/octokit/tree/master/lib/octokit",
//    "_links": {
//      "self": "https://api.github.com/repos/pengwynn/octokit/contents/lib/octokit",
//      "git": "https://api.github.com/repos/pengwynn/octokit/git/trees/a84d88e7554fc1fa21bcbc4efae3c782a70d2b9d",
//      "html": "https://github.com/pengwynn/octokit/tree/master/lib/octokit"
//    }
//  }

// A directory in a git repository.
@interface OCTDirectoryContent : OCTContent
@end
