#import <UIKit/UIKit.h>
#import "LMOverlayViewProtocol.h"

UIView* setupCommonAddDeviceWidgets(UITextField* verificationCodeField, UITextField* devicenameField, UILabel* message);

@interface LMAddDevicesViewController : UIViewController<LMOverlayViewProtocol>

- (void)removeOverlayViews;

@end
