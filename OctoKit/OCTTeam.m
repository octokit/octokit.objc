//
//  OCTTeam.m
//  OctoKit
//
//  Created by Josh Abernathy on 3/28/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTTeam.h"

@implementation OCTTeam

#pragma mark NSObject

// I kinda hate implementing this to something so mostly useless, but this makes bindings happier.
- (NSString *)description {
	return self.name;
}

@end
