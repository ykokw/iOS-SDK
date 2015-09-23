#include "LMUtils.h"
#include "QRCodeUtils.h"

BOOL startReadingQRCode(UIView* viewPreview, AVCaptureSession* captureSession, AVCaptureVideoPreviewLayer* videoPreviewLayer,
                        id<AVCaptureMetadataOutputObjectsDelegate> delegate) {
    
    // Setup capture device and session
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        showAlert(error);
        return NO;
    }
    
    [captureSession addInput:input];
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:delegate queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoPreviewLayer setFrame:viewPreview.layer.bounds];
    
    [viewPreview.layer addSublayer:videoPreviewLayer];
    
    // 1 - Set up the text layer
    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    [subtitle1Text setFont:@"Helvetica-Bold"];
    [subtitle1Text setFontSize:14];
    [subtitle1Text setFrame:CGRectMake(0, 0, 200, 100)];
    [subtitle1Text setString:@"Scan QR code here"];
    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    CALayer *textLayer = [CALayer layer];
    [textLayer addSublayer:subtitle1Text];
    textLayer.frame = CGRectMake(0, 8, 200, 100);
    [textLayer setMasksToBounds:YES];
    
    [viewPreview.layer addSublayer:textLayer];
    
    // 2 Set up the focus box layer
    CAShapeLayer* rectShape = [CAShapeLayer layer];
    rectShape.bounds = CGRectMake(0, 0, 300, 300);
    rectShape.position = CGPointMake(175, 175);
    rectShape.lineWidth = 3;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, 0);
    CGPathAddLineToPoint(path, nil, 150, 0);
    CGPathAddLineToPoint(path, nil, 150, 150);
    CGPathAddLineToPoint(path, nil, 0, 150);
    CGPathAddLineToPoint(path, nil, 0, 0);
    CGPathCloseSubpath(path);
    rectShape.path = path;
    
    rectShape.masksToBounds = NO;
    rectShape.strokeColor = [UIColor whiteColor].CGColor;
    rectShape.fillColor = [UIColor clearColor].CGColor;
    
    [viewPreview.layer addSublayer:rectShape];
    [captureSession startRunning];
    
    return YES;
}

