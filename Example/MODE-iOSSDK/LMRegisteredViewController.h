#import <UIKit/UIKit.h>
#import "LMOverlayViewProtocol.h"

@interface LMRegisteredViewController : UIViewController<LMOverlayViewProtocol>

-(void) removeOverlayViews;

@end
