#import "AddDeviceInConsoleViewController.h"
#import "ButtonUtils.h"
#import "DataHolder.h"
#import "HomeDetailableViewController.h"
#import "Messages.h"
#import "ModeApp.h"
#import "OverlayViewProtocol.h"
#import "UIColor+Extentions.h"
#import "Utils.h"

// This view is almost the same as AddDevicesViewController, but it wasn't merged well because a couple of behavior are different.

@interface AddDeviceInConsoleViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) IBOutlet UITextField* deviceNameField;

@end

@implementation AddDeviceInConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    setupStandardTextField(self.verificationCodeField, @"Claim Code", @"ClaimCode.png");

    setupStandardTextField(self.deviceNameField, @"Nickname (e.g. Office Lamp)", @"Nickname.png");

    setupMessage(self.message, MESSAGE_ADD_DEVICES);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(handleAdd)];
    
    self.navigationItem.titleView = setupTitle(@"Add device");

}

-(void)updateDeviceName:(MODEDevice*)device
{
    DataHolder* data = [DataHolder sharedInstance];
    [MODEAppAPI updateDevice:data.clientAuth deviceId:device.deviceId name:self.deviceNameField.text completion:^(MODEDevice *device, NSError *err) {
        if ( err != nil) {
            showAlert(err);
        }
        [self.sourceVC fetchDevices];
    }];
}

-(void)handleAdd {
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI claimDevice:data.clientAuth claimCode:self.verificationCodeField.text homeId:self.sourceVC.targetHome.homeId
                 completion:^(MODEDevice *device, NSError *err) {
                     if (err != nil) {
                         showAlert(err);
                     } else {
                         NSLog(@"added %@", device);
                         [self updateDeviceName:device];
                     }
                 }];
    
     [self.navigationController popToViewController:self.sourceVC animated:YES];
}

@end
