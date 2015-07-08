#import "AuthenticateAccountViewController.h"
#import "MODEApp.h"
#import "DataHolder.h"
#import "Utils.h"

@interface AuthenticateAccountViewController ()

@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) NumericTextFieldDelegate* numericDelegate;

@end

@implementation AuthenticateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.numericDelegate = setupNumericTextField(self.verificationCodeField,@"Authentication Code");
}

- (IBAction)handleNext:(id)sender {
    DataHolder* data = [DataHolder sharedInstance];

    [MODEAppAPI authenticateWithCode:data.projectId phoneNumber:data.members.phoneNumber appId:data.appId code:self.verificationCodeField.text
                          completion:^(MODEClientAuthentication *clientAuth, NSError *err) {
                              if (err == nil) {
                                  data.clientAuth = clientAuth;
                                  
                                  [data saveData];
                                  
                                  [self performSegueWithIdentifier:@"AuthenticatedSegue" sender:self];
                              } else {
                                  showAlert(err);
                              }
                          }];
}

@end
