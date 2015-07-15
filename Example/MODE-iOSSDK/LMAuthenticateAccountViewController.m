#import "LMAuthenticateAccountViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMMessages.h"
#import "MODEApp.h"
#import "LMOverlayViewProtocol.h"
#import "LMUtils.h"

@interface LMAuthenticateAccountViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) NumericTextFieldDelegate* numericDelegate;

@end

@implementation LMAuthenticateAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numericDelegate = setupNumericTextField(self.verificationCodeField,@"Authentication Code", @"Authentication.png");
    
    self.navigationItem.titleView = setupTitle(@"Authenticate Account");
    
    setupMessage(self.message, MESSAGE_VERIFY_YOU);
}

- (IBAction)handleNext:(id)sender
{
    setupOverlayView(self.navigationController, @"Verifying...");
    
    LMDataHolder* data = [LMDataHolder sharedInstance];

    [MODEAppAPI authenticateWithCode:data.projectId phoneNumber:data.members.phoneNumber appId:data.appId code:self.verificationCodeField.text
                          completion:^(MODEClientAuthentication *clientAuth, NSError *err) {
                              
                              if (err == nil) {
                                  data.clientAuth = clientAuth;
                                  
                                  [data saveData];

                                  removeOverlayViewSub(self.navigationController, ^(){
                                      [self performSegueWithIdentifier:@"@console" sender:self];
                                  });
                              } else {
                                  removeOverlayViewSub(self.navigationController, nil);
                                  
                                  showAlert(err);
                              }
                          }];
}

- (IBAction)handleResend:(id)sender
{

    LMDataHolder* data = [LMDataHolder sharedInstance];
    
    [MODEAppAPI initiateAuthenticationWithSMS:data.projectId phoneNumber:data.members.phoneNumber
                                   completion:^(MODESMSMessageReceipt *receipt, NSError *err) {
        if (err != nil) {
            showAlert(err);
        }
    }];

}

@end
