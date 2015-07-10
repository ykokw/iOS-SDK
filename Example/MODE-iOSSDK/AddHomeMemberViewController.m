#import "AddHomeMemberViewController.h"
#import "DataHolder.h"
#import "HomeDetailableViewController.h"
#import "Messages.h"
#import "MODEApp.h"
#import "Utils.h"
#import "ButtonUtils.h"

@interface AddHomeMemberViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* phoneNumberField;
@property(strong, nonatomic) PhoneNumberFieldDelegate* phoneNumberDelegate;

@end

@implementation AddHomeMemberViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneNumberDelegate = setupPhoneNumberField(self.phoneNumberField);
    setupMessage(self.message, MESSAGE_INVITE);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(handleAdd)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = setupTitle(@"Add Member");
}

-(void)handleAdd
{
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI addHomeMember:data.clientAuth homeId:self.sourceVC.targetHome.homeId phoneNumber:self.phoneNumberField.text
        completion:^(MODEHomeMember *member, NSError *err) {
            if (err != nil) {
                showAlert(err);
            }
            NSLog(@"added %@", member);
            [self.sourceVC fetchMembers];
        }];
    
    [self.navigationController popToViewController:self.sourceVC animated:YES];
}


@end
