void removeOverlayViewSub(UINavigationController* navigationController, void(^completion)());
void setupOverlayView(UINavigationController* navigationController, NSString* text);

@protocol OverlayViewProtocol <NSObject>

-(void) removeOverlayViews;

@end
