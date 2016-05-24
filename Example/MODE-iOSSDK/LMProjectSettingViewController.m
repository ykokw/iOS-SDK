#import "LMProjectSettingViewController.h"
#import "LMDataHolder.h"
#import "LMMessages.h"
#import "LMUtils.h"
#import "LMUIColor+Extentions.h"
#import "MODEApp.h"

@interface LMProjectSettingViewController ()
@property (strong, nonatomic) IBOutlet UITextField *projectIdField;
@property(strong, nonatomic) NumericTextFieldDelegate *numericDelegate;
@property (strong, nonatomic) IBOutlet UISwitch *isEmailLoginSwitch;
@property (strong, nonatomic) IBOutlet UILabel *emailLoginMessage;
@property (strong, nonatomic) IBOutlet UILabel *projectIdMessage;
@property (strong, nonatomic) IBOutlet UILabel *useEmailLoginMessage;
@property (strong, nonatomic) IBOutlet UIPickerView *apiHostPicker;
@property (strong, nonatomic) NSString* targetAPIHost;
@property (strong, nonatomic) NSArray* apiHosts;


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
    
    self.apiHostPicker.delegate = self;
    self.apiHostPicker.dataSource = self;
    
    int apiHostIdx = 0;
    _apiHosts = @[@"api.tinkermode.com", @"iot-device.jp-east-1.api.cloud.nifty.com"];
    if ([MODEAppAPI getAPIHost] != nil) {
        int cnt = 0;
        for (NSString *host in _apiHosts) {
            if ([host isEqualToString:[MODEAppAPI getAPIHost]]) {
                apiHostIdx = cnt;
                break;
            }
            cnt++;
        }
    }
    
    self.apiHostPicker.alpha = 1.0;
    [self.apiHostPicker selectRow:apiHostIdx inComponent:0 animated:TRUE];
    
    _targetAPIHost = _apiHosts[apiHostIdx];
    
    setupMessageConfigure(self.projectIdMessage, @"Enter your Project ID");
    setupMessageConfigure(self.emailLoginMessage, MESSAGE_EMAIL_LOGIN);
    setupMessageConfigure(self.useEmailLoginMessage, @"Use email login");
    
    setupKeyboardDismisser(self, @selector(dismissKeyboard));
}


- (void)dismissKeyboard
{
    [self.projectIdField resignFirstResponder];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _apiHosts.count;
}

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _targetAPIHost = _apiHosts[row];
}

-(NSString *)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _apiHosts[row];
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
    data.apiHost = _targetAPIHost;
    data.oldApiHost = _targetAPIHost;
    
    [data saveProjectId];
    [data saveData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

