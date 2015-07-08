#import <UIKit/UIKit.h>
#import "OverlayViewProtocol.h"

@interface RegisteredViewController : UIViewController<OverlayViewProtocol>

-(void) removeOverlayViews;

@end
