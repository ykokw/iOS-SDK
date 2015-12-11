#import "LMProjectSettingViewController.h"
#import "LMDataHolder.h"
#import "LMUtils.h"

@interface LMProjectSettingViewController ()
@property (strong, nonatomic) IBOutlet UITextField *projectIdField;
@property(strong, nonatomic) NumericTextFieldDelegate *numericDelegate;
@property (strong, nonatomic) IBOutlet UISwitch *isEmailLoginSwitch;

@end

@implementation LMProjectSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LMDataHolder *data = [LMDataHolder sharedInstance];

    if (data.projectId != 0) {
        [self.projectIdField setText:[NSString stringWithFormat:@"%d", data.projectId]];
    }

    [self.isEmailLoginSwitch setOn:data.isEmailLogin];
    
    self.numericDelegate = setupNumericTextField(self.projectIdField, @"Project ID", nil);
    
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

