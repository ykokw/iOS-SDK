#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMMessages.h"
#import "LMProfileViewController.h"
#import "LMProfileEditViewController.h"
#import "LMUtils.h"
#import "MODEApp.h"

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
    LMDataHolder* data = [LMDataHolder sharedInstance];
    
    [MODEAppAPI updateUserInfo:data.clientAuth userId:data.clientAuth.userId name:self.nameField.text
        completion:^(MODEUser *user, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                NSLog(@"Updated user name: %@", self.nameField.text);
                [self.sourceVC fetchUserInfo];
            }
        }];
    
    [self.navigationController popToViewController:self.sourceVC animated:YES];
}

-(void)fetchUserInfo
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    [MODEAppAPI getUser:data.clientAuth userId:data.clientAuth.userId
        completion:^(MODEUser *user, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                NSLog(@"Get user info: %@", user);
                setupStandardTextField(self.nameField, user.name, @"Name.png");
                setupStandardTextField(self.phonenumberField, formatPhonenumberFromString(user.phoneNumber), @"Phone.png");
            }
        }];
}

@end
