#import "LMDataHolder.h"
#import "LMDeviceManager.h"
#import "LMUtils.h"
#import "MODEApp.h"
#import "MODEEventListener.h"

@implementation LMDataHolderMembers

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"phoneNumber": @"phoneNumber",
             @"email": @"email",
             // Intentional not to save @"password": @"password",
             @"homeId": @"homeId"
             };
}

@end

@implementation LMDataHolder

- (id) init
{
    self = [super init];
    if (self) {
        self.members = [[LMDataHolderMembers alloc] init];
        
        // You would need to setup appId according to your App settings.
        // The sample project pregenerates "controller_app" App. So you don't have to change the project
        // if you use it as it is.
        // Please see more detail (http://dev.tinkermode.com/tutorials/getting_started.html) to get them.
        self.appId = @"controller_app";
    }
    
    return self;
}

+ (LMDataHolder *)sharedInstance
{
    static LMDataHolder *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate, ^{
                      _sharedInstance = [[self alloc] init];
                  });
    
    return _sharedInstance;
}


void saveObject(NSString *key, id<MTLJSONSerializing> obj)
{
    if (obj == nil) {
        DLog(@"Object is nil: %@", key);
        return;
    }
    NSError *err;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[MTLJSONAdapter JSONDictionaryFromModel:obj error:nil]
                                                       options:0 error:&err];
    if (err) {
        DLog(@"%@", err);
    }
    
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    DLog(@"saved: %@", str);
    
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveProjectId
{
    _doNotObserveValue = TRUE;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.projectId] forKey:@"projectId"];
    [[NSUserDefaults standardUserDefaults] setBool:self.isEmailLogin forKey:@"isEmailLogin"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.projectId] forKey:@"oldProjectId"];
    [[NSUserDefaults standardUserDefaults] setBool:self.isEmailLogin forKey:@"oldIsEmailLogin"];
    
    if (_apiHost != nil) {
        [MODEAppAPI setAPIHost:_apiHost];
        [MODEEventListener setWebsocketHost:_apiHost];
        [[NSUserDefaults standardUserDefaults] setObject:_oldApiHost forKey:@"oldApiHost"];
        [[NSUserDefaults standardUserDefaults] setObject:_apiHost forKey:@"apiHost"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    _doNotObserveValue = FALSE;
}

-(void) setApiHost:(NSString *)apiHost
{
    if (apiHost != _apiHost) {
        _apiHost = apiHost;
    }
}

- (void)saveData
{
    _doNotObserveValue = TRUE;
    saveObject(@"auth", self.clientAuth);
    saveObject(@"members", self.members);

    [[NSUserDefaults standardUserDefaults] synchronize];
    _doNotObserveValue = FALSE;
}

id loadObj(NSString *key, Class class)
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
    {
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        
        DLog(@"loaded: %@", str);
        
        NSError *err;
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        
        id obj = [MTLJSONAdapter modelOfClass:class fromJSONDictionary:dict error:&err];
        
        if (err) {
            DLog(@"%@", err);
        }
        
        if (obj) {
            DLog(@"Auth %@", obj);
        }
        
        return obj;
    } else {
        DLog(@"Cannot find object in key: %@", key);
    }
    return [[class alloc] init];
}

- (void)loadProjectId
{
    NSString* oldPid = [[NSUserDefaults standardUserDefaults] objectForKey:@"oldProjectId"];
    
    if (oldPid != nil) {
        self.oldProjectId = [oldPid intValue];
    }
    
    NSString* pid = [[NSUserDefaults standardUserDefaults] objectForKey:@"projectId"];
    
    if (pid != nil) {
        self.projectId = [pid intValue];
    }

    NSString* oldEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"oldIsEmailLogin"];
    
    if (oldEmail != nil) {
        self.oldIsEmailLogin = [oldEmail boolValue];
    }
    
    NSString* email = [[NSUserDefaults standardUserDefaults] objectForKey:@"isEmailLogin"];
    
    if (email != nil) {
        self.isEmailLogin = [email boolValue];
    }
    
    NSString* apiHost = [[NSUserDefaults standardUserDefaults] objectForKey:@"apiHost"];
    
    if (apiHost != nil) {
        _apiHost = apiHost;
        [MODEAppAPI setAPIHost:_apiHost];
        [MODEEventListener setWebsocketHost:_apiHost];
    }
    
    NSString* oldApiHost = [[NSUserDefaults standardUserDefaults] objectForKey:@"oldApiHost"];
    if (oldApiHost != nil) {
        _oldApiHost = oldApiHost;
    }
}

- (void)loadData
{
    // call loadProjectId first to get apiHost. It's used for websocket connection.
    [self loadProjectId];

    self.clientAuth = loadObj(@"auth", MODEClientAuthentication.class);
    self.members = loadObj(@"members", LMDataHolderMembers.class);
}

- (void)setClientAuth:(MODEClientAuthentication *)clientAuth
{
    self->_clientAuth = clientAuth;
    if (clientAuth.token) {
        // Only when Authentication is valid, start listening to events.
        [[LMDeviceManager sharedInstance] startListenToEvents:self.clientAuth];
    } else {
        [[LMDeviceManager sharedInstance] stopListenToEvents];
    }
}

@end
