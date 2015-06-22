//
//  OCTRepositoriesSearchResult.h
//  OctoKit
//
//  Created by leichunfeng on 15/5/10.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

// Represents the results of search repositories method.
@interface OCTRepositoriesSearchResult : OCTObject

// The total repositories count of the search results.
@property (nonatomic, assign, readonly) NSUInteger totalCount;

// Indicates whether the results incomplete or not.
@property (nonatomic, assign, getter = isIncompleteResults, readonly) BOOL incompleteResults;

// The repository array of the search results.
@property (nonatomic, copy, readonly) NSArray *repositories;

@end
