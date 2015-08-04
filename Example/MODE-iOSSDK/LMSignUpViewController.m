#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMMessages.h"
#import "LMSignUpViewController.h"
#import "LMUtils.h"
#import "MODEApp.h"

@interface LMSignUpViewController ()

@property(strong, nonatomic) IBOutlet UILabel *message;
@property(strong, nonatomic) IBOutlet UILabel *note;


@property(strong, nonatomic) IBOutlet UITextField *nameField;
@property(strong, nonatomic) IBOutlet UITextField *phoneNumberField;
@property(strong, nonatomic) PhoneNumberFieldDelegate *phoneNumberDelegate;

@end

@implementation LMSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    setupMessage(self.message, MESSAGE_WELCOME, 15.0);
    setupMessage(self.note, MESSAGE_NOTE, 15.0);
    
    setupStandardTextField(self.nameField, @"Name", @"Name.png");
    self.navigationItem.titleView = setupTitle(@"Sign Up");
    self.phoneNumberDelegate = setupPhoneNumberField(self.phoneNumberField);
    setupKeyboardDismisser(self, @selector(dismissKeyboard));
}


- (void)dismissKeyboard
{
    [self.phoneNumberField resignFirstResponder];
    [self.nameField resignFirstResponder];
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
    [self performSegueWithIdentifier:@"VerifyAccountSegue" sender:self];

    [MODEAppAPI createUser:data.projectId phoneNumber:self.phoneNumberField.text name:self.nameField.text
        completion:^(MODEUser *user, NSError *err) {
            if (err != nil) {
                [weakSelf windBack];
                showAlert(err);
            } else {
                NSLog(@"Added user: %@", user);
            }
        }];
}

@end
