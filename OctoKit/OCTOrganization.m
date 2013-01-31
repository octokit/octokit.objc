//
//  OCTOrganization.m
//  OctoKit
//
//  Created by Joe Ricioppo on 10/27/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTOrganization.h"
#import "OCTTeam.h"

@implementation OCTOrganization

#pragma mark MTLModel

+ (NSValueTransformer *)teamsTransformer {
	return [NSValueTransformer mtl_externalRepresentationArrayTransformerWithModelClass:OCTTeam.class];
}

- (void)mergeTeamsFromModel:(OCTOrganization *)model {
	// Teams are fetched separately from the actual organization. So when we
	// merge, the other model's teams will always be nil. Ignore that.
}

@end
