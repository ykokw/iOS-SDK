#import <UIKit/UIKit.h>
#import "OverlayViewProtocol.h"

@interface AddDevicesViewController : UIViewController<OverlayViewProtocol>

- (void)removeOverlayViews;
@end
