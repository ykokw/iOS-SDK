#import "OverlayViewProtocol.h"


void removeOverlayViewSub(UINavigationController* navigationController)
{
    UIView *view = (UIView *)[navigationController.view viewWithTag:88];
    UILabel *label = (UILabel *)[navigationController.view viewWithTag:99];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.alpha = 0.0;
                         label.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                         [label removeFromSuperview];
                     }
     ];

}

void setupOverlayView(UINavigationController* navigationController, NSString* text)
{
    // create a custom black view
    UIView *overlayView = [[UIView alloc] initWithFrame:navigationController.view.frame];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.8;
    overlayView.tag = 88;
    
    // create a label
    UILabel *message = [[UILabel alloc] initWithFrame:navigationController.view.frame];
    [message setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
    message.text = text;
    message.textColor = [UIColor whiteColor];
    message.textAlignment = NSTextAlignmentCenter;
    message.tag = 99;
    
    // and just add them to navigationbar view
    [navigationController.view addSubview:overlayView];
    [navigationController.view addSubview:message];
    
}
