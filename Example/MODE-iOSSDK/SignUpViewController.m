#import "SignUpViewController.h"
#import "MODEApp.h"
#import "DataHolder.h"
#import "Utils.h"

@interface SignUpViewController ()

@property(strong, nonatomic) IBOutlet UITextField* nameField;
@property(strong, nonatomic) IBOutlet UITextField* phoneNumberField;
@property(strong, nonatomic) PhoneNumberFieldDelegate* phoneNumberDelegate;

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.nameField setPlaceholder:@"Name"];
     self.phoneNumberDelegate = setupPhoneNumberField(self.phoneNumberField);
}

- (IBAction)handleNext:(id)sender
{
    DataHolder* data = [DataHolder sharedInstance];

    data.members.userName = self.nameField.text;
    data.members.phoneNumber = self.phoneNumberField.text;
    [self performSegueWithIdentifier:@"VerifyAccountSegue" sender:self];

    [MODEAppAPI createUser:data.projectId phoneNumber:self.phoneNumberField.text name:self.nameField.text
                completion:^(MODEUser *user, NSError *err) {
                    if (err != nil) {
                        showAlert(err);
                    }
                }];
}

@end
