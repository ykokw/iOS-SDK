#import "AddDeviceInConsoleViewController.h"
#import "AddHomeMemberViewController.h"
#import "ButtonUtils.h"
#import "DataHolder.h"
#import "MODEApp.h"
#import "HomeDetailableViewController.h"
#import "UIColor+Extentions.h"
#import "Utils.h"

#define DEVICES_IDX 0
#define MEMBERS_IDX 1


@interface HomeDetailableViewController ()

@property(strong, nonatomic) UIView * tableHeaderSubView;
@property(strong, nonatomic) UIButton* editButton;
@property(strong, nonatomic) UISegmentedControl* devicesOrMembersControl;

// Here we assume only either array is non nil to show which.
@property(strong, nonatomic) NSMutableArray* instances;

@end

@implementation HomeDetailableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    setupProfileButton(self.navigationItem, self, @selector(handleProfile));
    
    self.navigationItem.titleView = setupTitle(self.targetHome.name);
    
    [self fetchDevices];
}

-(BOOL)isMembers
{
     return self.devicesOrMembersControl.selectedSegmentIndex == MEMBERS_IDX;
}

-(void) handleProfile
{
    [self performSegueWithIdentifier:@"ProfileSegue" sender:nil];
}

- (void)fetchMembers
{
    self.editButton.selected = false;
    [self setEditing:false animated:true];

    DataHolder* data = [DataHolder sharedInstance];
    [MODEAppAPI getHomeMembers:data.clientAuth homeId:self.targetHome.homeId
        completion:^(NSArray *members, NSError *err) {
            self.devicesOrMembersControl.selectedSegmentIndex = MEMBERS_IDX;
            if (members != nil) {
                self.instances = [NSMutableArray arrayWithArray:members];
                for (MODEHomeMember* member in members) {
                    if (member.verified == false) {
                        member.name = @"(Unverified)";
                    }
                }
                [self.tableView reloadData];
            } else {
                showAlert(err);
            }
        }];
}

- (void)fetchDevices
{
    self.editButton.selected = false;
    [self setEditing:false animated:true];
    
    DataHolder* data = [DataHolder sharedInstance];
    [MODEAppAPI  getDevices:data.clientAuth homeId:self.targetHome.homeId
        completion:^(NSArray *devices, NSError *err) {
            self.devicesOrMembersControl.selectedSegmentIndex = DEVICES_IDX;
            if (devices != nil) {
                self.instances = [NSMutableArray arrayWithArray:devices];
                [self.tableView reloadData];
            } else {
                showAlert(err);
            }
        }];
}

- (void) addItem
{
    [self performSegueWithIdentifier:
     ([self isMembers] ? @"AddHomeMemberSegue" : @"AddDeviceSegue") sender:nil];
}

- (void) editItem
{
    NSLog(@"editItem");
    self.editButton.selected = !self.editing;
    [self setEditing:!self.editing animated:true];
}

-(void)handleDevicesOrMembers:(UISegmentedControl*)segment
{
    if ([self isMembers]) {
        [self fetchMembers];
    } else {
        [self fetchDevices];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.tableHeaderSubView == nil) {
        UIView* tableHeaderView = tableView.tableHeaderView;
        UIView *view=[[UIView alloc]init];
        setupAddButton(view, self, @selector(addItem));
        self.editButton = setupEditButton(view, self, @selector(editItem));
        [tableHeaderView insertSubview:view atIndex:0];
    
        NSArray *itemArray = [NSArray arrayWithObjects: @"Devices", @"Members", nil];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        segmentedControl.frame = CGRectMake(80, 10, 180, 26);
        [segmentedControl addTarget:self action:@selector(handleDevicesOrMembers:) forControlEvents: UIControlEventValueChanged];
        segmentedControl.tintColor = [UIColor defaultThemeColor];
        
        segmentedControl.selectedSegmentIndex = DEVICES_IDX;
        
        [view addSubview:segmentedControl];
        self.devicesOrMembersControl = segmentedControl;
        
        self.tableHeaderSubView = view;
        
    }
    return self.tableHeaderSubView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.instances.count;
}

- (NSString*) getCellIdentifier
{
    return [self isMembers] ? @"membersCellId" : @"devicesCellId";
}

- (void) setupCell:(UITableViewCell*) cell row:(long)row
{
    NSString* cellvalue;
    
    if( [self isMembers]) {
        MODEHomeMember* member = self.instances[row];
        cellvalue = member.name;
        
        cell.detailTextLabel.text = member.phoneNumber;

        
    } else {
        MODEDevice* device = self.instances[row];
        cellvalue = [device.name isEqual:@""] ? device.tag : device.name;
    }
    cell.textLabel.text = cellvalue;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [self getCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [self setupCell:cell row:indexPath.row];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.editing;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    DataHolder* data = [DataHolder sharedInstance];
    if ([self isMembers]) {
        MODEHomeMember* targetMember = self.instances[indexPath.row];
        [self.instances removeObjectAtIndex:indexPath.row];
        [MODEAppAPI deleteHomeMember:data.clientAuth homeId:self.targetHome.homeId userId:targetMember.userId
            completion:^(MODEHomeMember *member, NSError *err) {
                if (err != nil) {
                    showAlert(err);
                    [self fetchMembers];
                }
            }];
    } else {
        MODEDevice* targetDevice = self.instances[indexPath.row];
        [self.instances removeObjectAtIndex:indexPath.row];
        [MODEAppAPI deleteDevice:data.clientAuth deviceId:targetDevice.deviceId
            completion:^(MODEDevice *device, NSError *err) {
                if (err != nil) {
                    showAlert(err);
                    [self fetchDevices];
                }
        }];
    }
        
    // Then perform the action on the tableView
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddHomeMemberSegue"]) {
        AddHomeMemberViewController *view = [segue destinationViewController];
        view.sourceVC = self;
    } else if ([segue.identifier isEqualToString:@"AddDeviceSegue"]){
        AddDeviceInConsoleViewController *view = [segue destinationViewController];
        view.sourceVC = self;
    }
}

@end
