//
//  OCTOrg.m
//  OctoKit
//
//  Created by Joe Ricioppo on 10/27/10.
//  Copyright 2010 GitHub. All rights reserved.
//

#import "OCTOrg.h"
#import "OCTTeam.h"

@implementation OCTOrg

#pragma mark MTLModel

+ (NSValueTransformer *)teamsTransformer {
	return [NSValueTransformer mtl_externalRepresentationArrayTransformerWithModelClass:OCTTeam.class];
}

- (void)mergeTeamsFromModel:(OCTOrg *)model {
	// Teams are fetched separately from the actual Org. So when we merge, the
	// other model's teams will always be nil. Ignore that.
}

@end
