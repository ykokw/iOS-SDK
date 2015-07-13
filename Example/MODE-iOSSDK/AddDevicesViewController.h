#import <UIKit/UIKit.h>
#import "OverlayViewProtocol.h"

UIView* setupCommonAddDeviceWidgets(UITextField* verificationCodeField, UITextField* devicenameField, UILabel* message);

@interface AddDevicesViewController : UIViewController<OverlayViewProtocol>

- (void)removeOverlayViews;

@end
