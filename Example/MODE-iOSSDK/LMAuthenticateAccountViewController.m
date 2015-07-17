#import "LMAuthenticateAccountViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMMessages.h"
#import "LMOverlayViewProtocol.h"
#import "LMUtils.h"
#import "MODEApp.h"

@interface LMAuthenticateAccountViewController ()

@property(strong, nonatomic) IBOutlet UILabel *message;
@property(strong, nonatomic) IBOutlet UITextField *verificationCodeField;
@property(strong, nonatomic) NumericTextFieldDelegate *numericDelegate;

@end

@implementation LMAuthenticateAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numericDelegate = setupNumericTextField(self.verificationCodeField,@"Authentication Code", @"Authentication.png");
    self.navigationItem.titleView = setupTitle(@"Authenticate Account");
    setupMessage(self.message, MESSAGE_VERIFY_YOU, 15.0);
}

-(void)removeOverlayView:(BOOL)nextSegue
{
    removeOverlayViewSub(self.navigationController, ^(){
        if (nextSegue) {
            [self performSegueWithIdentifier:@"@console" sender:self];
        }
    });
}

- (IBAction)handleNext:(id)sender
{
    // Need to show overlay until Auth token is taken.
    setupOverlayView(self.navigationController, @"Verifying...");
    
    __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    [MODEAppAPI authenticateWithCode:data.projectId phoneNumber:data.members.phoneNumber appId:data.appId code:self.verificationCodeField.text
        completion:^(MODEClientAuthentication *clientAuth, NSError *err) {
            if (err != nil) {
                showAlert(err);
                [weakSelf removeOverlayView:false];
            } else {
                NSLog(@"Got auth token: %@", clientAuth);
                data.clientAuth = clientAuth;
                [data saveData];
                [weakSelf removeOverlayView:true];
            }
        }];
}

- (IBAction)handleResend:(id)sender
{
    LMDataHolder *data = [LMDataHolder sharedInstance];
    initiateAuth(data.projectId, data.members.phoneNumber);
}

@end
