#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMLoginViewController.h"
#import "LMMessages.h"
#import "LMUtils.h"
#import "MODEApp.h"

@interface LMLoginViewController ()

@property(strong, nonatomic) IBOutlet UILabel *message;
@property(strong, nonatomic) IBOutlet UITextField *phoneNumberField;
@property(strong, nonatomic) PhoneNumberFieldDelegate *phoneNumberDelegate;

@end

@implementation LMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneNumberDelegate = setupPhoneNumberField(self.phoneNumberField);
    self.navigationItem.titleView = setupTitle(@"Log In");
    setupMessage(self.message, MESSAGE_WELCOME_BACK, 15.0);
}

- (void)windBack
{
    [self.navigationController popToViewController:self animated:YES];
}

- (IBAction)handleNext:(id)sender
{
    __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    data.members.phoneNumber = self.phoneNumberField.text;
    [self performSegueWithIdentifier:@"AuthenticateAccountSegue" sender:self];

    [MODEAppAPI initiateAuthenticationWithSMS:data.projectId phoneNumber:self.phoneNumberField.text
        completion:^(MODESMSMessageReceipt *receipt, NSError *err) {
            if (err != nil) {
                [weakSelf windBack];
                showAlert(err);
            } else {
                NSLog(@"Reinitiated auth token: %@", receipt);
            }
        }];
}

@end
