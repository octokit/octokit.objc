//
//  OCTWebHook.h
//  OctoKit
//
//  Created by Benjamin Dobell on 3/8/16.
//  Copyright (c) 2016 GitHub. All rights reserved.
//

#import "OCTHook.h"

// The Content-Type of hook payloads will be application/json.
extern NSString * const OCTWebHookContentTypeJSON;

// The Content-Type of hook payloads will be application/x-www-form-urlencoded.
extern NSString * const OCTWebHookContentTypeURLEncodedForm;

// A Github webhook.
@interface OCTWebHook : OCTHook

// The URL that content will be HTTP POST to when this hook is triggered.
@property (nonatomic, copy, readonly) NSURL *hookURL;

// The type of the content sent when this hook is triggered.
@property (nonatomic, copy, readonly) NSString *contentType;

// Optional shared secret key for generating a HMAC digest of the content sent
// to this hook.
@property (nonatomic, copy, readonly) NSString *secret;

// Whether SSL certificate verification of the `hookURL` host should not be
// performed.
@property (nonatomic, assign, getter=isInsecureSSL, readonly) BOOL insecureSSL;

@end
