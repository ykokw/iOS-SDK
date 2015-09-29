#import <Mantle/Mantle.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////
// See mroe detail at http://dev.tinkermode.com/api/model_reference.html to get more detail schema
//////////////////////////////////////////////////////////////////////////////////////////////////////

// User Data

@interface MODEUser : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign)int userId;
@property (nonatomic, assign)int projectId;
@property (nonatomic, copy)NSDate* creationTime;
@property (nonatomic, copy)NSString* phoneNumber;
@property (nonatomic, copy)NSString* name;
@property (nonatomic, assign)BOOL verified;

@end

// Home Data

@interface MODEHome : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign)int homeId;
@property (nonatomic, assign)int projectId;
@property (nonatomic, copy)NSDate* creationTime;
@property (nonatomic, copy)NSString* name;
@property (nonatomic, copy)NSString* timezone;

@end

// Home Member Data

@interface MODEHomeMember : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign)int userId;
@property (nonatomic, copy)NSDate* creationTime;
@property (nonatomic, copy)NSString* name;
@property (nonatomic, copy)NSString* phoneNumber;
@property (nonatomic, assign)BOOL verified;

@end

// Smart Module Data

@interface MODESmartModule : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy)NSString* smartModuleId;
@property (nonatomic, copy)NSDate* creationTime;
@property (nonatomic, copy)NSString* moduleDescription;

@end

// Device Data

@interface MODEDevice : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign)int deviceId;
@property (nonatomic, assign)int projectId;
@property (nonatomic, copy)NSString* name;
@property (nonatomic, copy)NSString* tag;
@property (nonatomic, copy)NSString* deviceClass;
@property (nonatomic, assign)int homeId;
@property (nonatomic, copy)NSDate* claimTime;
@property (nonatomic, copy)NSDate* claimExpirationTime;
@property (nonatomic, copy)NSDate* lastConnectTime;
@property (nonatomic, copy)NSDate* lastDisconnectTime;
@property (nonatomic, copy)NSDate* lastCommandTime;
@property (nonatomic, copy)NSDate* lastEventTime;
@property (nonatomic, copy)NSString* apiKey;

@end

// User Session Info Data

@interface MODEUserSessionInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign)int userId;
@property (nonatomic, copy)NSString* appId;
@property (nonatomic, assign)int projectId;
@property (nonatomic, copy)NSDate* creationTime;

@end

// Autheintication Data
@interface MODESMSMessageReceipt : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString* recipient;

@end

@interface MODEClientAuthentication : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString* token;
@property (nonatomic) int userId;

@end

typedef enum : NSUInteger {
    MODEAuthenticationInfoTypeUser = 1,
    MODEAuthenticationInfoTypeDevice,
    MODEAuthenticationInfoTypeSmartModule,
    MODEAuthenticationInfoTypeNobody
} MODEAuthenticationInfoType;

@interface MODEAuthenticationInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) MODEAuthenticationInfoType type;
@property (nonatomic, assign) int userId;
@property (nonatomic, copy) NSString* appId;
@property (nonatomic, assign) int deviceId;
@property (nonatomic, copy) NSString* moduleId;
@property (nonatomic, assign) int projectId;

@end

// Device Event

@interface MODEDeviceEvent : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy)NSString* eventType;
@property (nonatomic, copy)NSDictionary* eventData;
@property (nonatomic, copy)NSDate* timestamp;
@property (nonatomic, assign)int homeId;
@property (nonatomic, assign)int originDeviceId;
@property (nonatomic, copy)NSString* originModuleId;

@end