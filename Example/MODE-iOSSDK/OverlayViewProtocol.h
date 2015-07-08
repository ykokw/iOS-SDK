#import <Foundation/Foundation.h>

void removeOverlayViewSub(UINavigationController* navigationController);
void setupOverlayView(UINavigationController* navigationController, NSString* text);

@protocol OverlayViewProtocol <NSObject>

-(void) removeOverlayViews;

@end
