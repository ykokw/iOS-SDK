#import "AddDevicesViewController.h"
#import "ModeApp.h"
#import "Utils.h"
#import "DataHolder.h"
#import "Messages.h"

@interface AddDevicesViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) NumericTextFieldDelegate* numericDelegate;

@end

@implementation AddDevicesViewController


- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;
    self.verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.numericDelegate = [[NumericTextFieldDelegate alloc] init];
    self.verificationCodeField.delegate = self.numericDelegate;
    
    setupMessage(self.message, MESSAGE_ADD_DEVICES);
}

- (IBAction)handleNext:(id)sender {
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI claimDevice:data.clientAuth claimCode:self.verificationCodeField.text homeId:data.members.homeId
        completion:^(MODEDevice *device, NSError *err) {
            if (err == nil) {
                
                data.targetDevice = device;
                [data saveData];
                
                [self performSegueWithIdentifier:@"CongratzSegue" sender:self];
            } else {
                showAlert(err);
            }
            
        }];

}

- (IBAction)handleSkip:(id)sender {
     [self performSegueWithIdentifier:@"CongratzSegue" sender:self];
}

@end
