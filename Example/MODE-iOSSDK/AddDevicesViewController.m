#import "AddDevicesViewController.h"
#import "ButtonUtils.h"
#import "DataHolder.h"
#import "Messages.h"
#import "ModeApp.h"
#import "OverlayViewProtocol.h"
#import "Utils.h"


UIView* setupCommonAddDeviceWidgets(UITextField* verificationCodeField, UITextField* devicenameField, UILabel*message) {
    setupStandardTextField(verificationCodeField, @"Claim Code", @"ClaimCode.png");
    setupStandardTextField(devicenameField, @"Nickname (e.g. Office Lamp)", @"Nickname.png");
    setupMessage(message, MESSAGE_ADD_DEVICES);
    return setupTitle(@"Add device");
}

@interface AddDevicesViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) IBOutlet UITextField* deviceNameField;

@end

@implementation AddDevicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = setupCommonAddDeviceWidgets(self.verificationCodeField, self.deviceNameField, self.message);
    
    self.navigationItem.hidesBackButton = YES;
    
    setupMessage(self.message, MESSAGE_ADD_DEVICES);
}

- (void)removeOverlayViews
{
    removeOverlayViewSub(self.navigationController, nil);
}


- (IBAction)handleSkip:(id)sender {
    [self performSegueWithIdentifier:@"@console" sender:self];
}

- (IBAction)handleNext:(id)sender
{
    [self performSegueWithIdentifier:@"@console" sender:self];

    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI claimDevice:data.clientAuth claimCode:self.verificationCodeField.text homeId:data.members.homeId
        completion:^(MODEDevice *device, NSError *err) {
            if (err == nil) {
                [self updateDeviceName:device];
            } else {
                // You need to rollback because auth failed.
                [self.navigationController popToViewController:self animated:YES];
                showAlert(err);
            }
            
        }];

}

-(void)updateDeviceName:(MODEDevice*)device
{
    DataHolder* data = [DataHolder sharedInstance];
    [MODEAppAPI updateDevice:data.clientAuth deviceId:device.deviceId name:self.deviceNameField.text completion:^(MODEDevice *device, NSError *err) {
        if ( err != nil) {
            showAlert(err);
        }
    }];
}

@end
