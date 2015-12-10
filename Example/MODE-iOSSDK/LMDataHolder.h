#import "Mantle.h"
#import "MODEData.h"

@interface LMDataHolderMembers : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (assign, nonatomic) int homeId;

@end


/**
  *This is a very simple persistent class.
  *In your real app, you would need to use Core Data to cache locally.
 */
@interface LMDataHolder : NSObject

+ (LMDataHolder *)sharedInstance;

@property (assign, nonatomic) int projectId;
@property (assign, nonatomic) int oldProjectId;
@property (assign, nonatomic) BOOL isEmailLogin;
@property (assign, nonatomic) BOOL oldIsEmailLogin;
@property (strong, nonatomic) NSString *appId;

@property (strong, nonatomic) MODEClientAuthentication *clientAuth;
@property (strong, nonatomic) LMDataHolderMembers *members;

- (void)saveData;
- (void)loadData;

- (void)saveProjectId;
- (void)saveOldProjectId;
- (void)loadProjectId;


@end
