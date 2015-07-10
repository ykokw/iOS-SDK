#import <UIKit/UIKit.h>

@class HomesTableViewController;

@interface AddHomeViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property(weak, nonatomic) HomesTableViewController* sourceVC;

@end
