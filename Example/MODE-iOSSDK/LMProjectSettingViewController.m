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
@property (strong, nonatomic) IBOutlet UILabel *apiHostMessage;
@property (strong, nonatomic) IBOutlet UITableView *apiHostTableView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSArray* apiHosts;
@property int targetAPIHostIndex;

@end

@implementation LMProjectSettingViewController

int targetAPIHostIndex;

void setupMessageConfigure(UILabel *message, NSString *text)
{
    setupMessageWithColorAndAlign(message, text,  [UIColor bodyTextColor], 15.0, NSTextAlignmentLeft);
}

-(void)gestureAction:(UITapGestureRecognizer *) sender
{
    CGPoint touchLocation = [sender locationOfTouch:0 inView:_apiHostTableView];
    NSIndexPath *indexPath = [_apiHostTableView indexPathForRowAtPoint:touchLocation];
    
    _targetAPIHostIndex = (int)indexPath.row;
    [_apiHostTableView reloadData];
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
    
    self.apiHostTableView.delegate = self;
    self.apiHostTableView.dataSource = self;
    
    // We are using UIScrollView as parent view holder to scroll the page.
    // To escape the gensture caputere of UIScrollView, you need this trick.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
    [recognizer setNumberOfTapsRequired:1];
    _scrollView.userInteractionEnabled = YES;
    [_scrollView addGestureRecognizer:recognizer];
    
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
    
    _targetAPIHostIndex = apiHostIdx;
    
    setupStandardTextField(_projectIdField, @"Project ID", nil);
    setupMessageConfigure(self.projectIdMessage, @"Enter your Project ID");
    setupMessageConfigure(self.emailLoginMessage, MESSAGE_EMAIL_LOGIN);
    setupMessageConfigure(self.apiHostMessage, MESSAGE_API_HOST);
    setupMessageConfigure(self.useEmailLoginMessage, @"Use email login");
    
    setupKeyboardDismisser(self, @selector(dismissKeyboard));
}


- (void)dismissKeyboard
{
    [self.projectIdField resignFirstResponder];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _apiHosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = @"APIHostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor defaultThemeColorWithAlpha:0.40];
        [cell setSelectedBackgroundView:bgColorView];
        
    }
    
    cell.accessoryType =  _targetAPIHostIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellSelectionStyleNone;
    
    NSString* cellvalue = _apiHosts[indexPath.row];
    setCellLabel(cell.textLabel, cellvalue, [UIColor subCellTextColor], 15.0);

    return cell;
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
    data.apiHost = _apiHosts[_targetAPIHostIndex];
    data.oldApiHost = data.apiHost;
    
    [data saveProjectId];
    [data saveData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

