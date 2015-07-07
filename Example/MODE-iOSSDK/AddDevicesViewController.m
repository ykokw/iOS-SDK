#import "AddDevicesViewController.h"
#import "ModeApp.h"
#import "Utils.h"
#import "DataHolder.h"

@interface AddDevicesViewController ()

@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;

@end

@implementation AddDevicesViewController


- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;
    self.verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.verificationCodeField.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0) || [string isEqualToString:@""];
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

@end
