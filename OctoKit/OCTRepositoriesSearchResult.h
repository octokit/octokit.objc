//
//  OCTRepositoriesSearchResult.h
//  OctoKit
//
//  Created by leichunfeng on 15/5/10.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTRepositoriesSearchResult : OCTObject

@property (nonatomic, assign, readonly) NSUInteger totalCount;
@property (nonatomic, assign, getter = isIncompleteResults, readonly) BOOL incompleteResults;
@property (nonatomic, strong, readonly) NSArray *repositories;

@end
