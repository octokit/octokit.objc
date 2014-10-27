//
//  OCTServerSpec.m
//  OctoKit
//
//  Created by Alan Rogers on 22/10/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <OctoKit/OctoKit.h>
#import <Quick/Quick.h>

#import "OCTServer+Private.h"

QuickSpecBegin(OCTServerSpec)

it(@"should have a dotComServer", ^{
	OCTServer *dotComServer = OCTServer.dotComServer;

	expect(dotComServer).toNot.beNil();
	expect(dotComServer.baseURL).to.beNil();
	expect(dotComServer.baseWebURL).to.equal([NSURL URLWithString:OCTServerDotComBaseWebURL]);
	expect(dotComServer.APIEndpoint).to.equal([NSURL URLWithString:OCTServerDotComAPIEndpoint]);
	expect(dotComServer.enterprise).to.beFalsy();
});

it(@"should be only one dotComServer", ^{
	OCTServer *dotComServer = [OCTServer serverWithBaseURL:nil];

	expect(dotComServer).to.equal(OCTServer.dotComServer);
});

it(@"can be an enterprise instance", ^{
	OCTServer *enterpriseServer = [OCTServer serverWithBaseURL:[NSURL URLWithString:@"https://localhost/"]];

	expect(enterpriseServer).toNot.beNil();
	expect(enterpriseServer.enterprise).to.beTruthy();
	expect(enterpriseServer.baseURL).to.equal([NSURL URLWithString:@"https://localhost/"]);
	expect(enterpriseServer.baseWebURL).to.equal(enterpriseServer.baseURL);
	expect(enterpriseServer.APIEndpoint).to.equal([NSURL URLWithString:@"https://localhost/api/v3/"]);
});

it(@"should use baseURL for equality", ^{
	OCTServer *dotComServer = OCTServer.dotComServer;

	OCTServer *enterpriseServer = [OCTServer serverWithBaseURL:[NSURL URLWithString:@"https://localhost/"]];
	OCTServer *secondEnterpriseServer = [OCTServer serverWithBaseURL:[NSURL URLWithString:@"https://localhost/"]];
	OCTServer *thirdEnterpriseServer = [OCTServer serverWithBaseURL:[NSURL URLWithString:@"https://192.168.0.1"]];

	expect(dotComServer).toNot.equal(enterpriseServer);
	expect(dotComServer).toNot.equal(secondEnterpriseServer);
	expect(dotComServer).toNot.equal(thirdEnterpriseServer);

	expect(enterpriseServer).to.equal(secondEnterpriseServer);
	expect(enterpriseServer).toNot.equal(thirdEnterpriseServer);

	expect(secondEnterpriseServer).toNot.equal(thirdEnterpriseServer);
});

QuickSpecEnd
