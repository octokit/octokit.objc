//
//  OCTObjectSpec.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-09-26.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <Quick/Quick.h>
#import <OctoKit/OctoKit.h>

#import "OCTObject+Private.h"
#import "OCTObjectSpec.h"

NSString * const OCTObjectArchivingSharedExamplesName = @"OCTObject archiving";
NSString * const OCTObjectExternalRepresentationSharedExamplesName = @"OCTObject externalRepresentation";
NSString * const OCTObjectKey = @"object";
NSString * const OCTObjectExternalRepresentationKey = @"externalRepresentation";

QuickSharedExampleGroupsBegin(OCTObjectSharedExamples)

sharedExamples(OCTObjectArchivingSharedExamplesName, ^(NSDictionary *data){
	__block OCTObject *obj;

	beforeEach(^{
		obj = data[OCTObjectKey];
		expect(obj).notTo.beNil();
	});

	it(@"should implement <NSCoding>", ^{
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
		expect(data).notTo.beNil();

		OCTObject *unarchivedObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		expect(unarchivedObj).to.equal(obj);
	});
});

sharedExamples(OCTObjectExternalRepresentationSharedExamplesName, ^(NSDictionary *data){
	__block OCTObject *obj;
	__block NSDictionary *representation;

	__block void (^expectRepresentationsToMatch)(NSDictionary *, NSDictionary *);

	beforeEach(^{
		obj = data[OCTObjectKey];
		expect(obj).notTo.beNil();

		representation = data[OCTObjectExternalRepresentationKey];
		expect(representation).notTo.beNil();

		__block void (^expectRepresentationsToMatchRecur)(NSDictionary *, NSDictionary *);
		expectRepresentationsToMatch = ^(NSDictionary *representation, NSDictionary *JSONDictionary) {
			[representation enumerateKeysAndObjectsUsingBlock:^(NSString *key, id expectedValue, BOOL *stop) {
				id value = JSONDictionary[key];
				if (value == nil) return;

				if ([value isKindOfClass:NSDictionary.class]) {
					expectRepresentationsToMatchRecur(value, expectedValue);
				} else {
					expect(value).to.equal(expectedValue);
				}
			}];
		};

		expectRepresentationsToMatchRecur = expectRepresentationsToMatch;
	});

	it(@"should be equal in all values that exist in both external representations", ^{
		NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:obj];
		expectRepresentationsToMatch(representation, JSONDictionary);
	});
});

QuickSharedExampleGroupsEnd

QuickSpecBegin(OCTObjectSpec)

describe(@"with an ID from JSON", ^{
	NSDictionary *representation = @{ @"id": @12345 };

	__block OCTObject *obj;

	before(^{
		obj = [MTLJSONAdapter modelOfClass:OCTObject.class fromJSONDictionary:representation error:NULL];
		expect(obj).notTo.beNil();
	});

	itShouldBehaveLike(OCTObjectArchivingSharedExamplesName, ^{
		return @{ OCTObjectKey: obj };
	});

	itShouldBehaveLike(OCTObjectExternalRepresentationSharedExamplesName, ^{
		return @{ OCTObjectKey: obj, OCTObjectExternalRepresentationKey: representation };
	});

	it(@"should have the same objectID", ^{
		expect(obj.objectID).to.equal(@"12345");
	});

	it(@"should be equal to another object with the same objectID", ^{
		OCTObject *secondObject = [MTLJSONAdapter modelOfClass:OCTObject.class fromJSONDictionary:representation error:NULL];
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
		obj = [[OCTObject alloc] initWithDictionary:dictionary error:NULL];
		expect(obj).notTo.beNil();
	});

	it(@"should have the same objectID", ^{
		expect(obj.objectID).to.equal(@"12345");
	});

	it(@"should be from an enterprise server", ^{
		expect(obj.server.enterprise).to.beTruthy();
	});

	it(@"should be equal to another object with the same objectID from the same server", ^{
		OCTObject *secondObject = [[OCTObject alloc] initWithDictionary:dictionary error:NULL];
		expect(obj).to.equal(secondObject);
	});

});

it(@"should not equal a OCTObject from another server", ^{
	OCTObject *dotComObject = [[OCTObject alloc] init];
	OCTServer *enterpriseServer = [OCTServer serverWithBaseURL:[NSURL URLWithString:@"https://localhost"]];

	OCTObject *enterpriseObject = [[OCTObject alloc] init];
	enterpriseObject.baseURL = enterpriseServer.APIEndpoint;

	expect(enterpriseObject).toNot.equal(dotComObject);
});

it(@"should convert a numeric objectID to a string", ^{
	OCTObject *obj = [OCTObject modelWithDictionary:@{
		@keypath(obj, objectID): @42
	} error:NULL];

	expect(obj).notTo.beNil();
	expect(obj.objectID).to.beKindOf(NSString.class);
	expect(obj.objectID).to.equal(@"42");
});

it(@"should initialize with a nil objectID", ^{
	OCTObject *obj = [OCTObject modelWithDictionary:@{
		@keypath(obj, objectID): NSNull.null
	} error:NULL];

	expect(obj).notTo.beNil();
	expect(obj.objectID).to.beNil();
});

QuickSpecEnd
