#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMLoginViewController.h"
#import "LMMessages.h"
#import "LMOverlayViewProtocol.h"
#import "LMUtils.h"
#import "MODEApp.h"

@interface LMLoginViewController ()

@property(strong, nonatomic) IBOutlet UILabel *message;
@property(strong, nonatomic) IBOutlet UITextField *phoneNumberField;
@property(strong, nonatomic) PhoneNumberFieldDelegate *phoneNumberDelegate;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = setupTitle(@"Log In");
    LMDataHolder *data = [LMDataHolder sharedInstance];
    
    if (data.isEmailLogin) {
        setupEmailField(self.phoneNumberField);
        setupPassowrdField(self.passwordField);
    } else {
        self.passwordField.hidden = TRUE;
        self.phoneNumberDelegate = setupPhoneNumberField(self.phoneNumberField);
    }
    
    setupMessage(self.message, data.isEmailLogin ? MESSAGE_WELCOME_BACK_EMAIL : MESSAGE_WELCOME_BACK, 15.0);
}

- (void)windBack
{
    [self.navigationController popToViewController:self animated:YES];
}


- (void)removeOverlayView:(BOOL)nextSegue
{
    removeOverlayViewSub(self.navigationController, ^(){
        if (nextSegue) {
            [self performSegueWithIdentifier:@"@console" sender:self];
        }
    });
}


- (void)handleNextEmail:(id)sender
{
    __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    data.members.email = self.phoneNumberField.text;
    // Need to show overlay until Auth token is taken.
    setupOverlayView(self.navigationController, @"Verifying...");
    
    [MODEAppAPI authenticateWithEmail:data.projectId email:data.members.email password:self.passwordField.text appId:data.appId
                           completion:^(MODEClientAuthentication *clientAuth, NSError *err) {
                               if (err != nil) {
                                   showAlert(err);
                                   [weakSelf removeOverlayView:false];
                               } else {
                                   DLog(@"Got auth token: %@", clientAuth);
                                   data.clientAuth = clientAuth;
                                   [data saveData];
                                   [weakSelf removeOverlayView:true];
                               }
                           }];

}

- (void)handleNextPhone:(id)sender
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
                                           DLog(@"Reinitiated auth token: %@", receipt);
                                       }
                                   }];

}

- (IBAction)handleNext:(id)sender
{
    LMDataHolder *data = [LMDataHolder sharedInstance];
    if (data.isEmailLogin) {
        [self handleNextEmail:sender];
    } else {
        [self handleNextPhone:sender];
    }
}

@end
