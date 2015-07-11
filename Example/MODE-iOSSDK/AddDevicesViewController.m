#import "AddDevicesViewController.h"
#import "DataHolder.h"
#import "Messages.h"
#import "ModeApp.h"
#import "OverlayViewProtocol.h"
#import "Utils.h"

@interface AddDevicesViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;

@end

@implementation AddDevicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    setupStandardTextField(self.verificationCodeField, @"Claim Code", @"ClaimCode.png");
    self.navigationItem.hidesBackButton = YES;
    
    setupMessage(self.message, MESSAGE_ADD_DEVICES);
}

- (void)removeOverlayViews
{
    removeOverlayViewSub(self.navigationController, nil);
}

- (IBAction)handleNext:(id)sender
{
    [self performSegueWithIdentifier:@"CongratzSegue" sender:self];

    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI claimDevice:data.clientAuth claimCode:self.verificationCodeField.text homeId:data.members.homeId
        completion:^(MODEDevice *device, NSError *err) {
            if (err == nil) {
                [data saveData];
            } else {
                // You need to rollback because auth failed.
                [self.navigationController popToViewController:self animated:YES];
                showAlert(err);
            }
            
        }];

}

- (IBAction)handleSkip:(id)sender
{
     [self performSegueWithIdentifier:@"CongratzSegue" sender:self];
}

@end
