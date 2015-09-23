#import "LMAddDevicesViewController.h"
#import "LMAddDeviceInConsoleViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMHomeDetailViewController.h"
#import "LMMessages.h"
#import "LMUIColor+Extentions.h"
#import "LMUtils.h"
#import "ModeApp.h"

// This view is almost the same as LMAddDevicesViewController, but it wasn't merged well because a couple of behavior are different.

@interface LMAddDeviceInConsoleViewController ()

@property(strong, nonatomic) IBOutlet UILabel *message;
@property(strong, nonatomic) IBOutlet UITextField *verificationCodeField;
@property(strong, nonatomic) IBOutlet UITextField *deviceNameField;

@property (strong, nonatomic) IBOutlet UIView *viewPreview;
@property (strong, nonatomic) IBOutlet UIButton *readButton;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation LMAddDeviceInConsoleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = setupCommonAddDeviceWidgets(self.verificationCodeField, self.deviceNameField, self.message);
    
    setupRightBarButtonItem(self.navigationItem, @"Add", self, @selector(handleAdd));
    setupKeyboardDismisser(self, @selector(dismissKeyboard));
    
    _isReading = NO;
}

- (IBAction)startStopReading:(id)sender {
    
    if (!_isReading) {
        if ([self startReading]) {
            //[_readButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
    } else {
        [self stopReading];
        //[_readButton setTitle:@"Start!" forState:UIControlStateNormal];
    }
    _isReading = !_isReading;
}

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }

    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];

    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];

    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];

    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    
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
 
    [_viewPreview.layer addSublayer:textLayer];
    
    // 3 - Focus overlay

    // Create CAShapeLayerS
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
    
    
    [_viewPreview.layer addSublayer:rectShape];
    
    [_captureSession startRunning];
    
    return YES;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
        if (metadataObjects != nil && [metadataObjects count] > 0) {
                AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
                if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
                        NSLog([metadataObj stringValue]);
            
                        [_verificationCodeField performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            
                        
                        [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
                        [_readButton performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
                        _isReading = NO;
                    }
            }

    
}

- (void)dismissKeyboard
{
    [self.verificationCodeField resignFirstResponder];
    [self.deviceNameField resignFirstResponder];
}

- (void)updateDeviceName:(MODEDevice*)device
{
    LMHomeDetailViewController *__weak sourceVC = self.sourceVC;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    [MODEAppAPI updateDevice:data.clientAuth deviceId:device.deviceId name:self.deviceNameField.text
        completion:^(MODEDevice *device, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                NSLog(@"Assigned device name: %@", device);
            }
            [sourceVC fetchDevices];
        }];
}

- (void)handleAdd
{
     __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    
#if 1
    [MODEAppAPI addDeviceToHomeWithClaimCode:data.clientAuth claimCode:self.verificationCodeField.text homeId:self.sourceVC.targetHome.homeId
         completion:^(MODEDevice *device, NSError *err) {
             if (err != nil) {
                 showAlert(err);
             } else {
                 NSLog(@"Added device: %@", device);
                 [weakSelf updateDeviceName:device];
             }
         }];
#else
    // This is the example how to call on-demand device addition to a home.
    [MODEAppAPI addDeviceToHomeOnDemand:data.clientAuth homeId:self.sourceVC.targetHome.homeId deviceClass:@"class1" deviceTag:nil
                             deviceName:self.deviceNameField.text
          completion:^(MODEDevice *device, NSError *err) {
              if (err != nil) {
                  showAlert(err);
              } else {
                  NSLog(@"Added device: %@", device);
                  [weakSelf updateDeviceName:device];
              }
          }];
    
#endif
    
     [self.navigationController popToViewController:self.sourceVC animated:YES];
}

@end
