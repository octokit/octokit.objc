//
//  OCTClient+Search.h
//  OctoKit
//
//  Created by leichunfeng on 15/5/10.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTClient (Search)

- (RACSignal *)searchRepositoriesWithQuery:(NSString *)query sort:(NSString *)sort order:(NSString *)order;

@end
