// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Photo.h instead.

#import <CoreData/CoreData.h>


extern const struct PhotoAttributes {
	__unsafe_unretained NSString *farm;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isfamily;
	__unsafe_unretained NSString *isfriend;
	__unsafe_unretained NSString *ispublic;
	__unsafe_unretained NSString *owner;
	__unsafe_unretained NSString *secret;
	__unsafe_unretained NSString *server;
	__unsafe_unretained NSString *title;
} PhotoAttributes;

extern const struct PhotoRelationships {
} PhotoRelationships;

extern const struct PhotoFetchedProperties {
} PhotoFetchedProperties;












@interface PhotoID : NSManagedObjectID {}
@end

@interface _Photo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PhotoID*)objectID;





@property (nonatomic, strong) NSNumber* farm;



@property int16_t farmValue;
- (int16_t)farmValue;
- (void)setFarmValue:(int16_t)value_;

//- (BOOL)validateFarm:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* id;



//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isfamily;



@property int16_t isfamilyValue;
- (int16_t)isfamilyValue;
- (void)setIsfamilyValue:(int16_t)value_;

//- (BOOL)validateIsfamily:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isfriend;



@property int16_t isfriendValue;
- (int16_t)isfriendValue;
- (void)setIsfriendValue:(int16_t)value_;

//- (BOOL)validateIsfriend:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* ispublic;



@property int16_t ispublicValue;
- (int16_t)ispublicValue;
- (void)setIspublicValue:(int16_t)value_;

//- (BOOL)validateIspublic:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* owner;



//- (BOOL)validateOwner:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* secret;



//- (BOOL)validateSecret:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* server;



//- (BOOL)validateServer:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;






@end

@interface _Photo (CoreDataGeneratedAccessors)

@end

@interface _Photo (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFarm;
- (void)setPrimitiveFarm:(NSNumber*)value;

- (int16_t)primitiveFarmValue;
- (void)setPrimitiveFarmValue:(int16_t)value_;




- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSNumber*)primitiveIsfamily;
- (void)setPrimitiveIsfamily:(NSNumber*)value;

- (int16_t)primitiveIsfamilyValue;
- (void)setPrimitiveIsfamilyValue:(int16_t)value_;




- (NSNumber*)primitiveIsfriend;
- (void)setPrimitiveIsfriend:(NSNumber*)value;

- (int16_t)primitiveIsfriendValue;
- (void)setPrimitiveIsfriendValue:(int16_t)value_;




- (NSNumber*)primitiveIspublic;
- (void)setPrimitiveIspublic:(NSNumber*)value;

- (int16_t)primitiveIspublicValue;
- (void)setPrimitiveIspublicValue:(int16_t)value_;




- (NSString*)primitiveOwner;
- (void)setPrimitiveOwner:(NSString*)value;




- (NSString*)primitiveSecret;
- (void)setPrimitiveSecret:(NSString*)value;




- (NSString*)primitiveServer;
- (void)setPrimitiveServer:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




@end
