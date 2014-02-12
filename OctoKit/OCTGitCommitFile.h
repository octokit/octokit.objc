#import <OctoKit/OctoKit.h>

// A file of a commit
@interface OCTGitCommitFile : OCTObject

// The filename in the repository.
@property (nonatomic, copy, readonly) NSString *filename;

// The number of additions made in the commit.
@property (nonatomic, readonly) NSUInteger countOfAdditions;

// The number of deletions made in the commit.
@property (nonatomic, readonly) NSUInteger countOfDeletions;

// The number of changes made in the commit.
@property (nonatomic, readonly) NSUInteger countOfChanges;

// The status of the commit, e.g. 'added' or 'modified'.
@property (nonatomic, copy, readonly) NSString *status;

// The GitHub URL for the whole file.
@property (nonatomic, copy, readonly) NSURL *rawURL;

// The GitHub blob URL.
@property (nonatomic, copy, readonly) NSURL *blobURL;

// The patch on this file in a commit.
@property (nonatomic, copy, readonly) NSString *patch;

@end
