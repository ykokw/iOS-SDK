#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMMessages.h"
#import "LMOverlayViewProtocol.h"
#import "LMVerifyAccountViewController.h"
#import "LMUtils.h"
#import "MODEApp.h"

@interface LMVerifyAccountViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;
@property(strong, nonatomic) NumericTextFieldDelegate* numericDelegate;

@end

@implementation LMVerifyAccountViewController

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

-(void)createMyHome:(UIViewController<LMOverlayViewProtocol>*)destVC
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    
    // Here we just create default "My Home" and set "Los Angeles" timezone.
    // But you have to rewrite according to users' environment.
    [MODEAppAPI createHome:data.clientAuth name:@"My Home" timezone:@"America/Los_Angeles"
        completion:^(MODEHome *home, NSError *err) {
            [destVC removeOverlayViews];
            if (err == nil) {
                data.members.homeId = home.homeId;
                
                [data saveData];
            } else {
                showAlert(err);
            }
        }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    setupOverlayView(self.navigationController, @"Verifying...");
    UIViewController<LMOverlayViewProtocol> *destVC = [segue destinationViewController];
    
    LMDataHolder* data = [LMDataHolder sharedInstance];
    [MODEAppAPI authenticateWithCode:data.projectId phoneNumber:data.members.phoneNumber appId:data.appId code:self.verificationCodeField.text
          completion:^(MODEClientAuthentication *clientAuth, NSError *err) {
              if (err == nil) {
                  data.clientAuth = clientAuth;
                  [data saveData];
                  [self createMyHome:destVC];
              } else {
                  // You need to rollback because auth failed.
                  [destVC removeOverlayViews];
                  
                  [self.navigationController popToViewController:self animated:YES];
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
