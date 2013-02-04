//
//  OCTOrganization.h
//  OctoKit
//
//  Created by Joe Ricioppo on 10/27/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTEntity.h"

// An organization.
@interface OCTOrganization : OCTEntity

// The OCTTeams in this organization.
//
// OCTClient endpoints do not actually set this property. It is provided as
// a convenience for persistence and model merging.
@property (atomic, copy) NSArray *teams;

@end
