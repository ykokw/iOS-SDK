#import "AFNetworking.h"

#import "ModeData.h"

@interface MODEAppAPI : NSObject

////////////////////////////////////////////////
// User API
////////////////////////////////////////////////

typedef void(^MODEUserBlock)(MODEUser*, NSError*);

// register yourself to project with your name and phoneNumber,
// You don't need authentication token, because the API is called before authorization.
+ (void)createUser:(int)projectId phoneNumber:(NSString*)phoneNumber name:(NSString*)name
        completion:(MODEUserBlock)completion;

// Look up yourself
+ (void)getUser:(MODEClientAuthentication*)clientAuthentication userId:(int)userId
     completion:(MODEUserBlock)completion;

// You can change only name
+ (void)updateUserInfo:(MODEClientAuthentication*)clientAuthetication userId:(int)userId name:(NSString*)name
            completion:(MODEUserBlock)completion;

// Delete yourself
+ (void)deleteUser:(MODEClientAuthentication*)clientAuthentication userId:(int)userId
        completion:(MODEUserBlock)completion;

////////////////////////////////////////////////
// Home API
////////////////////////////////////////////////

typedef void(^MODEHomeBlock)(MODEHome*, NSError*);

// You will get array of MODEHome
+ (void)getHomes:(MODEClientAuthentication *)clientAuthentication userId:(int)userId
      completion:(void (^)(NSArray*, NSError *))completion;


+ (void)createHome:(MODEClientAuthentication *)clientAuthentication projectId:(int)projectId name:(NSString*)name timezone:(NSString*)timezone
        completion:(MODEHomeBlock)completion;

+ (void)getHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
     completion:(MODEHomeBlock)completion;

+ (void)updateHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId name:(NSString*)name timezone:(NSString*)timezone
        completion:(MODEHomeBlock)completion;

+ (void)deleteHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
        completion:(MODEHomeBlock)completion;

////////////////////////////////////////////////
// Home Members API
////////////////////////////////////////////////

typedef void(^MODEHomeMemberBlock)(MODEHomeMember*, NSError*);

// You will get array of ModeHomeMember
+ (void)getHomeMembers:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
            completion:(void (^)(NSArray*, NSError*))completion;


+ (void)addHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId phoneNumber:(NSString*)phoneNumber
           completion:(MODEHomeMemberBlock)completion;

+ (void)getHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId userId:(int)userId
           completion:(MODEHomeMemberBlock)completion;

+ (void)deleteHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId userId:(int)userId
              completion:(MODEHomeMemberBlock)completion;

////////////////////////////////////////////////
// Smart Module API
////////////////////////////////////////////////

typedef void(^MODESmartModuleBlock)(MODESmartModule*, NSError*);


+ (void)getSmartModuleInfo:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId moduleId:(NSString*)moduleId
                completion:(MODESmartModuleBlock)completion;

+ (void)sendCommandToSmartModule:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId moduleId:(NSString*)moduleId
                          action:(NSString*)action parameters:(NSDictionary*)parameters
                      completion:(MODESmartModuleBlock)completion;


////////////////////////////////////////////////
// Device API
////////////////////////////////////////////////

typedef void(^MODEDeviceBlock)(MODEDevice*, NSError*);

+ (void)getDevices:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
        completion:(void (^)(NSArray*, NSError*))completion;

+ (void)getDeviceInfo:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId
           completion:(MODEDeviceBlock)completion;

+ (void)claimDevice:(MODEClientAuthentication *)clientAuthentication claimCode:(NSString*)claimCode homeId:(int)homeId
         completion:(MODEDeviceBlock)completion;

+ (void)updateDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId name:(NSString*)name
          completion:(MODEDeviceBlock)completion;

+ (void)deleteDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId
          completion:(MODEDeviceBlock)completion;

+ (void)sendCommandToDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId
                     action:(NSString*)action parameters:(NSDictionary*)parameters
                 completion:(MODEDeviceBlock)completion;


////////////////////////////////////////////////
// User Session API
////////////////////////////////////////////////

typedef void(^MODEUserSessionInfoBlock)(MODEUserSessionInfo*, NSError*);

+ (void)getUserSessionInfo:(MODEClientAuthentication *)clientAuthentication
                completion:(MODEUserSessionInfoBlock)completion;

+ (void)terminateUserSessionInfo:(MODEClientAuthentication *)clientAuthentication
                      completion:(MODEUserSessionInfoBlock)completion;


////////////////////////////////////////////////
// Authentication API
////////////////////////////////////////////////

// Maybe we would need to follow the order projectID -> code?
+ (void)initiateAuthenticationWithSMS:(int)projectId phoneNumber:(NSString*)phoneNumber
                           completion:(void(^)(MODESMSMessageReceipt*, NSError*))completion;

+ (void)authenticateWithCode:(int)projectId phoneNumber:(NSString*)phoneNumber appId:(NSString*)appId code:(NSString*)code
                  completion:(void(^)(MODEClientAuthentication*, NSError*))completion;

+ (void)getCurrentAuthenticationState:(MODEClientAuthentication*)clientAuthentication
                           completion:(void(^)(MODEAuthenticationInfo*, NSError*))completion;

@end

