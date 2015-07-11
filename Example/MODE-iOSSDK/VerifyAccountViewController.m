#import "ButtonUtils.h"
#import "VerifyAccountViewController.h"
#import "MODEApp.h"
#import "DataHolder.h"
#import "Utils.h"
#import "Messages.h"
#import "OverlayViewProtocol.h"

@interface VerifyAccountViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) NumericTextFieldDelegate* numericDelegate;

@end

@implementation VerifyAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.numericDelegate = setupNumericTextField(self.verificationCodeField,@"Verification Code", @"Authentication.png");

    self.navigationItem.titleView = setupTitle(@"Verify Account");
    
    setupMessage(self.message, MESSAGE_VERIFY_YOU);
}

- (IBAction)handleNext:(id)sender
{
    [self performSegueWithIdentifier:@"RegisteredSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    setupOverlayView(self.navigationController, @"Verifying...");

    DataHolder* data = [DataHolder sharedInstance];
    
    UIViewController<OverlayViewProtocol> *destVC = [segue destinationViewController];
    
    [MODEAppAPI authenticateWithCode:data.projectId phoneNumber:data.members.phoneNumber appId:data.appId code:self.verificationCodeField.text
                          completion:^(MODEClientAuthentication *clientAuth, NSError *err) {
                              
                              [destVC removeOverlayViews];
                              
                              if (err == nil) {
                                  data.clientAuth = clientAuth;
                                  [data saveData];
                                  
                              } else {
                                  // You need to rollback because auth failed.
                                  [self.navigationController popToViewController:self animated:YES];
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
