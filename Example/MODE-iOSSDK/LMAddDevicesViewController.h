#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "LMOverlayViewProtocol.h"

UIView *setupCommonAddDeviceWidgets(UITextField *verificationCodeField, UITextField *devicenameField, UILabel *message);
void setupKeyboardDismisser(UIViewController *viewController, SEL action);

@interface LMAddDevicesViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

- (void)removeOverlayViews;

@end
