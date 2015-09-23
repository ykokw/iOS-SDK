#import "Mantle.h"
#import "ModeData.h"
#import "ModeLog.h"

// Date formatter transformer block singleton

NSDateFormatter* dateFormatter(BOOL hasMillisec) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = hasMillisec ? @"yyyy-MM-dd'T'HH:mm:ss.SSSZ" : @"yyyy-MM-dd'T'HH:mm:ssZ";
    return dateFormatter;
}

NSValueTransformer* instantiateTimeTransformer(BOOL hasMillisec) {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *str, BOOL *success, NSError **error) {
        return [dateFormatter(hasMillisec) dateFromString:str];
    } reverseBlock:^(NSDate *date, BOOL *success, NSError **error) {
        return [dateFormatter(hasMillisec) stringFromDate:date];
    }];
}

NSValueTransformer* getTimeTransformer(BOOL hasMillisec) {
    static NSValueTransformer* timeTransformer = nil;
    static NSValueTransformer* timeTransformerWithMill = nil;

    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      timeTransformer = instantiateTimeTransformer(FALSE);
                      timeTransformerWithMill = instantiateTimeTransformer(TRUE);
                  });

    return hasMillisec ? timeTransformerWithMill : timeTransformer;
}

#define JSONTransformerFunc(x, y) \
+ (NSValueTransformer*) x##JSONTransformer { \
    return getTimeTransformer(y); \
}

// User Data

@implementation MODEUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"id",
             @"projectId": @"projectId",
             @"creationTime": @"creationTime",
             @"phoneNumber": @"phoneNumber",
             @"name": @"name",
             @"verified": @"verified"
             };
}

JSONTransformerFunc(creationTime, TRUE)

+ (NSValueTransformer*)verifiedTimeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end

// Home Data

@implementation MODEHome

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"homeId": @"id",
             @"projectId": @"projectId",
             @"creationTime": @"creationTime",
             @"name": @"name",
             @"timezone": @"timezone"
             };
}

JSONTransformerFunc(creationTime, TRUE)

@end



// Home Member Data

@implementation MODEHomeMember

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"userId",
             @"creationTime": @"creationTime",
             @"name": @"name",
             @"phoneNumber": @"phoneNumber",
             @"verified": @"verified"
             };
}

JSONTransformerFunc(creationTime, TRUE)

+ (NSValueTransformer*)verifiedTimeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end


// Smart Module Data

@implementation MODESmartModule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"smartModuleId": @"id",
             @"creationTime": @"creationTime",
             @"moduleDescription": @"description",
             };
}

JSONTransformerFunc(creationTime, TRUE)

@end

// Device Data

@implementation MODEDevice

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"deviceId": @"id",
             @"projectId": @"projectId",
             @"name": @"name",
             @"tag": @"tag",
             @"deviceClass": @"deviceClass",
             @"homeId": @"homeId",
             @"claimTime": @"claimTime",
             @"claimExpirationTime": @"claimExpirationTime",
             @"lastConnectTime": @"lastConnectTime",
             @"lastDisconnectTime": @"lastDisconnectTime",
             @"lastCommandTime": @"lastCommandTime",
             @"lastEventTime": @"lastEventTime",
             @"apiKey": @"apiKey",
             };
}

JSONTransformerFunc(claimTime, FALSE)
JSONTransformerFunc(claimExpirationTime, FALSE)

JSONTransformerFunc(lastConnectTime, TRUE)
JSONTransformerFunc(lastDisconnectTime, TRUE)

JSONTransformerFunc(lastCommandTime, TRUE)
JSONTransformerFunc(lastEventTime, TRUE)


@end

// User Session Info data

@implementation MODEUserSessionInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"userId",
             @"appId": @"appId",
             @"projectId": @"projectId",
             @"creationTime": @"creationTime"
             };
}

JSONTransformerFunc(creationTime, TRUE)

@end


// Authentication Data

@implementation MODESMSMessageReceipt

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"recipient": @"recipient"
    };
}

@end

@implementation MODEClientAuthentication

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"token": @"token",
             @"userId": @"userId"
    };
}

@end

@implementation MODEAuthenticationInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"type":@"type",
             @"userId":@"userId",
             @"appId":@"appId",
             @"deviceId":@"deviceId",
             @"moduleId":@"moduleId",
             @"projectId":@"projectId"
    };
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                    @"user": @(MODEAuthenticationInfoTypeUser),
                                    @"device": @(MODEAuthenticationInfoTypeDevice),
                                    @"smart module": @(MODEAuthenticationInfoTypeSmartModule),
                                    @"nobody": @(MODEAuthenticationInfoTypeNobody)
                                    }];
}

@end

@implementation MODEDeviceEvent

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"eventType":@"eventType",
             @"eventData":@"eventData",
             @"timestamp":@"timestamp",
             @"homeId":@"homeId",
             @"originDeviceId":@"originDeviceId",
             @"originModuleId":@"originModuleId"
             };
}

JSONTransformerFunc(timestamp, TRUE)

@end

