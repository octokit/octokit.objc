//
//  OCTRepositorySpec.m
//  GitHub
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTFeed.h"
#import "OCTObjectSpec.h"

SpecBegin(OCTFeed)

describe(@"from JSON", ^{
  NSDictionary *representation = @{
    @"timeline_url": @"https://github.com/timeline",
    @"user_url": @"https://github.com/octocat",
    @"current_user_url": @"https://github.com/octocat.private",
    @"current_user_public_url": @"https://github.com/octocat",
    @"current_user_actor_url": @"https://github.com:octocat.private.actor",
    @"current_user_organization_url": @"https://github.com/organizations/octokit/defunkt.private.atom",
  };

  __block OCTFeed *feed;

  before(^{
    feed = [MTLJSONAdapter modelOfClass:OCTFeed.class fromJSONDictionary:representation error:NULL];
    expect(feed).notTo.beNil();
  });

  itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
    return @{ OCTObjectKey: feed };
  });

  itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
    return @{ OCTObjectKey: feed, OCTObjectExternalRepresentationKey: representation };
  });
  
  it(@"should initialize", ^{
    expect(feed.timelineURL).notTo.beNil();
    expect(feed.userURL).notTo.beNil();
    expect(feed.currentUserURL).notTo.beNil();
    expect(feed.currentUserPublicURL).notTo.beNil();
    expect(feed.currentUserActivityURL).notTo.beNil();
    expect(feed.currentUserOrgURL).notTo.beNil();
  });
});

SpecEnd
