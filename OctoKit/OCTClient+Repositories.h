//
//  OCTClient+Repositories.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "OCTClient.h"

@class OCTOrganization;
@class OCTRepository;
@class OCTTeam;

@interface OCTClient (Repositories)

// Fetches the repositories of the current `user`.
//
// Returns a signal which sends zero or more OCTRepository objects. Private
// repositories will only be included if the client is `authenticated`. If no
// `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserRepositories;

/// Fetches the public repositories for the specified `user`.
///
/// user    - The specified user. This must not be nil.
/// offset  - Allows you to specify an offset at which items will begin being
///           returned.
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns a signal which sends zero or more OCTRepository objects. Private
/// repositories will not be included.
- (RACSignal *)fetchPublicRepositoriesForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage;

// Fetches the starred repositories of the current `user`.
//
// Returns a signal which sends zero or more OCTRepository objects. Private
// repositories will only be included if the client is `authenticated`. If no
// `user` is set, the signal will error immediately.
- (RACSignal *)fetchUserStarredRepositories;

/// Fetches the starred repositories for the specified `user`.
///
/// user    - The specified user. This must not be nil.
/// offset  - Allows you to specify an offset at which items will begin being
///           returned.
/// perPage - The perPage parameter. You can set a custom page size up to 100 and
///           the default value 30 will be used if you pass 0 or greater than 100.
///
/// Returns a signal which sends zero or more OCTRepository objects. Private
/// repositories will not be included.
- (RACSignal *)fetchStarredRepositoriesForUser:(OCTUser *)user offset:(NSUInteger)offset perPage:(NSUInteger)perPage;

// Fetches the specified organization's repositories.
//
// Returns a signal which sends zero or more OCTRepository objects. Private
// repositories will only be included if the client is `authenticated` and the
// `user` has permission to see them.
- (RACSignal *)fetchRepositoriesForOrganization:(OCTOrganization *)organization;

// Creates a repository under the user's account.
//
// Returns a signal which sends the new OCTRepository. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)createRepositoryWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate;

// Creates a repository under the specified organization's account, and
// associates it with the given team.
//
// Returns a signal which sends the new OCTRepository. If the client is not
// `authenticated`, the signal will error immediately.
- (RACSignal *)createRepositoryWithName:(NSString *)name organization:(OCTOrganization *)organization team:(OCTTeam *)team description:(NSString *)description private:(BOOL)isPrivate;

// Fetches the content at `relativePath` at the given `reference` from the
// `repository`.
//
// In case `relativePath` is `nil` the contents of the repository root will be
// sent.
//
// repository   - The repository from which the file should be fetched.
// relativePath - The relative path (from the repository root) of the file that
//                should be fetched, may be `nil`.
// reference    - The name of the commit, branch or tag, may be `nil` in which
//                case it defaults to the default repo branch.
//
// Returns a signal which will send zero or more OCTContents depending on if the
// relative path resolves at all or, resolves to a file or directory.
- (RACSignal *)fetchRelativePath:(NSString *)relativePath inRepository:(OCTRepository *)repository reference:(NSString *)reference;

// Fetches the readme of a `repository`.
//
// repository - The repository for which the readme should be fetched.
//
// Returns a signal which will send zero or one OCTContent.
- (RACSignal *)fetchRepositoryReadme:(OCTRepository *)repository;

// Fetches the readme of a `repository` by the given `reference`.
//
// repository - The repository for which the readme should be fetched.
// reference  - The name of the commit, branch or tag, may be `nil` in which
//              case it defaults to the default repo branch.
//
// Returns a signal which will send zero or one OCTContent.
- (RACSignal *)fetchRepositoryReadme:(OCTRepository *)repository reference:(NSString *)reference;

// Fetches a specific repository owned by the given `owner` and named `name`.
//
// name  - The name of the repository, must be a non-empty string.
// owner - The owner of the repository, must be a non-empty string.
//
// Returns a signal of zero or one OCTRepository.
- (RACSignal *)fetchRepositoryWithName:(NSString *)name owner:(NSString *)owner;

// Fetches all branches of a specific repository owned by the given `owner` and named `name`.
//
// name  - The name of the repository, must be a non-empty string.
// owner - The owner of the repository, must be a non-empty string.
//
// Returns a signal of zero or one OCTBranch.
- (RACSignal *)fetchBranchesForRepositoryWithName:(NSString *)name owner:(NSString *)owner;

// Fetches all open pull requests (returned as issues) of a specific
// repository owned by the given `owner` and named `name`.
//
// name  - The name of the repository, must be a non-empty string.
// owner - The owner of the repository, must be a non-empty string.
//
// Returns a signal of zero or one OCTPullRequest.
- (RACSignal *)fetchOpenPullRequestsForRepositoryWithName:(NSString *)name owner:(NSString *)owner;

// Fetches all closed pull requests (returned as issues) of a specific
// repository owned by the given `owner` and named `name`.
//
// name  - The name of the repository, must be a non-empty string.
// owner - The owner of the repository, must be a non-empty string.
//
// Returns a signal of zero or one OCTPullRequest.
- (RACSignal *)fetchClosedPullRequestsForRepositoryWithName:(NSString *)name owner:(NSString *)owner;

// Fetches a single pull request on a specific repository owned by the
// given `owner` and named `name` and with the pull request number 'number'.
//
// name   - The name of the repository, must be a non-empty string.
// owner  - The owner of the repository, must be a non-empty string.
// number - The pull request number on the repository, must be integer
//
// Returns a signal of zero or one OCTPullRequest.
- (RACSignal *)fetchSinglePullRequestForRepositoryWithName:(NSString *)name owner:(NSString *)owner number:(NSInteger)number;

/// Create a pull request in the repository.
///
/// repository - The repository on which the pull request will be created.
///              Cannot be nil.
/// title      - The title for the pull request. Cannot be nil.
/// body       - The body for the pull request. May be nil.
/// baseBranch - The name of the branch into which the changes will be merged.
///              Cannot be nil.
/// headBranch - The name of the branch which will be brought into `baseBranch`.
///              Cannot be nil.
///
/// Returns a signal of an OCTPullRequest.
- (RACSignal *)createPullRequestInRepository:(OCTRepository *)repository title:(NSString *)title body:(NSString *)body baseBranch:(NSString *)baseBranch headBranch:(NSString *)headBranch;

// Fetches commits of the given `repository` filtered by `SHA`.
// If no SHA is given, the commit history of all branches is returned.
//
// repository  - The repository to fetch from.
// SHA         - SHA or branch to start listing commits from.
//
// Returns a signal of zero or one OCTGitCommit.
- (RACSignal *)fetchCommitsFromRepository:(OCTRepository *)repository SHA:(NSString *)SHA;

// Fetches a single commit specified by the `SHA` from a `repository`.
//
// repository  - The repository to fetch from.
// SHA         - The SHA of the commit.
//
// Returns a signal of zero or one OCTGitCommit.
- (RACSignal *)fetchCommitFromRepository:(OCTRepository *)repository SHA:(NSString *)SHA;

// Fetches the statuses for the specified `reference` in the repository with the
// given `name` and owned by the given `owner`.
//
// name       - The name of the repository, must be a non-empty string.
// owner      - The owner of the repository, must be a non-empty string.
// reference  - The name of the commit, branch or tag, must be a non-empty string.
//
// Returns a signal of zero or more OCTGitCommitStatus.
- (RACSignal *)fetchCommitStatusesForRepositoryWithName:(NSString *)name owner:(NSString *)owner reference:(NSString *)reference;

// Fetches the combined status for the specified `reference` in the repository
// with the given `name` and owned by the given `owner`.
//
// name       - The name of the repository, must be a non-empty string.
// owner      - The owner of the repository, must be a non-empty string.
// reference  - The name of the commit, branch or tag, must be a non-empty string.
//
// Returns a signal of zero or one OCTCommitCombinedStatus.
- (RACSignal *)fetchCommitCombinedStatusForRepositoryWithName:(NSString *)name owner:(NSString *)owner reference:(NSString *)reference;

@end
