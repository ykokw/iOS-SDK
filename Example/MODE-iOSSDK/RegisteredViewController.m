#import "RegisteredViewController.h"
#import "ModeApp.h"
#import "DataHolder.h"
#import "Utils.h"

@implementation RegisteredViewController


- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;
}

- (IBAction)handleNext:(id)sender {
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI createHome:data.clientAuth name:@"MyHome" timezone:@"America/Los_Angeles" completion:^(MODEHome *home, NSError *err) {
        if (err == nil) {
            data.members.homeId = home.homeId;
            
            [data saveData];
            
            [self performSegueWithIdentifier:@"AddDevicesSegue" sender:self];
        } else {
            showAlert(err);
        }
    }];
    
}

@end
