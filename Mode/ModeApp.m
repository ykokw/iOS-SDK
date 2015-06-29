//
//  ModeApp.m
//  Test
//
//  Created by TakanoNaoki on 6/10/15.
//  Copyright (c) 2015 TakanoNaoki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModeApp.h"
#import "ModeData.h"

#import "AFNetworking.h"

// So far test mode for my test server...
//NSString *const ModeURL = @"https://api.tinkermode.com";
NSString *const ModeURL = @"http://akagi.local:7002";

NSString* getModeURL(NSString* path) {
    return [ModeURL stringByAppendingString:path];
}

@implementation MODEAppAPI

AFHTTPRequestOperationManager* getJSONRequesterWithAuth(MODEClientAuthentication* auth) {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager.requestSerializer setValue:[@"ModeCloud " stringByAppendingString:auth.token]forHTTPHeaderField:@"Authorization"];

    return manager;
}

typedef void (^completionBlock)(id, NSError*);
typedef void (^completionBlockForArray)(NSArray*, NSError*);
typedef id (^targetBlock)(id resposeObject, Class targetClass, NSError**);

void callHTTPRequestSub(AFHTTPRequestOperationManager* manager, NSString* selectorString, NSString* path, NSDictionary* parameters, Class targetClasss, completionBlock completion, targetBlock target) {

    SEL message = NSSelectorFromString([NSString stringWithFormat:@"%@:parameters:success:failure:", selectorString ]);

    NSMethodSignature *signature  = [manager methodSignatureForSelector:message];
    NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];

    NSString* _path = getModeURL(path);

    void(^successBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSArray* array = target(responseObject, targetClasss, &err);
        completion(array, err);
    };

    void(^failureBlock)(AFHTTPRequestOperation *, NSError*) = ^(AFHTTPRequestOperation *operation, NSError* err){
        completion(nil, err);
    };

    [invocation setTarget:manager];
    [invocation setSelector:message];
    [invocation setArgument:&_path atIndex:2];
    [invocation setArgument:&parameters atIndex:3];
    [invocation setArgument:&successBlock  atIndex:4];
    [invocation setArgument:&failureBlock  atIndex:5];
    [invocation invoke];
}

void callHTTPRequest(AFHTTPRequestOperationManager* manager, NSString* selectorString, NSString* path, NSDictionary* parameters, Class targetClasss, completionBlock completion) {

    callHTTPRequestSub(manager, selectorString, path, parameters, targetClasss, completion,
                       ^id(id responseObject, Class targetClass, NSError** err){
                           return [MTLJSONAdapter modelOfClass:targetClasss fromJSONDictionary:(NSDictionary*)responseObject error:err];
                       });
}

void callHTTPRequestForArray(AFHTTPRequestOperationManager* manager, NSString* selectorString, NSString* path, NSDictionary* parameters, Class targetClasss, completionBlockForArray completion) {

    callHTTPRequestSub(manager, selectorString, path, parameters, targetClasss, completion,
                       ^id(id responseObject, Class targetClass, NSError** err){
                           NSMutableArray* array = [[NSMutableArray alloc] init];
                           *err = nil;
                           for (id responseItem in (NSArray*)responseObject) {
                               id obj = [MTLJSONAdapter modelOfClass:targetClasss fromJSONDictionary:responseItem error:err];
                               if (*err) {
                                   return nil;
                               }
                               [array addObject:obj];
                           }
                           return array;
                       });
}

// User API


+ (void)createUser:(int)projectId phoneNumber:(NSString *)phoneNumber name:(NSString *)name completion:(void(^)(MODEUser*, NSError*))completion
{
    NSDictionary *parameters =@{
                                @"projectId": [NSNumber numberWithInt:projectId],
                                @"phoneNumber": phoneNumber,
                                @"name": name
                                };
    // This doesn't need Authrizatin header.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    callHTTPRequest(manager, @"POST", @"/users", parameters, MODEUser.class, completion);
}

+ (void)getUser:(MODEClientAuthentication *)clientAuthentication userId:(int)userId completion:(void (^)(MODEUser *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"GET", [NSString stringWithFormat:@"/users/%d", userId], nil, MODEUser.class, completion);
}

+ (void)deleteUser:(MODEClientAuthentication *)clientAuthentication userId:(int)userId completion:(void (^)(MODEUser *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"DELETE", [NSString stringWithFormat:@"/users/%d", userId], nil, MODEUser.class, completion);
}


+(void)updateUserInfo:(MODEClientAuthentication *)clientAuthetication userId:(int)userId name:(NSString *)name completion:(void (^)(MODEUser *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthetication);
    callHTTPRequest(manager,@"PATCH", [NSString stringWithFormat:@"/users/%d", userId], @{@"name": name}, MODEUser.class, completion);
}


// Home API
+(void)getHomes:(MODEClientAuthentication *)clientAuthentication userId:(int)userId completion:(void (^)(NSArray *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequestForArray(manager,@"GET", @"/homes",
                    @{@"userId": [NSNumber numberWithInt:userId]}, MODEHome.class, completion);
}


+ (void)createHome:(MODEClientAuthentication *)clientAuthentication projectId:(int)projectId name:(NSString*)name timezone:(NSString*)timezone completion:(void (^)(MODEHome *, NSError *))completion
{
    NSDictionary *parameters =@{
                                @"projectId": [NSNumber numberWithInt:projectId],
                                @"name": name,
                                @"timezone": timezone
                                };

    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager, @"POST", @"/homes", parameters, MODEHome.class, completion);
}

+(void)getHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId completion:(void (^)(MODEHome *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager, @"GET", [NSString stringWithFormat:@"/homes/%d", homeId], nil, MODEHome.class, completion);
}

+(void)updateHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId name:(NSString *)name timezone:(NSString *)timezone completion:(void (^)(MODEHome *, NSError *))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (name) {
        parameters[@"name"] = name;
    }

    if (timezone) {
        parameters[@"timezone"] = timezone;
    }

    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager, @"PATCH", [NSString stringWithFormat:@"/homes/%d", homeId], parameters, MODEHome.class, completion);
}

+(void)deleteHome:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId completion:(void (^)(MODEHome *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"DELETE", [NSString stringWithFormat:@"/homes/%d", homeId], nil, MODEHome.class, completion);
}

// Home Member API

+(void)getHomeMembers:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId completion:(void (^)(NSArray *, NSError *))completion

{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequestForArray(manager,@"GET", [NSString stringWithFormat:@"/homes/%d/members", homeId], nil, MODEHomeMember.class, completion);
}

+(void)addHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId phoneNumber:(NSString *)phoneNumber completion:(void (^)(MODEHomeMember *, NSError *))completion
{
    // This is form request, so don't use getJSONRequesterWithAuth()
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"phoneNumber": phoneNumber};
    [manager.requestSerializer setValue:[@"ModeCloud " stringByAppendingString:clientAuthentication.token]forHTTPHeaderField:@"Authorization"];
    callHTTPRequest(manager, @"POST",  [NSString stringWithFormat:@"/homes/%d/members", homeId], parameters, MODEHomeMember.class, completion);
}

+(void)getHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId userId:(int)userId completion:(void (^)(MODEHomeMember *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"GET", [NSString stringWithFormat:@"/homes/%d/members/%d", homeId, userId], nil, MODEHomeMember.class, completion);
}

+(void)deleteHomeMember:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId userId:(int)userId completion:(void (^)(MODEHomeMember *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"DELETE", [NSString stringWithFormat:@"/homes/%d/members/%d", homeId, userId], nil, MODEHomeMember.class, completion);
}

// Smart Module API

+(void)getSmartModuleInfo:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId moduleId:(NSString*)moduleId completion:(void (^)(MODESmartModule *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"GET", [NSString stringWithFormat:@"/homes/%d/smartModules/%@", homeId, moduleId], nil, MODESmartModule.class, completion);
}

+(void)sendCommandToSmartModule:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId moduleId:(NSString *)moduleId action:(NSString *)action parameters:(NSDictionary *)eventParameters completion:(void (^)(MODESmartModule *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    NSDictionary *parameters = @{@"action": action, @"parameters": eventParameters};
    callHTTPRequest(manager,@"PUT", [NSString stringWithFormat:@"/homes/%d/smartModules/%@/command", homeId, moduleId], parameters, MODESmartModule.class, completion);

}

// Device API

+(void)getDevices:(MODEClientAuthentication *)clientAuthentication homeId:(int)homeId completion:(void (^)(NSArray *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequestForArray(manager,@"GET", @"/devices", @{@"homeId": [@(homeId) stringValue]}, MODEDevice.class, completion);
}

+ (void)getDeviceInfo:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId completion:(void (^)(MODEDevice *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"GET", [NSString stringWithFormat:@"/devices/%d", deviceId], nil, MODEDevice.class, completion);
}

+(void)claimDevice:(MODEClientAuthentication *)clientAuthentication claimCode:(NSString *)claimCode homeId:(int)homeId completion:(void (^)(MODEDevice *, NSError *))completion
{
    // This is form request, so don't use getJSONRequesterWithAuth()
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"claimCode": claimCode, @"homeId": [@(homeId) stringValue]};
    [manager.requestSerializer setValue:[@"ModeCloud " stringByAppendingString:clientAuthentication.token]forHTTPHeaderField:@"Authorization"];
    callHTTPRequest(manager,@"POST", @"/devices", parameters, MODEDevice.class, completion);
}

+(void)updateDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId name:(NSString *)name completion:(void (^)(MODEDevice *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"PATCH", [NSString stringWithFormat:@"/devices/%d", deviceId], @{@"name": name}, MODEDevice.class, completion);
}

+(void)deleteDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId completion:(void (^)(MODEDevice *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"DELETE", [NSString stringWithFormat:@"/devices/%d", deviceId], nil, MODEDevice.class, completion);
}

+(void)sendCommandToDevice:(MODEClientAuthentication *)clientAuthentication deviceId:(int)deviceId action:(NSString *)action parameters:(NSDictionary *)eventParameters completion:(void (^)(MODEDevice *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    NSDictionary *parameters = @{@"action": action, @"parameters": eventParameters};
    callHTTPRequest(manager,@"PUT", [NSString stringWithFormat:@"/devices/%d/command", deviceId], parameters, MODEDevice.class, completion);
}

// User Session API

+ (void)getUserSessionInfo:(MODEClientAuthentication *)clientAuthentication completion:(void (^)(MODEUserSessionInfo *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"GET", @"/userSession", nil, MODEUserSessionInfo.class, completion);
}

+(void)terminateUserSessionInfo:(MODEClientAuthentication *)clientAuthentication completion:(void (^)(MODEUserSessionInfo *, NSError *))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"DELETE", @"/userSession", nil, MODEUserSessionInfo.class, completion);
}

// Authentication API
+ (void)initiateAuthenticationWithSMS:(int)projectId phoneNumber:(NSString*)phoneNumber
                                   completion:(void(^)(MODESMSMessageReceipt*, NSError*))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"projectId": [@(projectId) stringValue], @"phoneNumber": phoneNumber};
    callHTTPRequest(manager, @"POST", @"/auth/user/sms", parameters, MODESMSMessageReceipt.class, completion);
}


+ (void)authenticateWithCode:(int)projectId phoneNumber:(NSString*)phoneNumber appId:(NSString*)appId code:(NSString*)code
                            completion:(void(^)(MODEClientAuthentication*, NSError*))completion;
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"code": code, @"projectId": [@(projectId) stringValue], @"phoneNumber": phoneNumber, @"appId": appId};
    callHTTPRequest(manager, @"POST", @"/auth/user", parameters, MODEClientAuthentication.class, completion);
}

+ (void)getCurrentAuthenticationState:(MODEClientAuthentication*)clientAuthentication completion:(void(^)(MODEAuthenticationInfo*, NSError*))completion
{
    AFHTTPRequestOperationManager *manager = getJSONRequesterWithAuth(clientAuthentication);
    callHTTPRequest(manager,@"GET", @"/auth", nil, MODEAuthenticationInfo.class, completion);
}

@end
