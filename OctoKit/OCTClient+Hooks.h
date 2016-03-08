//
//  OCTClient+Hooks.h
//  OctoKit
//
//  Created by Benjamin Dobell on 3/8/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCTClient.h"

@class OCTRepository;

@interface OCTClient (Hooks)

// Creates (or updates) a Github repository hook. Existing hooks with a matching
// `name` will be updated instead of creating a new hook; with the possible
// exception of "web" hooks (for which multiple hooks may exist).
- (RACSignal *)createHookForEvents:(NSArray *)events active:(BOOL)active withName:(NSString *)name config:(NSDictionary *)config inRepository:(OCTRepository *)repository;

// Creates (or updates) a Github repository webhook. The Github API will update
// an existing webhook, rather than create a new one, when it makes sense to do
// so e.g. If an almost identical hook exists that is simply subscribed to one
// less event, then the existing hook will be updated to subscribe to the
// additional event.
- (RACSignal *)createWebHookForEvents:(NSArray *)events active:(BOOL)active withURL:(NSURL *)url contentType:(NSString *)contentType secret:(NSString *)secret insecureSSL:(BOOL)insecureSSL inRepository:(OCTRepository *)repository;

@end
