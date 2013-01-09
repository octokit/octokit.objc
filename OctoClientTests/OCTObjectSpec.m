//
//  OCTObjectSpec.m
//  OctoClient
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTObject.h"
#import "OCTObject+Private.h"
#import "OCTServer.h"
#import "OCTObjectSpec.h"

NSString * const OCTObjectArchivingSharedExamplesName = @"OCTObject archiving";
NSString * const OCTObjectExternalRepresentationSharedExamplesName = @"OCTObject externalRepresentation";
NSString * const OCTObjectKey = @"object";
NSString * const OCTObjectExternalRepresentationKey = @"externalRepresentation";

SharedExamplesBegin(OCTObjectSharedExamples)

sharedExamplesFor(OCTObjectArchivingSharedExamplesName, ^(NSDictionary *data){
	OCTObject *obj = data[OCTObjectKey];
	expect(obj).notTo.beNil();

	it(@"should implement <NSCoding>", ^{
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
		expect(data).notTo.beNil();

		OCTObject *unarchivedObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		expect(unarchivedObj).to.equal(obj);
	});
});

sharedExamplesFor(OCTObjectExternalRepresentationSharedExamplesName, ^(NSDictionary *data){
	OCTObject *obj = data[OCTObjectKey];
	expect(obj).notTo.beNil();

	NSDictionary *representation = data[OCTObjectExternalRepresentationKey];
	expect(representation).notTo.beNil();

	// Check all values that exist as keys in both external representations.
	[representation enumerateKeysAndObjectsUsingBlock:^(NSString *key, id expectedValue, BOOL *stop) {
		id value = obj.externalRepresentation[key];
		if (value == nil) return;

		expect(value).to.equal(expectedValue);
	}];
});

SharedExamplesEnd

SpecBegin(OCTObject)

describe(@"with an ID from JSON", ^{
	NSDictionary *representation = @{ @"id": @12345 };

	__block OCTObject *obj;
	
	before(^{
		obj = [[OCTObject alloc] initWithExternalRepresentation:representation];
		expect(obj).notTo.beNil();

		itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, @{ OCTObjectKey: obj }, nil);
		itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, @{ OCTObjectKey: obj, OCTObjectExternalRepresentationKey: representation }, nil);
	});

	it(@"should have the same objectID", ^{
		expect(obj.objectID).to.equal(@"12345");
	});

	it(@"should be equal to another object with the same objectID", ^{
		OCTObject *secondObject = [[OCTObject alloc] initWithExternalRepresentation:representation];
		expect(obj).to.equal(secondObject);
	});

	it(@"should be from the dotComServer", ^{
		expect(obj.server).to.equal(OCTServer.dotComServer);
	});
});

describe(@"with an objectID and a baseURL", ^{
	NSDictionary *dictionary = @{ @"objectID": @"12345", @"baseURL": [NSURL URLWithString:@"https://foo.bar.com"] };

	__block OCTObject *obj;

	before(^{
		obj = [[OCTObject alloc] initWithDictionary:dictionary];
		expect(obj).notTo.beNil();
	});

	it(@"should have the same objectID", ^{
		expect(obj.objectID).to.equal(@"12345");
	});

	it(@"should be from an enterprise server", ^{
		expect(obj.server.enterprise).to.beTruthy();
	});

	it(@"should be equal to another object with the same objectID from the same server", ^{
		OCTObject *secondObject = [[OCTObject alloc] initWithDictionary:dictionary];
		expect(obj).to.equal(secondObject);
	});

});

it(@"should omit NSNulls from its external representation", ^{
	OCTObject *obj = [[OCTObject alloc] init];
	expect(obj).notTo.beNil();
	expect(obj.objectID).to.beNil();

	expect(obj.externalRepresentation[@"id"]).to.beNil();
});

it(@"should not equal a OCTObject from another server", ^{
	OCTObject *dotComObject = [[OCTObject alloc] init];
	OCTServer *enterpriseServer = [OCTServer serverWithBaseURL:[NSURL URLWithString:@"https://localhost"]];

	OCTObject *enterpriseObject = [[OCTObject alloc] init];
	enterpriseObject.baseURL = enterpriseServer.APIEndpoint;

	expect(enterpriseObject).toNot.equal(dotComObject);
});


SpecEnd
