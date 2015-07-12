#import "ButtonUtils.h"
#import "DataHolder.h"
#import "Messages.h"
#import "MODEApp.h"
#import "ProfileViewController.h"
#import "ProfileEditViewController.h"
#import "Utils.h"

@interface ProfileEditViewController ()

@property (strong, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) IBOutlet UITextField* nameField;
@property (strong, nonatomic) IBOutlet UITextField* phonenumberField;

@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    setupStandardTextField(self.nameField, @"Name", @"Name.png");
    
    
    setupMessage(self.message, MESSAGE_EDIT_PROFILE);
    
    setupRightBarButtonItem(self.navigationItem, @"Done", self, @selector(handleDone));
    
    self.navigationItem.titleView = setupTitle(@"My Profile");
    
    self.phonenumberField.enabled = false;
    
    [self fetchUserInfo];
}

-(void)handleDone
{
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI updateUserInfo:data.clientAuth userId:data.clientAuth.userId name:self.nameField.text completion:^(MODEUser *user, NSError *err) {
        
        if (err != nil) {
            showAlert(err);
        } else {
            NSLog(@"added %@", user);
           [self.sourceVC fetchUserInfo];
        }
    }];
    
    [self.navigationController popToViewController:self.sourceVC animated:YES];

}

-(void)fetchUserInfo
{
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI getUser:data.clientAuth userId:data.clientAuth.userId
             completion:^(MODEUser *user, NSError *err) {
                 if (err != nil) {
                     showAlert(err);
                 } else {
                     setupStandardTextField(self.nameField, user.name, @"Name.png");
                     setupStandardTextField(self.phonenumberField, user.phoneNumber, @"Phone.png");
                 }
             }];
}


@end
