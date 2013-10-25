//
//  OCTTestClient.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-10-24.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTTestClient : OCTClient

// Changes the behavior of +openURL: so that it always or never succeeds.
+ (void)setShouldSucceedOpeningURL:(BOOL)shouldSucceed;

// Sends all URLs passed to +openURL:.
+ (RACSignal *)openedURLs;

@end
