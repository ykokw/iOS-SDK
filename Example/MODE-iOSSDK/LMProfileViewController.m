#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMProfileEditViewController.h"
#import "LMProfileViewController.h"
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
    self.phoneIcon.image = [UIImage imageNamed:@"Phone.png"];
}

-(void)handleEdit
{
    [self performSegueWithIdentifier:@"ProfileEditSegue" sender:nil];
}

-(void)fetchUserInfo
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    [MODEAppAPI getUser:data.clientAuth userId:data.clientAuth.userId
        completion:^(MODEUser *user, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                setupMessage(self.userName, user.name);
                setupMessage(self.phonenumber, formatPhonenumberFromString(user.phoneNumber));
            }
        }];
}

- (IBAction)handleLogout:(id)sender
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    data.members = [[LMDataHolderMembers alloc] init];
    data.clientAuth = [[MODEClientAuthentication alloc] init];
    [data saveData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ProfileEditViewController *view = [segue destinationViewController];
    view.sourceVC = self;
}

@end
