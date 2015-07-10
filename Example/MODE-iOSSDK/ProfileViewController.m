#import "DataHolder.h"
#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UITextField* nameField;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self.nameField setPlaceholder:@"Name"];
}

- (IBAction)handleLogout:(id)sender {
    
    DataHolder* data = [DataHolder sharedInstance];
    
    data.members = nil;
    data.clientAuth = nil;
    [data saveData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}


@end
