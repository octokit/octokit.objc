#import "OCTFile.h"

@implementation OCTFile

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"rawURL": @"raw_url",
		@"blobURL": @"blob_url",
		@"countOfChanges": @"changes",
		@"countOfAdditions": @"additions",
		@"countOfDeletions": @"deletions",
	}];
}

+ (NSValueTransformer *)blobURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)rawURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
