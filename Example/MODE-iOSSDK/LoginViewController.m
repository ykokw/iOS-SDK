#import "LoginViewController.h"
#import "MODEApp.h"
#import "DataHolder.h"
#import "Utils.h"
#import "Messages.h"

@interface LoginViewController ()


@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* phoneNumberField;
@property(strong, nonatomic) PhoneNumberFieldDelegate* phoneNumberDelegate;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneNumberDelegate = setupPhoneNumberField(self.phoneNumberField);
    setupMessage(self.message, MESSAGE_WELCOME_BACK);
}

- (IBAction)handleNext:(id)sender {
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI initiateAuthenticationWithSMS:data.projectId phoneNumber:self.phoneNumberField.text completion:^(MODESMSMessageReceipt *receipt, NSError *err) {
                            if (err == nil) {
                                data.members.phoneNumber = receipt.recipient;
                                [self performSegueWithIdentifier:@"AuthenticateAccountSegue" sender:self];
        
                            } else {
                                showAlert(err);
                            }
        
        
    }];
}

@end
