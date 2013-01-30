//
//  OCTOrg.h
//  OctoKit
//
//  Created by Joe Ricioppo on 10/27/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTEntity.h"

// An organization.
@interface OCTOrg : OCTEntity

// The OCTTeams in this organization.
@property (nonatomic, copy) NSArray *teams;

@end
