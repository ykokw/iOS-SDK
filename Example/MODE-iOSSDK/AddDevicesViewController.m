
#import "AddDevicesViewController.h"
#import "ModeApp.h"
#import "Utils.h"
#import "DataHolder.h"

@interface AddDevicesViewController ()

@property(strong, nonatomic) IBOutlet UITextField* verificationCodeField;

@end

@implementation AddDevicesViewController

- (IBAction)handleNext:(id)sender {
    DataHolder* data = [DataHolder sharedInstance];
//    
//    MODEAppAPI claimDevice:data.clientAuth claimCode:self.verificationCodeField.text homeId:data.homeId completion:^(MODEDevice *, NSError *) {
//        
//        
//    }
//    
//    [MODEAppAPI cl:data.projectId phoneNumber:data.phoneNumber appId:data.appId code:self.verificationCodeField.text
//                          completion:^(MODEClientAuthentication *clientAuth, NSError *err) {
//                              if (err == nil) {
//                                  data.clientAuth = clientAuth;
//                                  
//                                  [data saveData];
//                                  
//                                  [self performSegueWithIdentifier:@"CongratzSegue" sender:self];
//                              } else {
//                                  showAlert(err);
//                              }
//                          }];

}

@end
