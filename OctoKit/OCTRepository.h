//
//  OCTRepository.h
//  OctoKit
//
//  Created by Timothy Clem on 2/14/11.
//  Copyright 2011 GitHub. All rights reserved.
//

#import "OCTObject.h"

@interface OCTRepository : OCTObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *repoDescription;
@property (nonatomic, assign, getter=isPrivate) BOOL private;
@property (nonatomic, copy) NSString *ownerLogin;
@property (nonatomic, strong) NSDate *datePushed;
@property (nonatomic, copy) NSURL *HTTPSURL;
@property (nonatomic, copy) NSString *SSHURL;
@property (nonatomic, copy) NSURL *gitURL;
@property (nonatomic, copy) NSURL *HTMLURL;

@end
