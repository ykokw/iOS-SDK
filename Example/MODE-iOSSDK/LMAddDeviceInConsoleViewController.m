#import "LMAddDevicesViewController.h"
#import "LMAddDeviceInConsoleViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMHomeDetailableViewController.h"
#import "LMMessages.h"
#import "LMUIColor+Extentions.h"
#import "LMUtils.h"
#import "ModeApp.h"

// This view is almost the same as LMAddDevicesViewController, but it wasn't merged well because a couple of behavior are different.

@interface LMAddDeviceInConsoleViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) IBOutlet UITextField* deviceNameField;

@end

@implementation LMAddDeviceInConsoleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = setupCommonAddDeviceWidgets(self.verificationCodeField, self.deviceNameField, self.message);
    
    setupRightBarButtonItem(self.navigationItem, @"Add", self, @selector(handleAdd));
}

-(void)updateDeviceName:(MODEDevice*)device
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    [MODEAppAPI updateDevice:data.clientAuth deviceId:device.deviceId name:self.deviceNameField.text
        completion:^(MODEDevice *device, NSError *err) {
            if ( err != nil) {
                showAlert(err);
            } else {
                NSLog(@"Assigned device name: %@", device);
            }
            [self.sourceVC fetchDevices];
        }];
}

-(void)handleAdd
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    
    [MODEAppAPI claimDevice:data.clientAuth claimCode:self.verificationCodeField.text homeId:self.sourceVC.targetHome.homeId
         completion:^(MODEDevice *device, NSError *err) {
             if (err != nil) {
                 showAlert(err);
             } else {
                 NSLog(@"Added device: %@", device);
                 [self updateDeviceName:device];
             }
         }];
    
     [self.navigationController popToViewController:self.sourceVC animated:YES];
}

@end
