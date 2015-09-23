#import "LMAddDevicesViewController.h"
#import "LMAddDeviceInConsoleViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMHomeDetailViewController.h"
#import "LMMessages.h"
#import "LMUIColor+Extentions.h"
#import "LMUtils.h"
#import "ModeApp.h"
#import "QRCodeUtils.h"

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
    [self dismissKeyboard];
    
    if (!_isReading) {
        [self startReading];
    } else {
        [self stopReading];
    }
    _isReading = !_isReading;
}

- (BOOL)startReading
{
    _captureSession = [[AVCaptureSession alloc] init];
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    return startReadingQRCode(_viewPreview, _captureSession, _videoPreviewLayer, self);
}

-(void)stopReading
{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [_verificationCodeField performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue]waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
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
