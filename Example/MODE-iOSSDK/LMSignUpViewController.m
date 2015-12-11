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
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property(strong, nonatomic) PhoneNumberFieldDelegate *phoneNumberDelegate;
@property(strong, nonatomic) EmailFieldDelegate *emailFieldDelegate;

@end

@implementation LMSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    LMDataHolder *data = [LMDataHolder sharedInstance];

    if (data.isEmailLogin) {
        setupMessage(self.note, MESSAGE_NOTE_EMAIL, 15.0);
        self.emailFieldDelegate = setupEmailField(self.phoneNumberField);
        setupPassowrdField(self.passwordField);
    } else {
        setupMessage(self.note, MESSAGE_NOTE, 15.0);
        self.phoneNumberDelegate = setupPhoneNumberField(self.phoneNumberField);
        self.phoneNumberField.hidden = TRUE;
    }
    
    self.navigationItem.titleView = setupTitle(@"Sign Up");
    setupMessage(self.message, MESSAGE_WELCOME, 15.0);
    setupStandardTextField(self.nameField, @"Name", @"Name.png");
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
    [self performSegueWithIdentifier:@"VerifyAccountSegue" sender:self];

    if (data.isEmailLogin) {
        data.members.email = self.phoneNumberField.text;
        data.members.password = self.passwordField.text;
        [MODEAppAPI createUser:data.projectId email:self.phoneNumberField.text
                      password:self.passwordField.text name:self.nameField.text
                    completion:^(MODEUser *user, NSError *err) {
                        if (err != nil) {
                            [weakSelf windBack];
                            showAlert(err);
                        } else {
                            DLog(@"Added user: %@", user);
                        }
                    }];
    } else {
        data.members.phoneNumber = self.phoneNumberField.text;
        [MODEAppAPI createUser:data.projectId phoneNumber:self.phoneNumberField.text
                          name:self.nameField.text
            completion:^(MODEUser *user, NSError *err) {
                if (err != nil) {
                    [weakSelf windBack];
                    showAlert(err);
                } else {
                    DLog(@"Added user: %@", user);
                }
            }];
    }
}

@end
