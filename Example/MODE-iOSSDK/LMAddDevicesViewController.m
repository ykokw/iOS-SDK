#import "LMAddDevicesViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMMessages.h"
#import "LMOverlayViewProtocol.h"
#import "LMRoundButton.h"
#import "LMUIColor+Extentions.h"
#import "LMUtils.h"
#import "ModeApp.h"
#import "QRCodeUtils.h"

UIView *setupCommonAddDeviceWidgets(UITextField *verificationCodeField, UITextField *devicenameField, UILabel*message)
{
    setupStandardTextField(verificationCodeField, @"Claim Code", @"ClaimCode.png");
    setupStandardTextField(devicenameField, @"Nickname (e.g. Office Lamp)", @"Nickname.png");
    [verificationCodeField setReturnKeyType:UIReturnKeyDone];
    setupMessage(message, MESSAGE_ADD_DEVICES, 15.0);
    return setupTitle(@"Add device");
}

@interface LMAddDevicesViewController ()

@property(strong, nonatomic) IBOutlet UILabel *message;
@property(strong, nonatomic) IBOutlet UITextField *verificationCodeField;
@property(strong, nonatomic) IBOutlet UITextField *deviceNameField;

@property (strong, nonatomic) IBOutlet UIView *viewPreview;
@property (strong, nonatomic) IBOutlet UIButton *readButton;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) IBOutlet LMRoundButton *nextButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation LMAddDevicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = setupCommonAddDeviceWidgets(self.verificationCodeField, self.deviceNameField, self.message);
    self.navigationItem.hidesBackButton = YES;
    
    setupMessage(self.message, MESSAGE_ADD_DEVICES, 15.0);
    setupKeyboardDismisser(self, @selector(dismissKeyboard));

    [self showHideQRScanView:NO];
}

-(void)showHideQRScanView:(BOOL)showPreview
{
    _nextButton.hidden = showPreview;
    _pageControl.hidden = showPreview;
    _skipButton.hidden = showPreview;
    _viewPreview.hidden = !showPreview;
    if (showPreview) {
        [_readButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _readButton.backgroundColor = [UIColor defaultDisplayColor];
    } else {
        [_readButton setTitleColor:[UIColor defaultDisplayColor] forState:UIControlStateNormal];
        _readButton.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)startStopReading:(id)sender
{
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
    [self showHideQRScanView:YES];
    _captureSession = [[AVCaptureSession alloc] init];
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    return startReadingQRCode(_viewPreview, _captureSession, _videoPreviewLayer, self);
}

-(void)stopReading
{
    [self showHideQRScanView:NO];
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

- (void)removeOverlayViews
{
    removeOverlayViewSub(self.navigationController, nil);
}

- (IBAction)handleSkip:(id)sender {
    [self performSegueWithIdentifier:@"@console" sender:self];
}

- (void)updateDeviceName:(MODEDevice*)device
{
    NSString *name = self.deviceNameField.text;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    [MODEAppAPI updateDevice:data.clientAuth deviceId:device.deviceId name:self.deviceNameField.text
        completion:^(MODEDevice *device, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                DLog(@"Updated device name: %@", name);
            }
        }];
}

- (IBAction)handleNext:(id)sender
{
    [self performSegueWithIdentifier:@"@console" sender:self];

    __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    [MODEAppAPI addDeviceToHomeWithClaimCode:data.clientAuth claimCode:self.verificationCodeField.text homeId:data.members.homeId
        completion:^(MODEDevice *device, NSError *err) {
            if (err != nil) {
                // You need to rollback because auth failed.
                [weakSelf.navigationController popToViewController:weakSelf animated:YES];
                showAlert(err);
            } else {
                DLog(@"Attached device: %@ to homeId %d", device, data.members.homeId);
                [weakSelf updateDeviceName:device];
            }
        }];
}

@end
