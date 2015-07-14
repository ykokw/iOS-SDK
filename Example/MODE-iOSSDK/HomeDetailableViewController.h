#import <UIKit/UIKit.h>
#import "DeviceManager.h"

@class MODEHome;

@interface HomeDetailableViewController : UITableViewController<MODEDeviceEventDelegate>

@property(strong, nonatomic) MODEHome* targetHome;

- (void)fetchMembers;
- (void)fetchDevices;

@end
