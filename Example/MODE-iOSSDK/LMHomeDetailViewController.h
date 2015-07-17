#import <UIKit/UIKit.h>
#import "LMDeviceManager.h"

@class MODEHome;

@interface LMHomeDetailViewController : UITableViewController<MODEDeviceEventDelegate>

@property(strong, nonatomic) MODEHome *targetHome;

- (void)fetchMembers;
- (void)fetchDevices;

@end
