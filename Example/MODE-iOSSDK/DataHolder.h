#import "MODEData.h"
#import "Mantle.h"

@interface DataHolderMembers : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) NSString* phoneNumber;
@property (assign, nonatomic) int homeId;

@end


/**
 * This is a very simple persistent class.
 * In your real app, you would need to use Core Data to cache locally.
 */
@interface DataHolder : NSObject

+ (DataHolder *)sharedInstance;

@property (assign, nonatomic) int projectId;
@property (strong, nonatomic) NSString* appId;

@property (strong, nonatomic) MODEClientAuthentication* clientAuth;
@property (strong, nonatomic) DataHolderMembers* members;

-(void) saveData;
-(void) loadData;

@end
