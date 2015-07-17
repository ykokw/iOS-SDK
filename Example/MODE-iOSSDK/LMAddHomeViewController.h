#import <UIKit/UIKit.h>

@class LMHomesTableViewController;
@class MODEHome;

@interface LMAddHomeViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property(weak, nonatomic) LMHomesTableViewController *sourceVC;

@property(strong, nonatomic) MODEHome *targetHome;

@end
