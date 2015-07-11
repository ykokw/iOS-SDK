#import "AddHomeViewController.h"
#import "DataHolder.h"
#import "HomesTableViewController.h"
#import "Messages.h"
#import "MODEApp.h"
#import "Utils.h"


@interface AddHomeViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* nameField;
@property(strong, nonatomic) IBOutlet UIPickerView* timezoneField;
@property(strong, nonatomic) NSString* targetTimezone;
@property(strong, nonatomic) NSArray* timezones;

@end

@implementation AddHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    setupMessage(self.message, MESSAGE_CREATE_HOME);
 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(handleAdd)];

    setupStandardTextField(self.nameField, @"Name of Home", @"Home.png");
    
    self.timezoneField.dataSource = self;
    self.timezoneField.delegate = self;
    
    self.timezones = @[@"America/Los_Angeles", @"America/Detroit", @"America/Denver"];
    [self.timezoneField selectRow:0 inComponent:0 animated:TRUE];
    self.targetTimezone = self.timezones[0];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.timezones.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.targetTimezone = self.timezones[row];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return self.timezones[row];
}

-(void)handleAdd
{
    DataHolder* data = [DataHolder sharedInstance];
    
    [MODEAppAPI createHome:data.clientAuth name:self.nameField.text timezone:self.targetTimezone completion:^(MODEHome *home, NSError *err) {
        if(err != nil) {
            showAlert(err);
        } else {
            // You have to refresh loading homes at this timing, otherwise homes list is not updated.
            [self.sourceVC fetchHomes];
        }
    }];

    [self.navigationController popToViewController:self.sourceVC animated:YES];

}


@end
