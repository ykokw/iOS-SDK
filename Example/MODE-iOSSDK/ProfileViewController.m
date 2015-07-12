#import "ButtonUtils.h"
#import "DataHolder.h"
#import "ProfileEditViewController.h"
#import "ProfileViewController.h"
#import "MODEApp.h"

#import "Utils.h"

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *nameIcon;
@property (strong, nonatomic) IBOutlet UIImageView *phoneIcon;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *phonenumber;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchUserInfo];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(handleEdit)];
    
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
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI getUser:data.clientAuth userId:data.clientAuth.userId
             completion:^(MODEUser *user, NSError *err) {
                 if (err != nil) {
                     showAlert(err);
                 } else {
                     setupMessage(self.userName, user.name);
                     setupMessage(self.phonenumber, user.phoneNumber);
                 }
             }];
}


- (IBAction)handleLogout:(id)sender {
    
    DataHolder* data = [DataHolder sharedInstance];
    
    data.members = nil;
    data.clientAuth = nil;
    [data saveData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ProfileEditViewController *view = [segue destinationViewController];
    view.sourceVC = self;
}

@end
