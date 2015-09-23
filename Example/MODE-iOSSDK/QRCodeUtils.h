#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

BOOL startReadingQRCode(UIView* viewPreview, AVCaptureSession* captureSession, AVCaptureVideoPreviewLayer* videoPreviewLayer,
                        id<AVCaptureMetadataOutputObjectsDelegate> delegate);