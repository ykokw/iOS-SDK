#import "ModeData.h"

@interface MODEAppAPI : NSObject

/**
 *  All API functions return NSURLSessionDataTask to control the session you want.
 *  The task is queued so you won't have to worry about the object life.
 *
 *  You need to check the NSError object in each callback block to see if it was a success or not.
 *  If the error returned from MODE cloud, you can get the following information in NSError.
 *
 *  @param domain    If it's NSURLErrorDomain, it means MODE could returns HTTP errors.
 *  @param code      Shows HTTP status code. See more detail at http://dev.tinkermode.com/api/api_reference.html
 *  @param userInfo  Has more detailed information on why it failed. It is NSDictionary parsed from JSON string.
 */

+ (void)setAPIHost:(NSString*)host;
+ (NSString*)getAPIHost;

////////////////////////////////////////////////
// User API
////////////////////////////////////////////////

typedef void(^MODEUserBlock)(MODEUser*, NSError*);

/**
 *  Register a new user. An SMS code will be sent to the user (i.e. phone number owner) in order to verify the account.
 *
 *  @param projectId    ID of project which you want to register a new user.
 *  @param phoneNumber  New phone number to be registered in the database.
 *  @param name         Name you want to assign.
 *  @param completion   Callback block: MODEUser is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)createUser:(int)projectId phoneNumber:(NSString*)phoneNumber name:(NSString*)name
        completion:(MODEUserBlock)completion;

+ (NSURLSessionDataTask*)createUser:(int)projectId email:(NSString*)email password:(NSString*)password name:(NSString*)name
                         completion:(MODEUserBlock)completion;

/**
 *  Returns the account information of the user with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN of the user you want information for.
 *  @param userId               ID of user associated with USER_TOKEN.
 *  @param completion           Callback block: MODEUser is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getUser:(MODEClientAuthentication*)clientAuthentication userId:(int)userId
     completion:(MODEUserBlock)completion;

/**
 *  Only you can make changes to the name of the user with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN of the user you want to update.
 *  @param userId               ID of user associated with USER_TOKEN.
 *  @param name                 Updated name.
 *  @param completion           Callback block: MODEUser is nil.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)updateUserInfo:(MODEClientAuthentication*)clientAuthetication userId:(int)userId name:(NSString*)name
            completion:(MODEUserBlock)completion;

/**
 *  Only you can delete users with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN of the user you want to delete.
 *  @param userId               ID of the user associated with USER_TOKEN and whom you want to delete.
 *  @param completion           Callback block: MODEUser is nil.
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
 *  @param completion           Callback block: NSArray is valid as an array of MODEHome if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getHomes:(MODEClientAuthentication *)clientAuthentication userId:(int)userId
      completion:(void (^)(NSArray*, NSError *))completion;

/**
 *  Create a new home for the user who is making this request.
 *
 *  @param clientAuthentication USER_TOKEN.
 *  @param name                 New name of home.
 *  @param timezone             Specify a TZ from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones (e.g. "America/Los_Angeles").
 *  @param completion           Callback block: MODEHome is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)createHome:(MODEClientAuthentication *)clientAuthentication name:(NSString*)name timezone:(NSString*)timezone
        completion:(MODEHomeBlock)completion;

/**
 *  Return the home with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               ID of home with the info you want. The home must belong to a user.
 *  @param completion           Callback block: MODEHome is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
     completion:(MODEHomeBlock)completion;

/**
 *  Update the home with the specified ID. You can change 
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               ID of home you want to delete. The home must belong to the user.
 *  @param name                 New name you want to update. If nil, not updated.
 *  @param timezone             New TZ from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones (e.g. "America/Los_Angeles"), if nil, not updated.
 *  @param completion           Callback block: MODEHome is nil.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)updateHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId name:(NSString*)name timezone:(NSString*)timezone
        completion:(MODEHomeBlock)completion;

/**
 *  Delete the home with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               homeId you want to delete. The home must belong to the user.
 *  @param completion           Callback block: MODEHome is nil.
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
 *  @param homeId               ID of the home you want a list of members from.
 *  @param completion           Callback block: NSArray is valid as an array of MODEHomeMember if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getHomeMembers:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
            completion:(void (^)(NSArray*, NSError*))completion;

/**
 *  Add a member to the home. The member's phone number must be specified. If the member is not an existing user, the "verified" field of the returned member object will be false.
 *  The app will send an SMS invite to the new invited member.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               ID of home you want to add a member at.
 *  @param phoneNumber          Phone number of the user you want to add as a member.
 *  @param completion           Callback block: MODEHomeMember is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)addHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId phoneNumber:(NSString*)phoneNumber
           completion:(MODEHomeMemberBlock)completion;


/**
 *  Add a member to the home. The member's email address must be specified. If the member is not an existing user, the "verified" field of the returned member object will be false. An email notification will be sent to the invited member.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               ID of home you want to add a member at.
 *  @param phoneNumber          Phone number of the user you want to add as a member.
 *  @param completion           Callback block: MODEHomeMember is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)addHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId email:(NSString*)email
                            completion:(MODEHomeMemberBlock)completion;

/**
 *  Get the home member with the specified user ID.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               ID of home the specified member belongs to.
 *  @param userId               ID of user you want to get the info.
 *  @param completion           Callback block: MODEHomeMember is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId userId:(int)userId
           completion:(MODEHomeMemberBlock)completion;

/**
 *  Delete the specified user as a member of the home.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               ID of home the specified member belongs to.
 *  @param userId               ID of user you want to delete from the home.
 *  @param completion           Callback block: MODEHomeMember is valid if successful.
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
 *  @param homeId               ID of home Smart Module belongs to.
 *  @param moduleId             Smart Module Id.
 *  @param completion           Callback block: MODESmartModule is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getSmartModuleInfo:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId moduleId:(NSString*)moduleId
                completion:(MODESmartModuleBlock)completion;

/**
 *  Issue a command to the specified Smart Module.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               ID of home Smart Module belongs to.
 *  @param moduleId             Smart Module Id to which the command was issued.
 *  @param action               Command action name.
 *  @param eventParameters      Event parameters as dictionary. It will be sent as JSON.
 *  @param completion           Callback block: MODESmartModule is nil.
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
 *  @param homeId               ID of home which contains the devices.
 *  @param completion           Callback block: NSArray is valid as an array of MODEDevice if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getDevices:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId
        completion:(void (^)(NSArray*, NSError*))completion;

/**
 *  Return the device with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN.
 *  @param deviceId             ID of the device with the information you want.
 *  @param completion           Callback block: MODEDevice is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getDeviceInfo:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId
           completion:(MODEDeviceBlock)completion;

/**
 *  Claim a device and register it to the specified home with claim code. This API is valid only if the device is pre-provisioned.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param claimCode            claim code for the device.
 *  @param homeId               ID of the home that the device is added with a successful claim.
 *  @param completion           Callback block: MODEDevice is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)addDeviceToHomeWithClaimCode:(MODEClientAuthentication *)clientAuthentication claimCode:(NSString*)claimCode homeId:(int)homeId
         completion:(MODEDeviceBlock)completion;

/**
 *  Add a device to the home on-demand. This API is valid only if on-demand device provisioning is enabled.
 *
 *  @param clientAuthentication USER_TOKEN belonging to the home.
 *  @param homeId               ID of the home that the device is added with a successful claim.
 *  @param deviceClass          device class for which the device is made
 *  @param deviceTag            device tag with which the device is made, optional
 *  @param deviceName           device name with which the device is made, optional
 *  @param completion           Callback block: MODEDevice is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)addDeviceToHomeOnDemand:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId deviceClass:(NSString*)deviceClass
                                       deviceTag:(NSString*)deviceTag deviceName:(NSString*)deviceName completion:(MODEDeviceBlock)completion;

/**
 *  Update the device with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN
 *  @param deviceId             ID of device with the name you want to update.
 *  @param name                 New name you want to update.
 *  @param completion           Callback block: MODEDevice is nil.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)updateDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId name:(NSString*)name
          completion:(MODEDeviceBlock)completion;

/**
 *  Delete the device with the specified ID.
 *
 *  @param clientAuthentication USER_TOKEN
 *  @param deviceId             ID of device you want to delete.
 *  @param completion           Callback block: MODEDevice is nil.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)deleteDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId
          completion:(MODEDeviceBlock)completion;

/**
 *  Issue a command to the specified device.
 *
 *  @param clientAuthentication USER_TOKEN
 *  @param deviceId             ID of device you want to issue a command to.
 *  @param action               Event action name.
 *  @param parameters           Event parameters as dictionary. It will be sent as JSON.
 *  @param completion           Callback block: MODEDevice is nil.
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
 *  @param clientAuthentication USER_TOKEN for the session with information you want.
 *  @param completion           Callback block: MODEUserSessionInfo is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)getUserSessionInfo:(MODEClientAuthentication *)clientAuthentication
                completion:(MODEUserSessionInfoBlock)completion;

/**
 *  Terminate a user session. The associated auth token will also be invalidated.
 *
 *  @param clientAuthentication USER_TOKEN of the session you want to terminate.
 *  @param completion           Callback block: MODEUserSessionInfo is nil.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)terminateUserSessionInfo:(MODEClientAuthentication *)clientAuthentication
                      completion:(MODEUserSessionInfoBlock)completion;


////////////////////////////////////////////////
// Authentication API
////////////////////////////////////////////////

/**
 *  Initiate the authentication process by triggering an SMS text to a user. The text contains an auth code for the user to authenticate their account.
 *
 *  @param projectId   ID of project to which the user belongs.
 *  @param phoneNumber Phone number of the user. The phoneNumber must be registered viar createUser API.
 *  @param completion  Callback block: MODESMSMessageReceipt is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)initiateAuthenticationWithSMS:(int)projectId phoneNumber:(NSString*)phoneNumber
                           completion:(void(^)(MODESMSMessageReceipt*, NSError*))completion;

/**
 *  Exchange the auth code sent to user via SMS for an authentication token.
 *
 *  @param projectId   ID of project to which the user belongs.
 *  @param phoneNumber Phone number of the user.
 *  @param appId       ID of the app accessing the API.
 *  @param code        Auth code sent to user via SMS.
 *  @param completion  Callback block: MODEClientAuthentication is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)authenticateWithCode:(int)projectId phoneNumber:(NSString*)phoneNumber appId:(NSString*)appId code:(NSString*)code
                  completion:(void(^)(MODEClientAuthentication*, NSError*))completion;

/**
 *  Test the authentication token used in the HTTP Authorization header of the API request.
 *
 *  @param clientAuthentication USER_TOKEN you want to test.
 *  @param completion           Callback block: MODEAuthenticationInfo is valid if successful.
 *
 *  @return 
 */
+ (NSURLSessionDataTask*)getCurrentAuthenticationState:(MODEClientAuthentication*)clientAuthentication
                           completion:(void(^)(MODEAuthenticationInfo*, NSError*))completion;

/**
 *  Verify a user account by an email verification token. This API call is only allowed for projects with email address-based user accounts.
 *
 *  @param token      Verification token emailed to user.
 *  @param completion Callback block: non nil NSError is passed if unsuccessful
 *
 *  @return
 */
+ (NSURLSessionDataTask*)verifyUserEmailAddress:(NSString*)token completion:(void(^)(NSError*))completion;

/**
 *  Initiate the account verification process by sending out a verification email. For users who have lost the original message. This API call is only allowed for projects with email address-based user accounts.
 *
 *  @param projectId  ID of project to which the user belongs.
 *  @param email      Email address of user.
 *  @param completion Callback block: non nil NSError is passed if unsuccessful
 *
 *  @return
 */
+ (NSURLSessionDataTask*)initiateUserEmailVerification:(int)projectId email:(NSString*)email completion:(void(^)(NSError*))completion;

/**
 *  Initiate the password reset process by sending out an email containing a password reset token. For users who have forgotten their passwords. This API call is only allowed for projects with email address-based user accounts.
 *
 *  @param projectId  ID of project to which the user belongs.
 *  @param email      Email address of user.
 *  @param completion Callback block: non nil NSError is passed if unsuccessful
 *
 *  @return
 */
+ (NSURLSessionDataTask*)initiateUserPasswordReset:(int)projectId email:(NSString*)email completion:(void(^)(NSError*))completion;

/**
 *  Authenticate a user by password and return an API key. The request body must contain the email, appId and password parameters.
 *
 *  @param projectId  ID of project to which the user belongs.
 *  @param email      Email address of user.
 *  @param password   Password of user to be authenticated.
 *  @param appId      ID of the app being used to access the API.
 *  @param completion  Callback block: MODEClientAuthentication is valid if successful.
 *
 *  @return
 */
+ (NSURLSessionDataTask*)authenticateWithEmail:(int)projectId email:(NSString*)email  password:(NSString*)password appId:(NSString*)appId
                                   completion:(void(^)(MODEClientAuthentication*, NSError*))completion;


@end
