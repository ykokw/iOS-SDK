#import "LMAddHomeViewController.h"
#import "LMButtonUtils.h"
#import "LMDataHolder.h"
#import "LMHomesTableViewController.h"
#import "LMMessages.h"
#import "LMUtils.h"
#import "MODEApp.h"

// LMAddHomeViewController is shared for Edit/Add Home.

@interface LMAddHomeViewController ()

@property(strong, nonatomic) IBOutlet UILabel* message;
@property(strong, nonatomic) IBOutlet UITextField* nameField;
@property(strong, nonatomic) IBOutlet UIPickerView* timezoneField;
@property(strong, nonatomic) NSString* targetTimezone;
@property(strong, nonatomic) NSArray* timezones;

@end

@implementation LMAddHomeViewController

-(NSString*) getMessage
{
    return self.targetHome ? MESSAGE_EDIT_HOME : MESSAGE_CREATE_HOME;
}

-(NSString*) getTitle
{
    return self.targetHome ? @"Edit Home" : @"Add Home";
}

-(void) setupRightBarButton
{
    if (self.targetHome) {
        setupRightBarButtonItem(self.navigationItem, @"Done", self, @selector(handleDone));
    } else {
        setupRightBarButtonItem(self.navigationItem, @"Add", self, @selector(handleAdd));
    }
}

-(NSString*)getHomeName
{
    return self.targetHome ? self.targetHome.name : @"Name of Home";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    setupMessage(self.message, [self getMessage], 15.0);
 
    [self setupRightBarButton];
    
    setupStandardTextField(self.nameField, [self getHomeName], @"Home.png");
    
    self.navigationItem.titleView = setupTitle([self getTitle]);
    
    self.timezoneField.delegate = self;
    self.timezoneField.dataSource = self;
    
    int timezoneIdx = 0;
    self.timezones = @[@"America/Los_Angeles", @"America/Detroit", @"America/Denver"];
    if (self.targetHome != nil) {
        int cnt = 0;
        for (NSString* tz in self.timezones) {
            if ([tz isEqualToString:self.targetHome.timezone]) {
                timezoneIdx = cnt;
                break;
            }
            cnt++;
        }
    }
    
    [self.timezoneField selectRow:timezoneIdx inComponent:0 animated:TRUE];
    
    self.targetTimezone = self.timezones[timezoneIdx];
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

-(void)completion:(NSError*)err log:(NSString*)log
{
    if(err != nil) {
        showAlert(err);
    } else {
        NSLog(log);
        // You have to refresh loading homes at this timing, otherwise homes list is not updated.
        [self.sourceVC fetchHomes];
    }
}

-(void)handleAdd
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    
    [MODEAppAPI createHome:data.clientAuth name:self.nameField.text timezone:self.targetTimezone
        completion:^(MODEHome *home, NSError *err) {
            [self completion:err log:[NSString stringWithFormat:@"Added home: %@", home]];
        }];

    [self.navigationController popToViewController:self.sourceVC animated:YES];

}

-(void)handleDone
{
    LMDataHolder* data = [LMDataHolder sharedInstance];
    
   [MODEAppAPI updateHome:data.clientAuth homeId:self.targetHome.homeId name:self.nameField.text timezone:self.targetTimezone completion:^(MODEHome *home, NSError *err) {
       [self completion:err log:[NSString stringWithFormat:@"Uupdate home name: %@", self.nameField.text]];
    }];
    
    [self.navigationController popToViewController:self.sourceVC animated:YES];
}

@end
