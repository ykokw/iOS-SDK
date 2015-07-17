void removeOverlayViewSub(UINavigationController *navigationController, void(^completion)());
void setupOverlayView(UINavigationController *navigationController, NSString *text);

@protocol LMOverlayViewProtocol <NSObject>

- (void)removeOverlayViews;

@end
