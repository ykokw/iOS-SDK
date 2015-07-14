#import "DataHolder.h"
#import "DeviceManager.h"
#import "ModeEventListener.h"

@interface DeviceManager ()

@property(strong, nonatomic)NSMutableArray* deviceEventDelegates;

@property(strong, nonatomic) MODEEventListener* listener;
@property(strong, nonatomic)MODEClientAuthentication* currentClientAuth;

@end


@implementation DeviceManager

+ (DeviceManager *)sharedInstance
{
    static DeviceManager *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      _sharedInstance = [[self alloc] init];
                  });
    
    return _sharedInstance;

}

- (id) init
{
    self = [super init];
    self.deviceEventDelegates = [[NSMutableArray alloc]init];
    return self;
}


- (void)addMODEDeviceDelegate:(id<MODEDeviceEventDelegate>) delegate
{
    [self.deviceEventDelegates addObject:delegate];
}

- (void) callDeviceEventDelegates:(MODEDeviceEvent*) event err:(NSError*) err
{
    for (id<MODEDeviceEventDelegate> delegate in self.deviceEventDelegates) {
        [delegate receivedEvent:event err:err];
    }
    
}

- (void) checkAndStartListenToEvents:(MODEClientAuthentication*)clientAuth
{
    if (![self.currentClientAuth.token isEqualToString:clientAuth.token]) {
        self.currentClientAuth = clientAuth;
        self.listener = [[MODEEventListener alloc] initWithClientAuthentication:clientAuth];
        [self.listener startListenToEvents:^(MODEDeviceEvent *event, NSError *err) {
            [self callDeviceEventDelegates:event err:err];
        }];
    }
    
}

- (void)queryDeviceStatus
{
    
}

@end
