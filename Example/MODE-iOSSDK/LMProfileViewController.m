#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMProfileEditViewController.h"
#import "LMProfileViewController.h"
#import "LMUIColor+Extentions.h"
#import "LMUtils.h"
#import "MODEApp.h"

@interface LMProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *nameIcon;
@property (strong, nonatomic) IBOutlet UIImageView *phoneIcon;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *phonenumber;

@end

@implementation LMProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self fetchUserInfo];
    setupRightBarButtonItem(self.navigationItem, @"Edit", self, @selector(handleEdit));
    self.navigationItem.titleView = setupTitle(@"My Profile");
    self.nameIcon.image = [UIImage imageNamed:@"Name.png"];
    LMDataHolder *data = [LMDataHolder sharedInstance];
    self.phoneIcon.image = [UIImage imageNamed:data.isEmailLogin ? @"Email.png" : @"Phone.png"];
}

- (void)handleEdit
{
    [self performSegueWithIdentifier:@"ProfileEditSegue" sender:nil];
}

- (void)updateFields:(MODEUser *)user
{
    setupMessageWithColorAndAlign(self.userName, user.name, [UIColor bodyTextColor], 24.0, NSTextAlignmentLeft);
    
    LMDataHolder *data = [LMDataHolder sharedInstance];

    NSString* ident = data.isEmailLogin ? user.email : formatPhonenumberFromString(user.phoneNumber);
    setupMessageWithColorAndAlign(self.phonenumber, ident, [UIColor bodyTextColor], 24.0, NSTextAlignmentLeft);
}

- (void)fetchUserInfo
{
    __weak __typeof__(self) weakSelf = self;
    LMDataHolder *data = [LMDataHolder sharedInstance];
    [MODEAppAPI getUser:data.clientAuth userId:data.clientAuth.userId
        completion:^(MODEUser *user, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                DLog(@"Get user info: %@", user);
                [weakSelf updateFields:user];
            }
        }];
}

- (IBAction)handleLogout:(id)sender
{
    LMDataHolder *data = [LMDataHolder sharedInstance];
    data.members = [[LMDataHolderMembers alloc] init];
    data.clientAuth = [[MODEClientAuthentication alloc] init];
    [data saveData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ProfileEditViewController *view = [segue destinationViewController];
    view.sourceVC = self;
}

@end
