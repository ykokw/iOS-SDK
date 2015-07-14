#import <UIKit/UIKit.h>

@class MODEDeviceEvent;

@protocol MODEDeviceEventDelegate <NSObject>

-(void)receivedEvent:(MODEDeviceEvent*)event err:(NSError*)err;

@end

@interface DeviceManager : NSObject

+ (DeviceManager *)sharedInstance;

- (void)queryDeviceStatus;
- (void)addMODEDeviceDelegate:(id<MODEDeviceEventDelegate>) delegate;

- (void) checkAndStartListenToEvents:(MODEClientAuthentication*)clientAuth;

@end
