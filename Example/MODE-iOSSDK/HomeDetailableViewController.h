#import <UIKit/UIKit.h>
#import "MODEData.h"

@interface HomeDetailableViewController : UITableViewController

@property(strong, nonatomic) MODEHome* targetHome;

- (void)fetchMembers;
- (void)fetchDevices;

@end
