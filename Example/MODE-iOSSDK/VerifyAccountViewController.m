#import "VerifyAccountViewController.h"
#import "MODEApp.h"
#import "DataHolder.h"
#import "Utils.h"

@interface VerifyAccountViewController ()

@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) NumericTextFieldDelegate* numericDelegate;

@end

@implementation VerifyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.verificationCodeField setPlaceholder:@"Verification Code"];
    
    self.verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.numericDelegate = [[NumericTextFieldDelegate alloc] init];
    self.verificationCodeField.delegate = self.numericDelegate;
}

- (IBAction)handleNext:(id)sender {
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

@end
