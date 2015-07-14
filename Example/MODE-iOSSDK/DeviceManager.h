#import <UIKit/UIKit.h>

@class MODEDeviceEvent;

@protocol MODEDeviceEventDelegate <NSObject>

-(void)receivedEvent:(int)deviceId status:(BOOL)status;

@end

@interface DeviceManager : NSObject

+ (DeviceManager *)sharedInstance;

- (void)addMODEDeviceDelegate:(id<MODEDeviceEventDelegate>) delegate;
- (void)removeMODEDeviceDelegate:(id<MODEDeviceEventDelegate>) delegate;


- (void)startListenToEvents:(MODEClientAuthentication*)clientAuth;
- (void)stopListenToEvents;

- (void)queryDeviceStatus:(NSArray*)devices;
- (void)triggerSwitch:(int)deviceId status:(BOOL)status;

@end
