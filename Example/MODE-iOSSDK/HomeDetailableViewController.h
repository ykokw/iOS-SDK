#import <UIKit/UIKit.h>

@class MODEHome;

@interface HomeDetailableViewController : UITableViewController

@property(strong, nonatomic) MODEHome* targetHome;

- (void)fetchMembers;
- (void)fetchDevices;

@end
