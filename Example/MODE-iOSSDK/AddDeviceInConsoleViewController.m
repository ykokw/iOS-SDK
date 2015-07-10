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
@property(strong, nonatomic) NumericTextFieldDelegate* numericDelegate;

@end

@implementation AddDeviceInConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.numericDelegate = [[NumericTextFieldDelegate alloc] init];
    self.verificationCodeField.delegate = self.numericDelegate;
    
    setupMessage(self.message, MESSAGE_ADD_DEVICES);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(handleAdd)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = setupTitle(@"Add device");

}

-(void)handleAdd {
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI claimDevice:data.clientAuth claimCode:self.verificationCodeField.text homeId:self.sourceVC.targetHome.homeId
                 completion:^(MODEDevice *device, NSError *err) {
                     if (err != nil) {
                         showAlert(err);
                     }
                     
                     NSLog(@"added %@", device);
                     [self.sourceVC fetchDevices];
                 }];
    
     [self.navigationController popToViewController:self.sourceVC animated:YES];

}

@end
