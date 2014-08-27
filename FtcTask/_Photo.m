// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Photo.m instead.

#import "_Photo.h"

const struct PhotoAttributes PhotoAttributes = {
	.farm = @"farm",
	.id = @"id",
	.isfamily = @"isfamily",
	.isfriend = @"isfriend",
	.ispublic = @"ispublic",
	.owner = @"owner",
	.secret = @"secret",
	.server = @"server",
	.title = @"title",
};

const struct PhotoRelationships PhotoRelationships = {
};

const struct PhotoFetchedProperties PhotoFetchedProperties = {
};

@implementation PhotoID
@end

@implementation _Photo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Photo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:moc_];
}

- (PhotoID*)objectID {
	return (PhotoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"farmValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"farm"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isfamilyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isfamily"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isfriendValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isfriend"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"ispublicValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"ispublic"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic farm;



- (int16_t)farmValue {
	NSNumber *result = [self farm];
	return [result shortValue];
}

- (void)setFarmValue:(int16_t)value_ {
	[self setFarm:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveFarmValue {
	NSNumber *result = [self primitiveFarm];
	return [result shortValue];
}

- (void)setPrimitiveFarmValue:(int16_t)value_ {
	[self setPrimitiveFarm:[NSNumber numberWithShort:value_]];
}





@dynamic id;






@dynamic isfamily;



- (int16_t)isfamilyValue {
	NSNumber *result = [self isfamily];
	return [result shortValue];
}

- (void)setIsfamilyValue:(int16_t)value_ {
	[self setIsfamily:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIsfamilyValue {
	NSNumber *result = [self primitiveIsfamily];
	return [result shortValue];
}

- (void)setPrimitiveIsfamilyValue:(int16_t)value_ {
	[self setPrimitiveIsfamily:[NSNumber numberWithShort:value_]];
}





@dynamic isfriend;



- (int16_t)isfriendValue {
	NSNumber *result = [self isfriend];
	return [result shortValue];
}

- (void)setIsfriendValue:(int16_t)value_ {
	[self setIsfriend:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIsfriendValue {
	NSNumber *result = [self primitiveIsfriend];
	return [result shortValue];
}

- (void)setPrimitiveIsfriendValue:(int16_t)value_ {
	[self setPrimitiveIsfriend:[NSNumber numberWithShort:value_]];
}





@dynamic ispublic;



- (int16_t)ispublicValue {
	NSNumber *result = [self ispublic];
	return [result shortValue];
}

- (void)setIspublicValue:(int16_t)value_ {
	[self setIspublic:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIspublicValue {
	NSNumber *result = [self primitiveIspublic];
	return [result shortValue];
}

- (void)setPrimitiveIspublicValue:(int16_t)value_ {
	[self setPrimitiveIspublic:[NSNumber numberWithShort:value_]];
}





@dynamic owner;






@dynamic secret;






@dynamic server;






@dynamic title;











@end
