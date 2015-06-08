//
//  OCTClient+Search.h
//  OctoKit
//
//  Created by leichunfeng on 15/5/10.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTClient (Search)

///  Search repositories.
///
///  query - The search keywords, as well as any qualifiers. This must not be nil.
///  sort  - The sort field. One of stars, forks, or updated. Default: results
///          are sorted by best match. This can be nil.
///  order - The sort order if sort parameter is provided. One of asc or desc.
///          Default: desc. This can be nil.
///
///  Returns a signal which will send the search result `OCTRepositoriesSearchResult`.
- (RACSignal *)searchRepositoriesWithQuery:(NSString *)query sort:(NSString *)sort order:(NSString *)order;

@end
