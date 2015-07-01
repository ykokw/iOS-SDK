#import "ModeData.h"

@interface MODEAppAPI : NSObject

/**
 *  All API funtions return NSURLSessionDataTask to controll the session if you want.
 *  The task is queued so you don't have to care the object life.
 *
 *  You need to check the NSError object in each callback block if success or not.
 *  If the error returned from MODE cloud, you can get the following information in NSError.
 *
 *  @param domain    If it's NSURLErrorDomain, it means MODE clound returns HTTP errors.
 *  @param code      Shows HTTP status code. See more detail at http://dev.tinkermode.com/api/api_reference.html
 *  @param userInfo  Has more detail information why it failed. It is NSDictionary parsed from JSON string.
 */

////////////////////////////////////////////////
// User API
////////////////////////////////////////////////

typedef void(^MODEUserBlock)(MODEUser*, NSError*);

/**
 *  Register a new user. The user which is the phoneNumber owner will get SMS code to be veified.
 *
 *  @param projectId    projectId where you want to register a new user.
 *  @param phoneNumber  phoneNumber you want to register and not registered yet in the project.
 *  @param name         Name you want to assign.
 *  @param completion   Can get a valid MODEUser object and NSError is nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)createUser:(int)projectId phoneNumber:(NSString*)phoneNumber name:(NSString*)name
        completion:(MODEUserBlock)completion;

/**
 *  Return the user with the specified ID, you can only get your own information.
 *
 *  @param clientAuthentication USER_TOKEN you want to get the info.
 *  @param userId               userId associated to USER_TOKEN.
 *  @param completion           Can get a valid MODEUser object and NSError is nil when USER_TOKEN and userId are valid.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getUser:(MODEClientAuthentication*)clientAuthentication userId:(int)userId
     completion:(MODEUserBlock)completion;

/**
 *  Update the user with the specified ID, you can change your name only by youself.
 *
 *  @param clientAuthentication USER_TOKEN you want to update.
 *  @param userId               userId associated to USER_TOKEN.
 *  @param name                 New name you want to update.
 *  @param completion           MODEUser is always nil and NSError is nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)updateUserInfo:(MODEClientAuthentication*)clientAuthetication userId:(int)userId name:(NSString*)name
            completion:(MODEUserBlock)completion;

/**
 *  Delete the user with the specified ID, you can delete only youself.
 *
 *  @param clientAuthentication USER_TOKEN you want to delete.
 *  @param userId               userId associated to USER_TOKEN and want to delete.
 *  @param completion           MODEUser is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)deleteUser:(MODEClientAuthentication*)clientAuthentication userId:(int)userId
        completion:(MODEUserBlock)completion;

////////////////////////////////////////////////
// Home API
////////////////////////////////////////////////

typedef void(^MODEHomeBlock)(MODEHome*, NSError*);

/**
 *  Get a list of homes a user belongs to.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the homes.
 *  @param userId               userID belonging to the homes.
 *  @param completion           Can get a valid NSArray of MODEHome when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getHomes:(MODEClientAuthentication *)clientAuthentication userId:(int)userId
      completion:(void (^)(NSArray*, NSError *))completion;

/**
 *  Ceate a new home for the user who is making this request.
 *
 *  @param clientAuthentication USER_TOKEN
 *  @param name                 Whatever name you want to set.
 *  @param timezone             Specify a TZ from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones (e.g. "America/Los_Angeles").
 *  @param completion           Can get a valid MODEHome object and NSError is nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)createHome:(MODEClientAuthentication *)clientAuthentication name:(NSString*)name timezone:(NSString*)timezone
        completion:(MODEHomeBlock)completion;

/**
 *  Return the home with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId you want to get the info. The home has to be belonged to by the user.
 *  @param completion           Can get a valid MODEHome object when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
     completion:(MODEHomeBlock)completion;

/**
 *  Update the home with the specified ID. You can change 
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId you want to delete. The home has to be belonged to by the user.
 *  @param name                 New name you want to update. If nil, not updated.
 *  @param timezone             New TZ from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones (e.g. "America/Los_Angeles"), if nil, not updated.
 *  @param completion           MODEHome is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)updateHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId name:(NSString*)name timezone:(NSString*)timezone
        completion:(MODEHomeBlock)completion;

/**
 *  Delete the home with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId you want to delete. The home has to be belonged to by the user.
 *  @param completion           MODEHome is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)deleteHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
        completion:(MODEHomeBlock)completion;

////////////////////////////////////////////////
// Home Members API
////////////////////////////////////////////////

typedef void(^MODEHomeMemberBlock)(MODEHomeMember*, NSError*);

/**
 *  Get all members belonging to the specified home.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId you want get the all members belonging to.
 *  @param completion           Can get a valid NSArray of MODEHomeMember if success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getHomeMembers:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
            completion:(void (^)(NSArray*, NSError*))completion;

/**
 *  Add a member to the home. The member's phone number must be specified. If the member is not an existing user, the "verified" field of the returned member object will be false.
 *  It is the app's responsibility to send an SMS invite to the invited member.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeID you want to add a member at.
 *  @param phoneNumber          phoneNumber you want to add as a member.
 *  @param completion           Can get the added MODEHomeMember when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)addHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId phoneNumber:(NSString*)phoneNumber
           completion:(MODEHomeMemberBlock)completion;

/**
 *  Get the home member with the specified user ID.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId the specified member belongs to.
 *  @param userId               userId you want to get the info.
 *  @param completion           Can get a valid MODEHomeMmber when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId userId:(int)userId
           completion:(MODEHomeMemberBlock)completion;

/**
 *  Delete the specified user as a member of the home.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId the specified member belongs to.
 *  @param userId               userId you want to delete from the home.
 *  @param completion           MODEHomeMember is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)deleteHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId userId:(int)userId
              completion:(MODEHomeMemberBlock)completion;

////////////////////////////////////////////////
// Smart Module API
////////////////////////////////////////////////

typedef void(^MODESmartModuleBlock)(MODESmartModule*, NSError*);

/**
 *  Get the list of Smart Modules available for the home.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId Smart Module belongs to.
 *  @param moduleId             Smart Module Id.
 *  @param completion           Can get a valid MODESmartModule object when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getSmartModuleInfo:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId moduleId:(NSString*)moduleId
                completion:(MODESmartModuleBlock)completion;

/**
 *  Issue a command to the specified Smart Module.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId Smart Module belongs to.
 *  @param moduleId             Smart Module Id to which the command issued.
 *  @param action               Command action name.
 *  @param eventParameters      Event parameters as dictionary. It will be sent as JSON.
 *  @param completion           MODEHomeMember is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)sendCommandToSmartModule:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId moduleId:(NSString*)moduleId
                          action:(NSString*)action parameters:(NSDictionary*)parameters
                      completion:(MODESmartModuleBlock)completion;


////////////////////////////////////////////////
// Device API
////////////////////////////////////////////////

typedef void(^MODEDeviceBlock)(MODEDevice*, NSError*);

/**
 *  Get a list of devices attached to the home.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId which the devices is beloging to.
 *  @param completion           Can get a valid NSArray of MODEDevice if success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getDevices:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
        completion:(void (^)(NSArray*, NSError*))completion;

/**
 *  Return the device with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN.
 *  @param deviceId             deviceId you want get the info.
 *  @param completion           Can get a valid MODEDevice object if success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getDeviceInfo:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId
           completion:(MODEDeviceBlock)completion;

/**
 *  Claim a device and register it to the specified home.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param claimCode            claim code for the device.
 *  @param homeId               Id of the home that the device is added with a successful claim.
 *  @param completion           Can get a valid ModeDevice object if success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)claimDevice:(MODEClientAuthentication *)clientAuthentication claimCode:(NSString*)claimCode homeId:(int)homeId
         completion:(MODEDeviceBlock)completion;


/**
 *  Update the device with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN
 *  @param deviceId             deviceId you want to update the name.
 *  @param name                 New name you want to update.
 *  @param completion           MODEDevice is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)updateDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId name:(NSString*)name
          completion:(MODEDeviceBlock)completion;

/**
 *  Update the device with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN
 *  @param deviceId             deviceId you want to delete.
 *  @param completion           MODEDevice is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)deleteDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId
          completion:(MODEDeviceBlock)completion;

/**
 *  Issue a command to the specified device.
 *
 *  @param clientAuthentication USER_TOKEN
 *  @param deviceId             deviceId you want to issue a command to.
 *  @param action               Event action name.
 *  @param parameters           Event parameters as dictionary. It will be sent as JSON.
 *  @param completion           MODEDevice is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)sendCommandToDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId
                     action:(NSString*)action parameters:(NSDictionary*)parameters
                 completion:(MODEDeviceBlock)completion;

////////////////////////////////////////////////
// User Session API
////////////////////////////////////////////////

typedef void(^MODEUserSessionInfoBlock)(MODEUserSessionInfo*, NSError*);


/**
 *  Get info about the current user session.
 *
 *  @param clientAuthentication USER_TOKEN you want to get the info.
 *  @param completion           Can get a valid MODEUserSessionInfo object when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getUserSessionInfo:(MODEClientAuthentication *)clientAuthentication
                completion:(MODEUserSessionInfoBlock)completion;

/**
 *  Terminate a user session. The associated auth token will also be invalidated.
 *
 *  @param clientAuthentication USER_TOKEN you want to terminate.
 *  @param completion           MODEUserSessionInfo is always nil and NSError will be nil when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)terminateUserSessionInfo:(MODEClientAuthentication *)clientAuthentication
                      completion:(MODEUserSessionInfoBlock)completion;


////////////////////////////////////////////////
// Authentication API
////////////////////////////////////////////////

/**
 *  Initiate the authentication process by triggering an SMS text to a user. The text contains an auth code for the user to exchange for an authentication token.
 *
 *  @param projectId   ID of project to which the user belongs.
 *  @param phoneNumber Phone number of user to be authenticated, the phoneNumber has to be registered with createUser API.
 *  @param completion  Can get a valid MODESMSMessageReceipt object when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)initiateAuthenticationWithSMS:(int)projectId phoneNumber:(NSString*)phoneNumber
                           completion:(void(^)(MODESMSMessageReceipt*, NSError*))completion;

/**
 *  Exchange the auth code sent to user via SMS for an authentication token.
 *
 *  @param projectId   ID of project to which the user belongs.
 *  @param phoneNumber Phone number of user to be authenticated.
 *  @param appId       ID of the app being used to access the API.
 *  @param code        Auth code sent to user via SMS.
 *  @param completion  Can get a valid MODEClientAuthentication object when success.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)authenticateWithCode:(int)projectId phoneNumber:(NSString*)phoneNumber appId:(NSString*)appId code:(NSString*)code
                  completion:(void(^)(MODEClientAuthentication*, NSError*))completion;

/**
 *  Test the authentication token used in the HTTP Authorization header of the API request.
 *
 *  @param clientAuthentication USER_TOKEN you want to test.
 *  @param completion           Can get MODEAuthenticationInfo when USER_TOKEN is valid and success to call.
 *
 *  @return 
 */
+ (NSURLSessionDataTask*)getCurrentAuthenticationState:(MODEClientAuthentication*)clientAuthentication
                           completion:(void(^)(MODEAuthenticationInfo*, NSError*))completion;

@end
