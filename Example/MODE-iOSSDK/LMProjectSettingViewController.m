#import "LMProjectSettingViewController.h"
#import "LMDataHolder.h"
#import "LMUtils.h"

@interface LMProjectSettingViewController ()
@property (strong, nonatomic) IBOutlet UITextField *projectIdField;
@property(strong, nonatomic) NumericTextFieldDelegate *numericDelegate;

@end

@implementation LMProjectSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LMDataHolder *data = [LMDataHolder sharedInstance];

    if (data.projectId != 0) {
        [self.projectIdField setText:[NSString stringWithFormat:@"%d", data.projectId]];
    }
    
     self.numericDelegate = setupNumericTextField(self.projectIdField, @"Project ID", nil);
}

- (IBAction)handleOK:(id)sender {
    LMDataHolder *data = [LMDataHolder sharedInstance];
    data.members = [[LMDataHolderMembers alloc] init];
    data.clientAuth = [[MODEClientAuthentication alloc] init];
    
    data.projectId = [self.projectIdField.text integerValue];
    data.oldProjectId = data.projectId;
    
    [data saveProjectId];
    [data saveData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

