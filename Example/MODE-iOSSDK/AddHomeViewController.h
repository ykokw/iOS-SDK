#import <UIKit/UIKit.h>

@class HomesTableViewController;
@class MODEHome;

@interface AddHomeViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property(weak, nonatomic) HomesTableViewController* sourceVC;

@property(strong, nonatomic) MODEHome* targetHome;

@end
