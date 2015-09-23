#import "LMDataHolder.h"
#import "LMDeviceManager.h"
#import "LMUtils.h"
#import "MODEApp.h"
#import "ModeEventListener.h"

@interface LMDeviceManager ()

@property(strong, nonatomic)NSMutableArray *deviceEventDelegates;
@property(strong, nonatomic)MODEEventListener *listener;

@end

@implementation LMDeviceManager

+ (LMDeviceManager *)sharedInstance
{
    static LMDeviceManager *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate, ^{
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

- (void)removeMODEDeviceDelegate:(id<MODEDeviceEventDelegate>)delegate
{
    [self.deviceEventDelegates removeObject:delegate];
}

- (void)callDeviceEventDelegates:(MODEDeviceEvent*) event err:(NSError*) err
{
    /**
      *event.evenType == "status"
      *event.eventData == {"switch": 1} or {"switch": 0}
     */
    for (id<MODEDeviceEventDelegate> delegate in self.deviceEventDelegates) {
        if (err) {
            DLog(@"Receive event error %@", err);
        }
        
        DLog(@"event: %@", event);
        if (event && [event.eventType isEqualToString:@"status"]) {
            DLog(@"eventData: %@", event.eventData);
            if([event.eventData[@"switch"] intValue] == 1) {
                [delegate receivedEvent:event.originDeviceId status:TRUE];
                DLog(@"Received status deeviceId: %d status 1", event.originDeviceId);
            } else if([event.eventData[@"switch"] intValue] == 0) {
                [delegate receivedEvent:event.originDeviceId status:FALSE];
                DLog(@"Received status deeviceId: %d status 0", event.originDeviceId);
            } else {
                DLog(@"Unknown eventData: %@", event.eventData);
            }
        } else if (event && [event.eventType isEqualToString:@"click"]) {
            DLog(@"eventData: %@", event.eventData);
            if([event.eventData[@"button"] intValue] == 1) {
                [delegate receivedButtonPressed:event.originDeviceId];
                DLog(@"Received button pressed deeviceId: %d button 1", event.originDeviceId);
            } else {
                DLog(@"Unknown eventData: %@", event.eventData);
            }
        }

    }
}

- (BOOL) startListenToEvents:(MODEClientAuthentication*)clientAuth
{
    DLog(@"Start listenning to device events.");
    if (clientAuth.token == nil) {
        DLog(@"Failed to start listening because auth token is nil");
        return false;
    }
    
    self.listener = [[MODEEventListener alloc] initWithClientAuthentication:clientAuth];
    
    [self.listener startListenToEvents:^(MODEDeviceEvent *event, NSError *err) {
        [self callDeviceEventDelegates:event err:err];
    }];
    
    return true;
}

- (void)stopListenToEvents
{
    DLog(@"Stop listenning to device events.");
    [self.listener stopListenToEvents];
    self.listener = nil;
}

- (void)reconnect
{
    if (self.listener == nil) {
        DLog(@"Reconnect to listen to device events.");
        LMDataHolder *data = [LMDataHolder sharedInstance];
        [self startListenToEvents:data.clientAuth];
    }
}

- (void)queryDeviceStatus:(NSArray *)devices
{
    // Broadcast query to all devices.
    /**
      *command.action == "query"
      *command.parameters == {}
     */
    LMDataHolder *data = [LMDataHolder sharedInstance];
    for (MODEDevice *device in devices) {
        [MODEAppAPI sendCommandToDevice:data.clientAuth deviceId:device.deviceId action:@"query" parameters:@{}
             completion:^(MODEDevice *device, NSError *err) {
                 if (err != nil) {
                     showAlert(err);
                 } else {
                     DLog(@"Query event triggered: deviceId: %d", device.deviceId);
                 }
             }];
    }
}

- (void)triggerSwitch:(int)deviceId status:(BOOL)status
{
    /**
      *command.action == "change"
      *command.parameters == {"switch": 1} or {"switch": 0}
     */
    LMDataHolder *data = [LMDataHolder sharedInstance];
    NSNumber *value = [NSNumber numberWithInt:status];
    [MODEAppAPI sendCommandToDevice:data.clientAuth deviceId:deviceId action:@"change" parameters:@{@"switch":value}
        completion:^(MODEDevice *device, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                DLog(@"Switch event triggered: deviceId: %d, light %@", deviceId, value);
            }
        }];
}

@end
