#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@class LMHomeDetailViewController;

@interface LMAddDeviceInConsoleViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property(weak, nonatomic) LMHomeDetailViewController *sourceVC;

@end
