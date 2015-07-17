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

@end

@implementation LMAddDeviceInConsoleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = setupCommonAddDeviceWidgets(self.verificationCodeField, self.deviceNameField, self.message);
    
    setupRightBarButtonItem(self.navigationItem, @"Add", self, @selector(handleAdd));
    
    setupKeyboardDismisser(self, @selector(dismissKeyboard));
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
    [MODEAppAPI claimDevice:data.clientAuth claimCode:self.verificationCodeField.text homeId:self.sourceVC.targetHome.homeId
         completion:^(MODEDevice *device, NSError *err) {
             if (err != nil) {
                 showAlert(err);
             } else {
                 NSLog(@"Added device: %@", device);
                 [weakSelf updateDeviceName:device];
             }
         }];
    
     [self.navigationController popToViewController:self.sourceVC animated:YES];
}

@end
