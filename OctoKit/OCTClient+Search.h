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
///  query     - The search keywords, as well as any qualifiers. This must not be nil.
///  orderBy   - The sort field. One of stars, forks, or updated. Default: results
///              are sorted by best match. This can be nil.
///  ascending - The sort order, ascending or not.
///
///  Returns a signal which will send the search result `OCTRepositoriesSearchResult`.
- (RACSignal *)searchRepositoriesWithQuery:(NSString *)query orderBy:(NSString *)orderBy ascending:(BOOL)ascending;

@end
