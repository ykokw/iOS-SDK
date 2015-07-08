#import "VerifyAccountViewController.h"
#import "MODEApp.h"
#import "DataHolder.h"
#import "Utils.h"
#import "Messages.h"

@interface VerifyAccountViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) NumericTextFieldDelegate* numericDelegate;

@end

@implementation VerifyAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.numericDelegate = setupNumericTextField(self.verificationCodeField,@"Verification Code");
    setupMessage(self.message, MESSAGE_VERIFY_YOU);
}

- (IBAction)handleNext:(id)sender
{
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI authenticateWithCode:data.projectId phoneNumber:data.members.phoneNumber appId:data.appId code:self.verificationCodeField.text
                          completion:^(MODEClientAuthentication *clientAuth, NSError *err) {
                              if (err == nil) {
                                  data.clientAuth = clientAuth;
                                  
                                  [data saveData];
                                  
                                  [self performSegueWithIdentifier:@"RegisteredSegue" sender:self];
                              } else {
                                  showAlert(err);
                              }
                          }];
}

- (IBAction)handleResend:(id)sender {
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI initiateAuthenticationWithSMS:data.projectId phoneNumber:data.members.phoneNumber
                                   completion:^(MODESMSMessageReceipt *receipt, NSError *err) {
                                       if (err != nil) {
                                           showAlert(err);
                                       }
                                   }];
    
}

@end
