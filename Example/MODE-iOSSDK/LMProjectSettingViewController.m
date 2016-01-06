#import "LMProjectSettingViewController.h"
#import "LMDataHolder.h"
#import "LMMessages.h"
#import "LMUtils.h"
#import "LMUIColor+Extentions.h"

@interface LMProjectSettingViewController ()
@property (strong, nonatomic) IBOutlet UITextField *projectIdField;
@property(strong, nonatomic) NumericTextFieldDelegate *numericDelegate;
@property (strong, nonatomic) IBOutlet UISwitch *isEmailLoginSwitch;
@property (strong, nonatomic) IBOutlet UILabel *emailLoginMessage;
@property (strong, nonatomic) IBOutlet UILabel *projectIdMessage;
@property (strong, nonatomic) IBOutlet UILabel *useEmailLoginMessage;

@end

@implementation LMProjectSettingViewController


void setupMessageConfigure(UILabel *message, NSString *text)
{
    setupMessageWithColorAndAlign(message, text,  [UIColor bodyTextColor], 15.0, NSTextAlignmentLeft);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LMDataHolder *data = [LMDataHolder sharedInstance];

    if (data.projectId != 0) {
        [self.projectIdField setText:[NSString stringWithFormat:@"%d", data.projectId]];
    }

    [self.isEmailLoginSwitch setOn:data.isEmailLogin];
    
    self.numericDelegate = setupNumericTextField(self.projectIdField, @"Project ID", nil);
    
    
    setupMessageConfigure(self.projectIdMessage, @"Enter your Project ID");
    setupMessageConfigure(self.emailLoginMessage, MESSAGE_EMAIL_LOGIN);
    setupMessageConfigure(self.useEmailLoginMessage, @"Use email login");
    
    setupKeyboardDismisser(self, @selector(dismissKeyboard));
}


- (void)dismissKeyboard
{
    [self.projectIdField resignFirstResponder];
}


- (IBAction)handleOK:(id)sender {
    int projectId = (int)[self.projectIdField.text integerValue];
    BOOL isEmailLogin = self.isEmailLoginSwitch.on;
    
    if (projectId == 0) {
        showAlert([NSError errorWithDomain:@"Invalid Project ID" code:0 userInfo:nil]);
        return;
    }
    
    LMDataHolder *data = [LMDataHolder sharedInstance];
    data.members = [[LMDataHolderMembers alloc] init];
    data.clientAuth = [[MODEClientAuthentication alloc] init];
    
    data.projectId = projectId;
    data.oldProjectId = data.projectId;
    
    data.isEmailLogin = isEmailLogin;
    data.oldIsEmailLogin = data.isEmailLogin;
    
    [data saveProjectId];
    [data saveData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

