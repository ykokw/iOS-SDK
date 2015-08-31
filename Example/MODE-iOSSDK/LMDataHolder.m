#import "LMDataHolder.h"
#import "LMDeviceManager.h"

@implementation LMDataHolderMembers

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"phoneNumber": @"phoneNumber",
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
        
        // You need to setup projectId and appId according to your project and App settings.
        // Please see more detail (http://dev.tinkermode.com/tutorials/getting_started.html) to get them.
        self.projectId = 154;
        self.appId = @"ios-r1";
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
        NSLog(@"Object is nil: %@", key);
        return;
    }
    NSError *err;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[MTLJSONAdapter JSONDictionaryFromModel:obj error:nil]
                                                       options:0 error:&err];
    if (err) {
        NSLog(@"%@", err);
    }
    
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"saved: %@", str);
    
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveData
{
    saveObject(@"auth", self.clientAuth);
    saveObject(@"members", self.members);
}

id loadObj(NSString *key, Class class)
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
    {
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        
        NSLog(@"loaded: %@", str);
        
        NSError *err;
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        
        id obj = [MTLJSONAdapter modelOfClass:class fromJSONDictionary:dict error:&err];
        
        if (err) {
            NSLog(@"%@", err);
        }
        
        if (obj) {
            NSLog(@"Auth %@", obj);
        }
        
        return obj;
    } else {
        NSLog(@"Cannot find object in key: %@", key);
    }
    return [[class alloc] init];
}

- (void)loadData
{
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
